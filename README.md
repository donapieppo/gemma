# GE.M.MA (GEstione Multiutente MAteriale di consumo) 

GE.M.MA è un applicativo per la gestione del
materiale di consumo all'interno di Strutture Multi Dipartimentali.

## Demo locale con Docker Compose

Questa sezione descrive come provare l'applicativo via Docker Compose. 

Per preparare il db e configurare l'applicazione:

```bash
# build
docker compose -f compose_demo.yaml build
# start del database
docker compose -f compose_demo.yaml up -d db
# preparazione del database
docker compose -f compose_demo.yaml run --rm web bin/rails db:prepare
# aggiunta al database dati iniziali del demo
docker compose -f compose_demo.yaml run --rm web bin/rails db:setup_demo 
```

Per far partire il server:

```bash
docker compose -f compose_demo.yaml up web
```

Connettersi quindi a `(http://127.0.0.1:3000/home)[http://127.0.0.1:3000/home]` e 
loggarsi con utente `admin.user@example.com` (senza password)
per essere un amministratore della struttura di prova 1.
