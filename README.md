# NordVPN WireGuard Exporter

Shell script to easily export WireGuard configuration from NordVPN.

For further details, please refer to [this blog post](https://myshittycode.com/2024/06/08/nordvpn-extracting-wireguard-configuration/).

## Usage

- Generate your [NordVPN access token](https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/).
- Run the script.

```bash
export NORDVPN_ACCESS_TOKEN="[YOUR_NORDVPN_ACCESS_TOKEN]"

./nordvpn-wireguard-exporter.sh
```
