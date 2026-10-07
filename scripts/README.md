# Skripte

Skripte für wiederkehrende Aufgaben im Homelab.

## Konventionen

- Bash, `#!/usr/bin/env bash`, immer `set -euo pipefail`
- Kopfkommentar: Name, Zweck, Aufruf, Host, Abhängigkeiten
- `-h|--help` zeigt die Hilfe, wo sinnvoll `-n|--dry-run`
- Kommentare und Meldungen auf Deutsch, kurz gehalten
- Geheimnisse nur aus `../.env` laden (siehe `.env.example`), nie im Skript
- Neue Skripte aus [`_vorlage.sh`](_vorlage.sh) erstellen und hier eintragen
- Vor dem Commit prüfen: `bash -n skript.sh` und, falls installiert, `shellcheck skript.sh`

## Übersicht

| Skript          | Zweck                       | Läuft auf |
|-----------------|-----------------------------|-----------|
| `_vorlage.sh`   | Vorlage für neue Skripte    | –         |
| `inventar-proxmox.sh` | Inventar aller LXC/VMs als Markdown-Tabelle (nur lesend) | Proxmox-Host |
