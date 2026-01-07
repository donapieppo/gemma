# GE.M.MA (GEstione Multiutente MAteriale di consumo) 

GE.M.MA è un applicativo per la gestione del
materiale di consumo all'interno di Strutture Multi Dipartimentali.

## Demo locale con Docker Compose

Questa sezione descrive un flusso base per provare l'applicativo via Docker
Compose. 

Per preparare il db e configurare l'applicazione: 

```bash
docker compose -f compose_demo.yaml build
docker compose -f compose_demo.yaml up -d db
docker compose -f compose_demo.yaml run --rm web bin/rails db:prepare
docker compose -f compose_demo.yaml run --rm web bin/rails db:setup_demo 
```

Per far partire il server:

```bash
docker compose -f compose_demo.yaml up web
```

Quindi loggarsi con utente `admin.user@example.com` per essere un amministratore della struttura di prova 1
