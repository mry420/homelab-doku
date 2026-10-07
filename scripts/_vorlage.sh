#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Name:     _vorlage.sh
# Zweck:    Vorlage für neue Skripte – kopieren, umbenennen, anpassen.
# Aufruf:   ./_vorlage.sh [-h|--help] [-n|--dry-run]
# Läuft auf: <HOST>
# Benötigt: bash >= 4
# Hinweis:  Geheimnisse kommen aus ../.env, nie aus dem Skript selbst.
# -----------------------------------------------------------------------------
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=0

usage() {
    cat <<EOF
Aufruf: $SCRIPT_NAME [Optionen]

Kurze Beschreibung, was das Skript tut.

Optionen:
  -n, --dry-run   Nur anzeigen, was passieren würde
  -h, --help      Diese Hilfe anzeigen
EOF
}

# Meldungen mit Zeitstempel auf stderr
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >&2; }
die() { log "FEHLER: $*"; exit 1; }

# Führt einen Befehl aus – oder zeigt ihn im Dry-Run nur an
run() {
    if (( DRY_RUN )); then log "DRY-RUN: $*"; else "$@"; fi
}

# Optional: .env laden, falls das Skript Geheimnisse braucht
load_env() {
    local env_file="$SCRIPT_DIR/../.env"
    [[ -f "$env_file" ]] || die ".env fehlt – siehe .env.example"
    set -a; source "$env_file"; set +a
}

# --- Argumente ----------------------------------------------------------------
while (( $# )); do
    case "$1" in
        -n|--dry-run) DRY_RUN=1 ;;
        -h|--help)    usage; exit 0 ;;
        *)            usage >&2; die "Unbekannte Option: $1" ;;
    esac
    shift
done

# --- Hauptteil ----------------------------------------------------------------
log "Start"
run echo "Hier passiert die eigentliche Arbeit"
log "Fertig"
