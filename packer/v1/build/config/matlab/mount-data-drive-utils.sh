# Copyright 2025 The MathWorks, Inc.

# Function to set permissions
set_permissions() {
  local dir="$1"
  local owner="$2"
  local group="$3"
  local perms="$4"
  sudo chown -R "$owner:$group" "$dir"
  sudo chmod -R "$perms" "$dir"
}

# Function to find an NVMe disk with no file system
mount_nvme_disk() {
  local mount_point="$1"
  # Nitro-based instances expose EBS volumes as NVMe block devices.
  # Recommended way to identify newly attached volumes is to check for
  # disks with no file systems mounted as /dev/nvmeXnX.
  # See: https://docs.aws.amazon.com/ebs/latest/userguide/ebs-using-volumes.html
  for disk in $(lsblk -dpn -o NAME | grep '^/dev/nvme'); do
      echo "Processing disk: ${disk}"
      if [[ $(sudo file -bs "${disk}") == 'data' ]]; then
          echo "Found disk ${disk} with no file system."
          echo "$disk"
          sudo mkfs -t ext4 $disk
          sudo mount $disk $mount_point
          return
      fi
      echo "Disk ${disk} already has a file system. Skipping."
  done
  echo "Found no additional disk attached to the instance. Exiting..." 
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

    # Create a volume from the snapshot
    VOLUME_ID=$(aws ec2 create-volume --region $REGION --size 128 --volume-type gp3 --availability-zone $AVAILABILITY_ZONE --query 'VolumeId' --output text)

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

    mount_nvme_disk "${mount_dir}"

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
