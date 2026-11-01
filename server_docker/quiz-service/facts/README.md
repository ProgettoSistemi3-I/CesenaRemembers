# Archivio storico locale (schede dei POI)

Una scheda per POI, con nome file = ID usato dall'app Flutter (`rocca.md`, `stazione.md`...).
Il server carica le schede all'avvio e le tiene in memoria. Durante la generazione non fa ricerche online. Per ogni richiesta invia al modello un sottoinsieme casuale dei fatti verificati, fino al limite configurato da `FACTS_PER_PROMPT` (predefinito: 18). Con l'archivio attuale, il limite predefinito consente di inviare l'intera scheda di ogni POI.

## Cosa legge il server

Soltanto i blocchi `### ID` dentro la sezione `## Fatti verificati` con `- Stato: verificato`.
Tutte le altre sezioni non vengono mai inviate al modello:
- `## Fonti consultate`
- `## Informazioni parzialmente verificate o non verificate`
- `## Discrepanze tra fonti`
- `## Correzioni rispetto alle descrizioni attuali dell'app (ARB)`

## Allineamento con le descrizioni dell'app

- Ogni affermazione storica nelle descrizioni dei POI che si desidera rendere utilizzabile nei quiz deve avere un fatto corrispondente in questa sezione.
- Se una descrizione contiene un'informazione parziale o una datazione discordante, non copiarla tra i fatti verificati: riformulare la descrizione in modo prudente oppure lasciare la cautela nelle sezioni dedicate alle discrepanze.
- Non usare come fatto verificato una semplice interpretazione narrativa (per esempio "luogo strategico") senza indicare il rapporto concreto attestato dalla fonte.
- Il modello riceve il testo della sola lingua richiesta, non entrambe le traduzioni. Le due affermazioni devono comunque essere equivalenti.
- Il modello non riceve le sezioni sulle fonti, sulle informazioni parziali e sulle discrepanze: se un dettaglio deve poter fondare una domanda, va espresso in modo autonomo nella sezione dei fatti verificati.


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
