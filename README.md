# netscan

Interactive Bash menu around nmap and nbtscan for network discovery and analysis.

> **Legal notice:** only scan networks you own or have explicit written
> permission to test. The full and vulnerability scans are intrusive.

## Requirements
- Linux with bash, run as root
- `nmap`, `xsltproc`
- `nbtscan` (optional, only for the NetBIOS scan)

On Debian/Kali: `sudo apt install nmap xsltproc nbtscan`

## Usage
```bash
chmod +x netscan.sh
sudo ./netscan.sh
```
Enter a network in CIDR notation (e.g. `192.168.1.0/24`), then pick a scan.

| Option | Scan | Notes |
|---|---|---|
| 1 | Host discovery | Ping scan, fast |
| 2 | Standard scan | Service versions + OS detection, top 1000 ports |
| 3 | Full scan | All ports, `-A`, slow |
| 4 | Vulnerability scan | nmap `vuln` scripts, intrusive and slow |
| 5 | NetBIOS name scan | Only finds Windows/Samba hosts |

## Output
Each scan creates a timestamped folder with `.txt` and `.xml` results and,
when possible, an `.html` report.