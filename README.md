# homelab-doku

Dokumentation und Skriptsammlung für mein Homelab.

## Struktur

```
.
├── docs/                 Dokumentation
│   ├── README.md         Einstieg, Übersicht Server/IPs/Dienste, Netzdiagramm
│   └── netzwerk.md       Zugriff von außen: CGNAT, cloudflared, Tailscale, Hetzner-VPS
├── scripts/              Skripte für wiederkehrende Aufgaben
│   ├── README.md         Konventionen und Liste der Skripte
│   └── _vorlage.sh       Vorlage für neue Skripte
├── .env.example          Platzhalter für alle Geheimnisse und lokalen Werte
└── .gitignore            hält u. a. die echte .env aus dem Repo heraus
```

Einstieg: [docs/README.md](docs/README.md)

## Geheimnisse

Passwörter, API-Keys und Tokens gehören **nicht** ins Repo.

```bash
cp .env.example .env   # .env ist per .gitignore ausgeschlossen
$EDITOR .env           # echte Werte nur lokal eintragen
```

In der Doku stehen stattdessen Platzhalter wie `<CLOUDFLARE_TUNNEL_TOKEN>`.
