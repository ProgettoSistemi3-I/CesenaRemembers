# Archivio storico locale (schede dei POI)

Una scheda per POI, con nome file = ID usato dall'app Flutter (`rocca.md`, `stazione.md`...).
Il server carica le schede all'avvio e le tiene in memoria. Durante la generazione non fa ricerche online.

## Cosa legge il server

Soltanto i blocchi `### ID` dentro la sezione `## Fatti verificati` con `- Stato: verificato`.
Tutte le altre sezioni non vengono mai inviate al modello:
- `## Fonti consultate`
- `## Informazioni parzialmente verificate o non verificate`
- `## Discrepanze tra fonti`
- `## Correzioni rispetto alle descrizioni attuali dell'app (ARB)`

## Formato di un fatto

```
### ROC-01
- Affermazione (IT): frase singola, autonoma, verificata.
- Affermazione (EN): stessa frase in inglese, senza aggiungere o togliere nulla.
- Stato: verificato
- Fonti: [S1], [S3]
- Passaggio di riferimento: citazione breve o sezione della fonte che sostiene la frase
```

Regole:
- ID stabile e univoco (`XXX-NN`). Non rinumerare i fatti esistenti: gli ID compaiono nei log e nelle risposte (`factIds`).
- Una sola informazione verificabile per fatto. Non unire fatti sostenuti da fonti diverse.
- Il testo IT/EN è quello che il modello deve copiare alla lettera nel campo `evidence`. Va quindi scritto come frase completa.
- Date, numeri e nomi propri presenti nel fatto sono gli unici che il validatore accetta nella domanda e nella risposta corretta.
- Un'informazione con una sola fonte debole, o con fonti discordanti, va nella sezione "parzialmente verificate", non tra i fatti verificati.
- Servono almeno 3 fatti verificati per POI: con meno di 3 il server risponde con un errore e l'app usa il quiz locale. La build Docker fallisce se una scheda ne ha meno di 3.

## Aggiornare una scheda

1. Modificare il file `.md`.
2. Eseguire i test: `python -m pytest -q tests` dalla cartella `quiz-service`.
3. Ricostruire e riavviare il container (vedi `../README_DEPLOY.md`).
