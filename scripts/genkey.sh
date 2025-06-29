#!/bin/bash
set -euo pipefail

# Configurable variables
NAME="Shanyu Juneja"
EMAIL="shanyujuneja@gmail.com"
KEY_TYPE="RSA"
KEY_LENGTH="4096"
EXPIRE_DATE="1y"
PASSPHRASE="${1:-}"

# Generate batch config for GPG
cat > gen-key.conf <<EOF
%echo Generating GPG key
Key-Type: ${KEY_TYPE}
Key-Length: ${KEY_LENGTH}
Name-Real: ${NAME}
Name-Email: ${EMAIL}
Expire-Date: ${EXPIRE_DATE}
EOF

if [[ -z "$PASSPHRASE" ]]; then
    echo "No passphrase"
    exit 1
else
    echo "Passphrase: ${PASSPHRASE}" >> gen-key.conf
fi

echo "%commit" >> gen-key.conf
echo "%echo Done" >> gen-key.conf

echo "[INFO] Generating GPG key..."
gpg --batch --gen-key gen-key.conf

# Extract key ID
GPG_KEY_ID=$(gpg --list-secret-keys --with-colons | awk -F: '/^sec/ {print $5; exit}')

if [[ -z "$GPG_KEY_ID" ]]; then
    echo "[ERROR] Failed to extract generated GPG key ID"
    exit 1
fi

# Export private key in ASCII-armored form
echo "[INFO] Exporting private key..."
if [[ -z "$PASSPHRASE" ]]; then
    gpg --armor --export-secret-keys "$GPG_KEY_ID"
else
    # Use --pinentry-mode loopback for scripted passphrase export
    echo "$PASSPHRASE" | gpg --pinentry-mode loopback --passphrase-fd 0 --armor --export-secret-keys "$GPG_KEY_ID"
fi

# Cleanup
rm -f gen-key.conf
