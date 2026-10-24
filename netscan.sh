#!/bin/bash

show_banner() {
    echo ""
    echo -e "\033[1;36m"
    echo "################################################################################"
    echo "#                                                                              #"
    echo "#       ███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗         #"
    echo "#       ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝         #"
    echo "#       ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝          #"
    echo "#       ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗          #"
    echo "#       ██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗         #"
    echo "#       ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝         #"
    echo "#                                                                              #"
    echo "#        ███████╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗███████╗██████╗           #"
    echo "#        ██╔════╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██╔════╝██╔══██╗          #"
    echo "#        ███████╗██║     ███████║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝          #"
    echo "#        ╚════██║██║     ██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗          #"
    echo "#        ███████║╚██████╗██║  ██║██║ ╚████║██║ ╚████║███████╗██║  ██║          #"
    echo "#        ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝          #"
    echo "#                                                                              #"
    echo "#  ┌─────────────────────────────────────────────────────────────────────────┐ #"
    echo "#  │                        Advanced Network Scanner                         │ #"
    echo "#  │                      Network Discovery & Analysis                       │ #"
    echo "#  └─────────────────────────────────────────────────────────────────────────┘ #"
    echo "#                                                                              #"
    echo "################################################################################"
    echo -e "\033[1;33m"
    echo "  Author: SAHRAOUI YOUNES | v1.0"
	echo "  Only scan networks you own or have written permission to test."
    echo -e "\033[0m"
    echo ""
}

report() {
	case $1 in
		0)	echo "[DONE] $2 done successfully" ;;
		*)	echo "[ERROR] $2 failed (exit code: $1)" ;;
	esac
}

convert_html() {
	if [ ! -s "$1" ]; then
		echo "[WARNING] No XML to convert, skipping HTML"
		return
	fi
	echo "[+] Converting to HTML..."
	xsltproc "$1" -o "$2"
	report $? "HTML conversion"
}

fix_owner() {
	chown -R "${SUDO_USER:-root}": "$1"
}

CURRENT_DIR=""

cleanup() {
	echo ""
	echo "[!] Interrupted."
	if [ -n "$CURRENT_DIR" ]; then
		fix_owner "$CURRENT_DIR"
	fi
	exit 130
}

#HOST DISCOVERY
host_discovery(){
	echo "================HOST DISCOVERY================"

	local TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
	mkdir -p "host-discovery_$TIMESTAMP"
	CURRENT_DIR="host-discovery_$TIMESTAMP"

	echo "[+] Discovering hosts..."
	nmap -sn "$NETWORK" -oN ./"host-discovery_$TIMESTAMP"/host-discovery.txt -oX ./"host-discovery_$TIMESTAMP"/host-discovery.xml
	report $? "Host discovery"

	convert_html "host-discovery_$TIMESTAMP/host-discovery.xml" "host-discovery_$TIMESTAMP/host-discovery.html"

	fix_owner "host-discovery_$TIMESTAMP"
	CURRENT_DIR=""

	echo "================================================="
}

#STANDARD SCAN
standard_scan(){
	echo "================STANDARD SCAN================="

	local TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
	mkdir -p "standard-scan_$TIMESTAMP"
	CURRENT_DIR="standard-scan_$TIMESTAMP"

	echo "[+] Scanning and extracting..."
	nmap --stats-every 1m -sV -O -T4 "$NETWORK" -oN ./"standard-scan_$TIMESTAMP"/standard-scan.txt -oX ./"standard-scan_$TIMESTAMP"/standard-scan.xml
	report $? "Standard scan"

	convert_html "standard-scan_$TIMESTAMP/standard-scan.xml" "standard-scan_$TIMESTAMP/standard-scan.html"

	fix_owner "standard-scan_$TIMESTAMP"
	CURRENT_DIR=""

	echo "================================================="
}

#PORT-OS-SERVICE SCAN
port_os_service_scan(){
	echo "==============PORT-OS-SERVICE SCAN============="

	local TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
	mkdir -p "port-os-service-scan_$TIMESTAMP"
	CURRENT_DIR="port-os-service-scan_$TIMESTAMP"

	echo "[+] Scanning and extracting..."
	nmap --stats-every 5m -A -T4 -p- "$NETWORK" -oN ./"port-os-service-scan_$TIMESTAMP"/PortOsService-scan.txt -oX ./"port-os-service-scan_$TIMESTAMP"/PortOsService-scan.xml
	report $? "Port/OS/service scan"

	convert_html "port-os-service-scan_$TIMESTAMP/PortOsService-scan.xml" "port-os-service-scan_$TIMESTAMP/PortOsService-scan.html"

	fix_owner "port-os-service-scan_$TIMESTAMP"
	CURRENT_DIR=""

	echo "================================================="
}

#VULNERABILITY SCAN
vuln_scan(){
	echo "===============VULNERABILITY SCAN==============="

	local TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
	mkdir -p "vuln-scan_$TIMESTAMP"
	CURRENT_DIR="vuln-scan_$TIMESTAMP"

	echo "[+] Scanning and extracting..."
	nmap --stats-every 5m --script vuln -T4 "$NETWORK" -oN ./"vuln-scan_$TIMESTAMP"/vuln-scan.txt -oX ./"vuln-scan_$TIMESTAMP"/vuln-scan.xml
	report $? "Vulnerability scan"

	convert_html "vuln-scan_$TIMESTAMP/vuln-scan.xml" "vuln-scan_$TIMESTAMP/vuln-scan.html"

	fix_owner "vuln-scan_$TIMESTAMP"
	CURRENT_DIR=""

	echo "================================================="
}

#HOST-NAME SCAN
host_name_scan(){
	echo "=================HOST NAME SCAN================="

	local TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
	mkdir -p "host-name-scan_$TIMESTAMP"
	CURRENT_DIR="host-name-scan_$TIMESTAMP"

	echo "[+] Scanning and extracting..."
	nbtscan "$NETWORK" > ./"host-name-scan_$TIMESTAMP"/host.txt
	report $? "Host name scan"

	fix_owner "host-name-scan_$TIMESTAMP"
	CURRENT_DIR=""

	echo "================================================="
}

#MAIN FUNCTION
main_function(){
	local OPTION
	echo -e "\033[1;36m[ MENU ]\033[0m"
	echo "1. Host Discovery"
	echo "2. Standard Scan (services + OS)"
	echo "3. Full Scan (all ports, slow)"
	echo "4. Vulnerability Scan (intrusive, slow)"
	echo "5. NetBIOS Name Scan (Windows/Samba hosts only)"
	echo "6. Quit"
	read -r -p "Select an option: " OPTION

	case "$OPTION" in
		1) host_discovery ;;
		2) standard_scan ;;
		3) port_os_service_scan ;;
		4) vuln_scan ;;
		5) host_name_scan ;;
		6) exit ;;
		*) echo "Invalid option" ;;
	esac
}

#==============RUN==============
if [ "$EUID" -ne 0 ]; then
	echo "[ERROR] This script must be run as root: sudo $0"
	exit 1
fi

trap cleanup INT TERM

show_banner

declare NETWORK
while true; do
	read -p "Enter your IPv4 network subnet (eg: 192.168.1.0/24) " NETWORK
	if [[ "$NETWORK" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
		break
	fi
	echo "[ERROR] Invalid format. Use CIDR notation."
done

while true; do
	main_function
done
