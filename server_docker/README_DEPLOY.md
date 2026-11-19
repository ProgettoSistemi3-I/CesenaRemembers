# Deployment dello stack Docker

Questo Compose gestisce esclusivamente i servizi backend di **Cesena Remembers**:

- `gateway`: Nginx, reverse proxy HTTPS sulla porta host `8000`.
- `quiz-server`: API FastAPI per `POST /api/generate-quiz`.
- `notifier-service`: microservizio Node.js per le notifiche FCM.

Nginx inoltra l'endpoint quiz a `quiz-server`; gli altri percorsi `/api/*` rispondono `404`. Il notifier non è esposto dal gateway. Nginx e quiz condividono soltanto la rete Docker dedicata `quiz-backend`; il notifier resta sulla rete Compose predefinita separata.

## Prerequisiti sul server

Prima dell'avvio devono essere già presenti, sul server e non nel repository:

- `quiz-service/.env` con la configurazione del provider LLM e del progetto Firebase;
- `quiz-service/firebase-auth-reader.json`;
- `notifier-service/serviceAccountKey.json`;
- `certs/server.crt` e `certs/server.key`.

Le credenziali e la chiave privata TLS non devono essere committate. I file delle credenziali vengono montati in sola lettura nei rispettivi container.

## Aggiornamento

Eseguire i comandi nella stessa directory del progetto Compose usata per il deployment:

```bash
cd /percorso/CesenaRemembers
git pull --ff-only
cd server_docker

# Controlla la configurazione risolta prima di modificare i container.
docker compose config

# Verifica la configurazione Nginx usando i mount del servizio, senza avviare
# una seconda istanza che pubblichi la porta 8000.
docker compose run --rm --no-deps gateway nginx -t

# Ricrea/aggiorna i servizi e rimuove gli eventuali container orfani
# appartenenti a questo progetto Compose (incluso il vecchio servizio UniKlas).
docker compose up -d --build --remove-orphans

# Verifiche dopo l'avvio.
docker compose exec -T gateway nginx -t
docker compose exec -T gateway wget -qO- http://quiz-server:8000/health
docker compose ps
docker compose logs --tail=100 gateway quiz-server notifier-service
```

Il comando `up --remove-orphans` è quello da usare per eliminare il vecchio servizio rimosso dal file Compose. Non usare `docker compose down -v`: non serve per questa modifica e può eliminare volumi del progetto.

## Controllo e rimozione manuale di residui UniKlas

Dopo l'aggiornamento, verificare che non restino container con quel nome:

```bash
docker ps -a --filter name=uniklas-backend
```

Normalmente il container viene già rimosso da `docker compose up -d --remove-orphans`. Se esiste ancora, prima controllare che sia davvero il vecchio servizio del progetto:

```bash
docker inspect uniklas-backend --format 'project={{index .Config.Labels "com.docker.compose.project"}} service={{index .Config.Labels "com.docker.compose.service"}}'
```

Solo dopo aver verificato che si tratta del vecchio container UniKlas, rimuoverlo:

```bash
docker rm -f uniklas-backend
```

Per individuare l'eventuale immagine rimasta:

```bash
docker image ls --format 'table {{.Repository}}\\t{{.Tag}}\\t{{.ID}}' | grep -i uniklas
```

L'immagine è opzionale da eliminare: prima verificare che nessun container la stia usando, quindi rimuovere soltanto l'ID effettivamente riconosciuto come immagine legacy:

```bash
docker image rm <IMAGE_ID>
```

Non eseguire `docker system prune -a`, `docker volume prune` o cancellazioni generalizzate: non sono necessarie per rimuovere UniKlas e potrebbero coinvolgere risorse di altri servizi.

## Servizi attesi

```bash
docker compose ps
```

Per questo progetto devono risultare i servizi `gateway`, `quiz-server` e `notifier-service`. La porta host `8000` deve essere pubblicata soltanto dal gateway Nginx; la porta Uvicorn `8000` del container quiz resta esposta esclusivamente sulla rete Docker interna.
