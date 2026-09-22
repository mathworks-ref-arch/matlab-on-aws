# Copyright 2025-2026 The MathWorks, Inc.

# Function to set permissions
set_permissions() {
  local dir="$1"
  local owner="$2"
  local group="$3"
  local perms="$4"
  sudo chown -R "$owner:$group" "$dir"
  sudo chmod -R "$perms" "$dir"
}

# mount_nvme_disk MOUNT_POINT [VOLUME_ID]
#   1 arg  -> mount the ephemeral instance-store disk (first NVMe disk with no
#            filesystem) as scratch; if none exists, warn and return 0.
#   2 args -> mount the EBS volume whose NVMe serial matches VOLUME_ID; a miss
#            is an error (the caller created that volume).
mount_nvme_disk() {
  local mount_point="$1"
  local volume_id="${2:-}"

  if [[ -z "${volume_id}" ]]; then
      # Ephemeral instance-store disk: first NVMe disk with no file system.
      for disk in $(lsblk -dpn -o NAME | grep '^/dev/nvme'); do
          echo "Processing disk: ${disk}"
          if [[ $(sudo file -bs "${disk}") == 'data' ]]; then
              echo "Found instance-store disk ${disk} with no file system."
              sudo mkfs -t ext4 "${disk}"
              sudo mount "${disk}" "${mount_point}"
              return 0
          fi
          echo "Disk ${disk} already has a file system. Skipping."
      done
      # No instance-store disk (e.g. a non-'d'-type builder): stay on the root volume.
      echo "No ephemeral instance-store disk found; leaving ${mount_point} on the root volume."
      return 0
  fi

  # EBS volume: match the NVMe serial to the volume ID.
  local target_serial="${volume_id//-/}"
  for disk in $(lsblk -dpn -o NAME | grep '^/dev/nvme'); do
      echo "Processing disk: ${disk}"
      # Read the NVMe serial; fall back to sysfs if lsblk does not populate SERIAL.
      local serial
      serial=$(lsblk -dn -o SERIAL "${disk}" | tr -d '[:space:]')
      if [[ -z "${serial}" ]]; then
          serial=$(cat "/sys/block/$(basename "${disk}")/device/serial" 2>/dev/null | tr -d '[:space:]')
      fi
      if [[ "${serial}" == "${target_serial}"* ]]; then
          echo "Found EBS volume ${volume_id} at ${disk} (serial ${serial})."
          sudo mkfs -t ext4 "${disk}"
          sudo mount "${disk}" "${mount_point}"
          return 0
      fi
      echo "Disk ${disk} (serial ${serial}) is not volume ${volume_id}. Skipping."
  done
  echo "Unable to find the attached EBS volume ${volume_id}. Exiting..."
  exit 1
}

retrieve_artifacts() {
    # Given a Source URL and a Destination path, this function downloads the source
    # zip file to the destination folder, extracts it, and removes the zip file.
    local source_url="$1"
    local destination="$2"

    aws s3 cp "${source_url}" "${destination}/source.zip"
    unzip -q -o "${destination}/source.zip" -d "${destination}"
    sudo rm -f "${destination}/source.zip"
}

wait_for_volume_attachment() {
    # This function waits for the specified volume to be attached to the instance within the given timeout period.
    local region="$1"
    local volume_id="$2"
    local timeout_seconds=300

    echo "Waiting for volume $volume_id to attach..."
    start_time=$(date +%s)
    end_time=$((start_time + timeout_seconds))

    while [[ $(date +%s) -lt $end_time ]]; do
        attachment_state=$(aws ec2 describe-volumes --region "$region" --volume-ids "$volume_id" --query 'Volumes[0].Attachments[0].State' --output text)
        if [[ "$attachment_state" == "attached" ]]; then
            echo "Volume $volume_id successfully attached"
            return 0
        fi
        sleep 5
    done
    echo "Volume $volume_id failed to attach within $timeout_seconds seconds"
    return 1
}

