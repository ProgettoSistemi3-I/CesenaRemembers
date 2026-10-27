# Usa un'immagine ufficiale di Python leggera come base
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Imposta la cartella di lavoro all'interno del container
WORKDIR /app

# Copia il file dei requisiti prima del resto del codice
# (cache di Docker: se i requisiti non cambiano, non reinstalla tutto).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia il codice e le schede storiche (facts/). I test e il file .env sono
# esclusi da .dockerignore; la chiave API arriva da env_file in docker-compose.
COPY . .

# Verifica in fase di build che tutte e dieci le schede esistano e siano
# leggibili: se ne manca una la build fallisce invece di scoprirlo in produzione.
RUN python -c "from pathlib import Path; import facts_loader as f; r=f.load_all(Path('facts')); bad=[k for k,v in r.items() if len(v.facts)<3]; assert not bad, bad; print({k: len(v.facts) for k,v in r.items()})"

# Esponi la porta su cui gira FastAPI
EXPOSE 8000

HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=4).status==200 else 1)"

# Comando per avviare il server quando il container parte
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
