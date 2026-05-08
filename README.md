# GE.M.MA (GEstione Multiutente MAteriale di consumo)

GE.M.MA è un applicativo per la gestione del
materiale di consumo all'interno di Strutture Multi Dipartimentali.

## Sviluppo locale con Docker Compose

Questa configurazione è pensata per sviluppo locale:

- usa il target Docker `development`
- avvia `./bin/dev` per Rails, JavaScript e CSS in watch mode

Creazione container:

```bash
docker compose -f compose.yaml -f compose.dev.yaml build
```

Avvio del database e preparazione e popolamento del database demo:

```bash
docker compose -f compose.yaml -f compose.dev.yaml up -d db
docker compose -f compose.yaml -f compose.dev.yaml run --rm web bin/rails db:prepare
```

Avvio dell'ambiente di sviluppo:

```bash
docker compose -f compose.yaml -f compose.dev.yaml up web
```

L'applicazione sarà disponibile su [http://127.0.0.1:3000/home](http://127.0.0.1:3000/home).

## Demo locale con Docker Compose

Questa configurazione è separata da quella di sviluppo:

- usa file di configurazione demo dedicati
- usa il target Docker `production`
- avvia Rails con `RAILS_ENV=production`

Creazione immagine demo:

```bash
docker compose -f compose.yaml -f demo/compose.demo.yaml build web
```

Avvio del database demo e preparazione e popolamento del database demo:

```bash
docker compose -f compose.yaml -f demo/compose.demo.yaml up -d db
docker compose -f compose.yaml -f demo/compose.demo.yaml run --rm web bin/rails db:prepare
docker compose -f compose.yaml -f demo/compose.demo.yaml run --rm web bin/rails db:setup_demo
```

Avvio del server demo:

```bash
docker compose -f compose.yaml -f demo/compose.demo.yaml up web
```

Connettersi quindi a [http://127.0.0.1:3000/home](http://127.0.0.1:3000/home) e
loggarsi con:

- `admin.user@example.com` per essere amministratore delle strutture demo
- `simple.user@example.com` per un utente base con permessi limitati

## Note

- `compose.yaml` contiene i servizi condivisi.
- `compose.dev.yaml` aggiunge bind mounts e `./bin/dev`.
- `compose.demo.yaml` applica le personalizzazioni per il demo locale in ambiente production.
