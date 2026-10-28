FROM node:22-alpine

# Imposta la directory di lavoro
WORKDIR /usr/src/app

# Copia i file per l'installazione delle dipendenze
COPY package*.json ./

# Installa le dipendenze
RUN npm install --omit=dev

# Copia il codice sorgente
COPY . .

# Esegui il processo senza privilegi di root.
USER node

# Comando per avviare il servizio
CMD [ "npm", "start" ]
