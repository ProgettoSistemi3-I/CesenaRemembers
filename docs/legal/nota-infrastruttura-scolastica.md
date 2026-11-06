# Nota interna sull'infrastruttura scolastica
**Progetto:** Cesena Remembers  
**Versione:** 1.0 – 6 novembre 2026  
**Natura:** registrazione interna dell'assetto operativo dichiarato dai gestori; non è un contratto sottoscritto dall'istituto e non nomina l'istituto come responsabile ex art. 28 GDPR.

## 1. Istituto e infrastruttura

L'infrastruttura è messa a disposizione dall'**Istituto Superiore Pascal - Comandini**, con sede in Piazzale Macrelli 100, 47521 Cesena (FC), C.F. 90076540401, tramite un Raspberry Pi dedicato al progetto e la connettività necessaria a rendere raggiungibile il servizio quiz.

L'istituto ha autorizzato l'utilizzo del dispositivo e della rete per ospitare il backend di Cesena Remembers. Secondo quanto dichiarato dai due gestori del progetto, l'autorizzazione consente loro di amministrare il server per il progetto come infrastruttura dedicata.

## 2. Assetto operativo dichiarato

Alla data di questa nota:
- il Raspberry Pi è dedicato a Cesena Remembers e non ospita altri servizi scolastici;
- le credenziali e l'accesso amministrativo al sistema operativo, ai container Docker, a Nginx, al backend quiz, al microservizio notifiche e ai relativi log applicativi sono in possesso e sotto il controllo operativo esclusivo di Lorenzo Ostolani e Luca Bazzocchi;
- il personale dell'istituto non dispone di account o credenziali per accedere a database, container, pannelli, log applicativi o segreti del progetto;
- l'istituto non configura né amministra i database o i servizi applicativi e non decide quali dati dell'app raccogliere, per quali finalità o per quanto tempo conservarli;
- l'istituto non esegue backup applicativi o operazioni di manutenzione sui dati per conto dei contitolari, secondo l'assetto operativo dichiarato;
- le decisioni e le attività applicative sono svolte congiuntamente dai due contitolari.

## 3. Qualificazione del ruolo dell'istituto

Sulla base dei fatti dichiarati nella sezione 2, l'istituto svolge una funzione di **messa a disposizione dell'infrastruttura fisica e della connettività**. Non determina le finalità o i mezzi essenziali dei trattamenti effettuati nell'app e non è incaricato di trattare i dati applicativi per conto dei contitolari.

In questo assetto, l'istituto **non viene nominato responsabile del trattamento ai sensi dell'art. 28 GDPR** per i dati contenuti nel backend e nei database dell'app. La sola proprietà del Raspberry Pi o la concessione dell'accesso alla rete non determina automaticamente la contitolarità o la qualità di responsabile: la qualificazione dipende dalle attività effettivamente svolte.

Eventuali dati tecnici che l'istituto raccolga autonomamente per amministrare e proteggere la propria rete (ad esempio log della rete scolastica) ricadono nelle finalità e nelle responsabilità dell'istituto stesso e non sono gestiti dai contitolari dell'app. Questa nota non afferma che tali log siano effettivamente raccolti né ne determina tempi e finalità.

## 4. Limiti e condizioni che comportano una nuova valutazione

Questa qualificazione si basa sulle informazioni rese dai gestori e deve essere aggiornata prima che cambi l'assetto. È necessaria una rivalutazione se l'istituto o personale da esso incaricato:
- ottiene credenziali o accesso ai container, database, file, log o backup applicativi;
- esegue backup, ripristini, aggiornamenti o manutenzione che comportino trattamento dei dati per conto dei contitolari;
- consulta o utilizza dati degli utenti per finalità proprie diverse dalla sicurezza della propria rete;
- decide finalità o mezzi del trattamento dell'app.

Se l'istituto inizia a trattare dati personali per conto dei contitolari, il trattamento deve essere disciplinato prima dell'accesso da un contratto o altro atto giuridico scritto conforme all'art. 28 GDPR. Se determina finalità proprie, deve essere valutato il suo ruolo di titolare autonomo o, quando le decisioni sono congiunte, di contitolare.

## 5. Trasparenza verso gli utenti

L'informativa privacy descrive l'istituto come soggetto che mette a disposizione il supporto infrastrutturale, specificando che l'amministrazione applicativa e l'accesso ordinario ai dati sono riservati ai due contitolari. Non lo presenta come responsabile ex art. 28 perché, in base all'assetto dichiarato, non è incaricato di trattare dati per conto dei contitolari.

## 6. Dichiarazione dei gestori

I sottoscritti dichiarano che la presente nota descrive l'assetto operativo che hanno comunicato per il progetto e si impegnano a mantenerla aggiornata in caso di variazioni.

**Lorenzo Ostolani** – Firma: ____________________  Data: __________

**Luca Bazzocchi** – Firma: ____________________  Data: __________

---

### Fonti istituzionali
- Sito dell'Istituto Superiore “Pascal-Comandini”: https://www.ispascalcomandini.it/pagine/la-storia
- GDPR, art. 28: https://eur-lex.europa.eu/legal-content/IT/TXT/?uri=CELEX:32016R0679
- EDPB, Guidelines 07/2020 on controller and processor: https://www.edpb.europa.eu/documents/guideline/guidelines-072020-on-the-concepts-of-controller-and-processor-in-the-gdpr_en
