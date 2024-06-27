#!/usr/bin/env bash

#=========================================================
# (Optional) Tweak, if needed
#=========================================================
TOTAL_CONFIGS=3 # Number of configurations to generate
DNS="1.1.1.1"   # DNS server to use
#=========================================================

if [ -z "${NORDVPN_ACCESS_TOKEN}" ]; then
  echo "Error: Environment variable NORDVPN_ACCESS_TOKEN is not set or empty. Please set it, then try again."
  exit 1
fi

CREDENTIALS_URL="https://api.nordvpn.com/v1/users/services/credentials"
SERVER_RECOMMENDATIONS_URL="https://api.nordvpn.com/v1/servers/recommendations?&filters\[servers_technologies\]\[identifier\]=wireguard_udp&limit=$TOTAL_CONFIGS"

# Fetch the private key
PRIVATE_KEY=$(curl -s -u token:"$NORDVPN_ACCESS_TOKEN" "$CREDENTIALS_URL" | jq -r .nordlynx_private_key)

# Ensure private key is fetched
if [[ "$PRIVATE_KEY" == "null" ]]; then
  echo "Error: Failed to fetch the private key. Verify the access token."
  exit 1
fi

# Fetch server recommendations and create WireGuard config files
curl -s "$SERVER_RECOMMENDATIONS_URL" | \
  jq -r --arg private_key "$PRIVATE_KEY" --arg dns "$DNS" '
    .[] |
    {
      filename: (.locations[0].country.name + " - " + .locations[0].country.city.name + " - " + .hostname + ".conf"),
      ip: .station,
      publicKey: (.technologies | .[] | select(.identifier == "wireguard_udp") | .metadata | .[] | .value)
    } |
    {
      filename: .filename,
      config: [
        "# " + .filename,
        "",
        "[Interface]",
        "PrivateKey = \($private_key)",
        "Address = 10.5.0.2/32",
        "DNS = \($dns)",
        "",
        "[Peer]",
        "PublicKey = " + .publicKey,
        "AllowedIPs = 0.0.0.0/0, ::/0",
        "Endpoint = " + .ip + ":51820"
      ] | join("\n")
    } |
    "echo \"" + .config + "\" > \"" + .filename + "\""
  ' | sh

# Find all conf files, sort them and display them
find . -name "*.conf" -type f | sort