mount_data_drive() {
    local mount_dir="$1"
    local device_name="$2"

    # Obtain a session token for IMDSv2
    TOKEN=$(curl -H "X-aws-ec2-metadata-token-ttl-seconds: 300" -s http://169.254.169.254/latest/api/token)

    # Retrieve instance metadata using IMDSv2
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
    AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)

    VOLUME_ID=$(aws ec2 create-volume --region $REGION --size 256 --volume-type gp3 --availability-zone $AVAILABILITY_ZONE --query 'VolumeId' --output text)

    # Wait for the volume to become available
    aws ec2 wait volume-available --region $REGION --volume-ids $VOLUME_ID

    # Attach the volume to the instance
    aws ec2 attach-volume --region $REGION --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device ${device_name}

    # Wait for the volume to attach
    if ! wait_for_volume_attachment "$REGION" "$VOLUME_ID"; then
        echo "Failed to attach volume. Exiting..."
        exit 1
    fi
    
    # Modify the volume's delete on termination attribute
    aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --region $REGION --block-device-mappings "[{\"DeviceName\": \"${device_name}\",\"Ebs\":{\"DeleteOnTermination\":true}}]"

    sudo mkdir -p "${mount_dir}"

    mount_nvme_disk "${mount_dir}" "${VOLUME_ID}"

    set_permissions "${mount_dir}" "ubuntu" "ubuntu" "755"
}

remove_data_drive() {
    local mount_dir="$1"
    local device_name="$2"

    # Obtain a session token for IMDSv2
    TOKEN=$(curl -H "X-aws-ec2-metadata-token-ttl-seconds: 300" -s http://169.254.169.254/latest/api/token)

    # Retrieve instance metadata using IMDSv2
    REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

    # Get the volume ID using the device ID
    VOLUME_ID=$(aws ec2 describe-volumes --filters "Name=attachment.device,Values=${device_name}" "Name=attachment.instance-id,Values=${INSTANCE_ID}" --query "Volumes[0].VolumeId" --output text)

    sudo umount $mount_dir
    # use aws cli to detach and delete the volume
    aws ec2 detach-volume --volume-id $VOLUME_ID
    aws ec2 wait volume-available --region $REGION --volume-ids $VOLUME_ID
    aws ec2 delete-volume --region $REGION --volume-id $VOLUME_ID
}

# Get the regex followed by /etc/fstab entries created by persist_mount_in_fstab
# method.
fstab_entry_regex() {
    local mount_point="$1"
    printf '^[[:space:]]*[^#[:space:]]+[[:space:]]+%s[[:space:]]+' "${mount_point}"
}

# Adds an /etc/fstab entry so the file system currently mounted at MOUNT_POINT
# is remounted automatically on subsequent boots. No-op if nothing is mounted
# at MOUNT_POINT.
persist_mount_in_fstab() {
    local mount_point="$1"

    # Only persist if a separate file system is actually mounted here (e.g. a
    # builder with no instance-store disk leaves this dir on the root volume).
    if ! mountpoint -q "${mount_point}"; then
        echo "Nothing mounted at ${mount_point}; skipping /etc/fstab entry."
        return 0
    fi

    # Drop any existing entry for this mount point before adding one
    # so re-running does not record the same mount point twice.
    if grep -Eq "$(fstab_entry_regex "${mount_point}")" /etc/fstab; then
        echo "Existing /etc/fstab entry found for ${mount_point}; replacing it."
        remove_mount_from_fstab "${mount_point}"
    fi

    local device uuid fstype
    device=$(findmnt -n -o SOURCE "${mount_point}")
    uuid=$(sudo blkid -s UUID -o value "${device}")
    fstype=$(findmnt -n -o FSTYPE "${mount_point}")

    echo "Persisting mount of ${device} (UUID=${uuid}) at ${mount_point} in /etc/fstab."
    echo "UUID=${uuid} ${mount_point} ${fstype} defaults,nofail,x-systemd.device-timeout=10 0 2" \
        | sudo tee -a /etc/fstab
}

# Removes the /etc/fstab entry added by persist_mount_in_fstab (matched by its
# mount point).
remove_mount_from_fstab() {
    local mount_point="$1"
    sudo sed -Ei "\|$(fstab_entry_regex "${mount_point}")|d" /etc/fstab
}
