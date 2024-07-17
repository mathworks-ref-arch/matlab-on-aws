# Copyright 2024 The MathWorks, Inc.

import os
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
import datetime

if __name__ == "__main__":
    # Get the directory path of the script
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Generate a private key
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )

    # Create a self-signed certificate
    subject = issuer = x509.Name([
        x509.NameAttribute(x509.oid.NameOID.COUNTRY_NAME, u"US"),
        x509.NameAttribute(x509.oid.NameOID.STATE_OR_PROVINCE_NAME, u"Massachusetts"),
        x509.NameAttribute(x509.oid.NameOID.LOCALITY_NAME, u"Natick"),
        x509.NameAttribute(x509.oid.NameOID.ORGANIZATION_NAME, u"MathWorks"),
        x509.NameAttribute(x509.oid.NameOID.COMMON_NAME, u"mathworks.com"),
    ])

    cert = x509.CertificateBuilder().subject_name(
        subject
    ).issuer_name(
        issuer
    ).public_key(
        private_key.public_key()
    ).serial_number(
        x509.random_serial_number()
    ).not_valid_before(
        datetime.datetime.utcnow()
    ).not_valid_after(
        datetime.datetime.utcnow() + datetime.timedelta(days=365)
    ).sign(private_key, hashes.SHA256(), default_backend())

    # Save the private key and certificate to files in the script directory
    private_key_path = os.path.join(script_dir, "private_key.pem")
    certificate_path = os.path.join(script_dir, "certificate.pem")

    with open(private_key_path, "wb") as f:
        f.write(private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ))

    with open(certificate_path, "wb") as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))

    # Print the paths of the generated files
    print("Private key saved to:", private_key_path)
    print("Certificate saved to:", certificate_path)
