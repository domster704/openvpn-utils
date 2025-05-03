#!/bin/bash

clientName=${1}
adminDir=/home/admin
caDir="$adminDir/easy-rsa/"

# Search for files matching the client name
matches=$(sudo find ~ -name "${clientName}*")

if [[ -n "$matches" ]]; then
    echo "The following files were found:"
    echo "$matches"
    echo

    read -p "Are you sure you want to delete these files? [y/N]: " confirm

    if [[ "${confirm,,}" == "y" ]]; then

        cd $caDir || exit 1
        sudo bash ./easyrsa revoke $clientName
        sudo bash ./easyrsa gen-crl

        sudo cp $adminDir/easy-rsa/pki/crl.pem /etc/openvpn/server/

        echo "Deleting..."
        sudo find ~ -name "${clientName}*" -exec rm -f {} \;
        echo "Files deleted successfully."

        sudo systemctl restart openvpn-server@server.service
    else
        echo "Deletion cancelled."
    fi
else
    echo "No files found matching '${clientName}*'. Nothing to delete."
fi
