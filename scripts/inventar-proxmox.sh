#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Name:     inventar-proxmox.sh
# Zweck:    Listet alle LXC-Container und VMs eines Proxmox-Hosts als
#           Markdown-Tabelle (ID, Name, Status, IP, Ressourcen) – zum
#           Einfügen in docs/README.md. Ändert nichts am System.
# Aufruf:   ./inventar-proxmox.sh [-d|--dienste] [-h|--help]
# Läuft auf: Proxmox-Host (server-mry, server-sds) als root
# Benötigt: pct, qm (Proxmox VE)
# -----------------------------------------------------------------------------
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
DIENSTE=0

usage() {
    cat <<EOF
Aufruf: $SCRIPT_NAME [Optionen]

Gibt eine Inventar-Tabelle aller LXC-Container und VMs dieses Hosts aus.
Liest nur Konfigurationen, ändert nichts.

Optionen:
  -d, --dienste   In laufenden Containern zusätzlich nach Docker-Containern,
                  cloudflared und tailscaled schauen (per 'pct exec')
  -h, --help      Diese Hilfe anzeigen
EOF
}

die() { echo "FEHLER: $*" >&2; exit 1; }

while (( $# )); do
    case "$1" in
        -d|--dienste) DIENSTE=1 ;;
        -h|--help)    usage; exit 0 ;;
        *)            usage >&2; die "Unbekannte Option: $1" ;;
    esac
    shift
done

command -v pct >/dev/null || die "pct nicht gefunden – läuft das auf einem Proxmox-Host?"
(( EUID == 0 ))           || die "Bitte als root ausführen"

# Hinweis: 'pct exec' bekommt </dev/null, sonst liest es die Zeilen der
# while-Schleife mit und Container fehlen in der Ausgabe.

# Wert eines Schlüssels aus einer Proxmox-Konfiguration lesen (z. B. "memory")
cfg() { awk -F': ' -v k="$1" '$1 == k { print $2; exit }'; }

# IP aus net0 lesen; bei DHCP die tatsächliche IP im laufenden Container abfragen
lxc_ip() {
    local id="$1" conf="$2" status="$3" ip
    ip="$(cfg net0 <<<"$conf" | grep -o 'ip=[^,]*' | cut -d= -f2 || true)"
    if [[ "$ip" == "dhcp" && "$status" == "running" ]]; then
        ip="dhcp: $(pct exec "$id" -- hostname -I </dev/null 2>/dev/null | awk '{print $1}')"
    fi
    echo "${ip:--}"
}

# Dienste in einem laufenden Container erkennen (nur lesend)
lxc_dienste() {
    local id="$1"
    pct exec "$id" -- sh -c '
        out=""
        command -v docker >/dev/null 2>&1 &&
            out="docker: $(docker ps --format "{{.Names}}" 2>/dev/null | paste -sd, -)"
        for s in cloudflared tailscaled; do
            pgrep -x "$s" >/dev/null 2>&1 && out="$out $s"
        done
        echo "${out:--}"
    ' </dev/null 2>/dev/null || echo "?"
}

echo "## $(hostname) – Stand $(date +%F)"
echo
echo "### LXC-Container"
echo
if (( DIENSTE )); then
    echo "| ID | Name | Status | IP | Kerne | RAM (MB) | Autostart | Dienste |"
    echo "|----|------|--------|----|-------|----------|-----------|---------|"
else
    echo "| ID | Name | Status | IP | Kerne | RAM (MB) | Autostart |"
    echo "|----|------|--------|----|-------|----------|-----------|"
fi

# pct list: VMID Status [Lock] Name – Name ist immer die letzte Spalte
pct list | tail -n +2 | while read -r id status rest; do
    conf="$(pct config "$id")"
    name="$(cfg hostname <<<"$conf")"
    zeile="| $id | ${name:-${rest##* }} | $status | $(lxc_ip "$id" "$conf" "$status")"
    zeile+=" | $(cfg cores <<<"$conf") | $(cfg memory <<<"$conf") | $(cfg onboot <<<"$conf" | grep . || echo 0)"
    if (( DIENSTE )); then
        d="-"; [[ "$status" == "running" ]] && d="$(lxc_dienste "$id")"
        zeile+=" | $d"
    fi
    echo "$zeile |"
done

echo
echo "### VMs"
echo
echo "| ID | Name | Status | IP (cloud-init) | Kerne | RAM (MB) | Autostart |"
echo "|----|------|--------|-----------------|-------|----------|-----------|"

# qm list: VMID NAME STATUS MEM BOOTDISK PID
qm list | tail -n +2 | while read -r id name status _; do
    conf="$(qm config "$id")"
    ip="$(cfg ipconfig0 <<<"$conf" | grep -o 'ip=[^,]*' | cut -d= -f2 || true)"
    echo "| $id | $name | $status | ${ip:--} | $(cfg cores <<<"$conf") | $(cfg memory <<<"$conf") | $(cfg onboot <<<"$conf" | grep . || echo 0) |"
done
