# karlsendev-web

Nettsted for **Karlsen Development** — statisk enkeltside servet av nginx i Docker.

```
karlsendev-web/
├── site/                 # alt innhold (index.html, robots.txt, sitemap.xml)
├── nginx/default.conf    # server-config: gzip, cache, sikkerhetsheadere, /healthz
├── Dockerfile
├── docker-compose.yml
└── .github/workflows/    # bygger og pusher image til GHCR ved push til main
```

## 1. Legg i GitHub

```bash
cd karlsendev-web
git init -b main
git add .
git commit -m "Første versjon av karlsendev.no"
git remote add origin git@github.com:<bruker>/karlsendev-web.git
git push -u origin main
```

## 2. Deploy på Docker-VM

```bash
cd /opt/stacks
git clone git@github.com:<bruker>/karlsendev-web.git karlsendev
cd karlsendev
docker compose up -d --build
curl -I http://localhost:8088/healthz
```

Oppdatering senere:

```bash
cd /opt/stacks/karlsendev && git pull && docker compose up -d --build
```

Er 8088 opptatt, endre venstre side av portmappingen i `docker-compose.yml`.

## 3. Publiser via Cloudflare Tunnel

**Kjører `cloudflared` i Docker på samme host:** avkommenter `cloudflared`-nettverket i
`docker-compose.yml` (både under `networks:` på tjenesten og nederst i fila), sett
navnet til det nettverket cloudflared faktisk ligger på (`docker network ls`), og bruk
container-navnet som service-URL:

```
karlsendev.no       →  http://karlsendev-web:80
www.karlsendev.no   →  http://karlsendev-web:80
```

**Kjører cloudflared et annet sted:** bruk `http://<vm-ip>:8088` i stedet.

I Cloudflare DNS: `karlsendev.no` og `www` som proxied CNAME til tunnel-UUID-et.
Sett SSL/TLS-modus til **Full** og slå på *Always Use HTTPS*.

> **Merk:** Ikke legg denne siden bak Cloudflare Access — den skal være åpen for
> kundene. Access hører hjemme på de interne tjenestene (Uptime Kuma, HA, Jellyfin).

Legg gjerne inn en monitor i Uptime Kuma mot `https://karlsendev.no/healthz`
(forventet svar: `ok`).

## 4. Før lansering — fyll inn dette

| Hvor | Hva |
|---|---|
| `site/index.html`, footer | `Org.nr. under registrering` → faktisk org.nr. når det kommer |
| `docker-compose.yml` | GHCR-image-navn hvis du vil bygge i CI i stedet for på VM-en |
| E-post | Vurder `post@karlsendev.no` med videresending, i stedet for Gmail-adressen |

Om du bytter til `post@karlsendev.no`: SPF-en din er i dag `v=spf1 -all` (ingen
sending). Skal domenet sende e-post, må SPF utvides og DKIM settes opp — ellers
havner det i søpla hos mottaker.

## 5. Fonter og GDPR

Siden laster Barlow Condensed og IBM Plex fra Google Fonts. Det innebærer at
besøkendes IP-adresse går til Google, noe som har vært omstridt i EØS. Vil du
være på trygg grunn, last ned fontene og server dem selv:

```bash
mkdir -p site/fonts    # legg woff2-filene her
```

…og bytt `<link href="https://fonts.googleapis.com/...">` i `index.html` med lokale
`@font-face`-regler. Da kan `fonts.googleapis.com` og `fonts.gstatic.com` også
fjernes fra CSP-en i `nginx/default.conf`.

## Innhold

Alt innhold ligger i `site/index.html`. Seksjonene er merket i markup-en:
hero, `#tjenester`, `#arbeid`, `#om`, `#kontakt`. Fargene styres av CSS-variablene
øverst i `<style>` — `--signal` er aksentfargen.
