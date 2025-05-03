#!/bin/bash

clientName=${1}
adminDir=/home/admin
serverDir="$adminDir/easy-rsa-server"
caDir="$adminDir/easy-rsa"

# 0. Ask for delete client if exists
bash delClient.sh $clientName

# 1. Generate request
cd "$serverDir" || exit 1
./easyrsa gen-req "$clientName" nopass
sudo cp "$serverDir/pki/private/$clientName.key" "$adminDir/client-configs/keys/"

# 2. Import request
cd "$caDir" || exit 1
sudo ./easyrsa import-req "$serverDir/pki/reqs/$clientName.req" $clientName

# 3. Sign cert
sudo ./easyrsa sign-req client $clientName

# 4. Copy cert
sudo cp "$caDir/pki/issued/$clientName.crt" "$adminDir/client-configs/keys/"

sudo chown -R admin:admin $adminDir/client-configs

# 5. Create opvn client config
cd "$adminDir/client-configs"
bash "$adminDir/client-configs/make_config.sh" $clientName

echo "Config file was created in:"
echo "$adminDir/client-configs/files/$clientName.ovpn"
