"""Caricamento delle schede storiche (facts/<poi_id>.md).

Le schede vengono lette UNA volta all'avvio e tenute in memoria.
Dal file viene estratta soltanto la sezione "## Fatti verificati": le
sezioni con informazioni parziali, non verificate o discrepanze servono
alla revisione umana e non arrivano mai al modello.

Formato atteso di ogni fatto (vedi facts/README.md):

    ### ROC-01
    - Affermazione (IT): ...
    - Affermazione (EN): ...
    - Stato: verificato
    - Fonti: ...
    - Passaggio di riferimento: ...
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger("quiz.facts")

# Gli unici POI ammessi. Gli ID coincidono con quelli dell'app Flutter
# (lib/data/seeds/historic_places_seed.dart) e NON vanno rinominati.
KNOWN_POI_IDS: tuple[str, ...] = (
    "santa_cristina",
    "rocca",
    "san_rocco",
    "abbazia_monte",
    "osservanza",
    "palazzo_ridotto",
    "stazione",
    "arrigoni",
    "fantaguzzi",
    "rifugi_antiaerei",
)

_VERIFIED_SECTION = re.compile(
    r"^##\s+Fatti verificati\s*$(.*?)(?=^##\s|\Z)", re.MULTILINE | re.DOTALL
)
_FACT_BLOCK = re.compile(
    r"^###\s+([A-Z]{3}-\d{2})\s*$(.*?)(?=^###\s|\Z)", re.MULTILINE | re.DOTALL
)
_FIELD = re.compile(r"^-\s*([^:]+?):\s*(.+)$", re.MULTILINE)
_TITLE = re.compile(r"^#\s+(.+)$", re.MULTILINE)


@dataclass(frozen=True)
class Fact:
    id: str
    text_it: str
    text_en: str
    sources: str

    def text(self, lang: str) -> str:
        return self.text_en if lang == "en" else self.text_it


@dataclass
class PoiFacts:
    poi_id: str
    title: str
    facts: list[Fact] = field(default_factory=list)

    def by_id(self) -> dict[str, Fact]:
        return {f.id: f for f in self.facts}


class FactsError(RuntimeError):
    pass


def parse_facts_file(poi_id: str, content: str) -> PoiFacts:
    title_match = _TITLE.search(content)
    title = title_match.group(1).strip() if title_match else poi_id

    section = _VERIFIED_SECTION.search(content)
    if not section:
        raise FactsError(f"{poi_id}: sezione '## Fatti verificati' mancante")

    facts: list[Fact] = []
    seen: set[str] = set()
    for fact_id, body in _FACT_BLOCK.findall(section.group(1)):
        fields = {k.strip().lower(): v.strip() for k, v in _FIELD.findall(body)}
        status = fields.get("stato", "").lower()
        if status != "verificato":
            # Difesa in profondità: un fatto non verificato finito per errore
            # nella sezione sbagliata non viene comunque usato.
            logger.warning("%s: fatto %s ignorato (stato=%r)", poi_id, fact_id, status)
            continue
        text_it = fields.get("affermazione (it)", "")
        text_en = fields.get("affermazione (en)", "")
        if not text_it or not text_en:
            raise FactsError(f"{poi_id}: il fatto {fact_id} non ha entrambe le lingue")
        if fact_id in seen:
            raise FactsError(f"{poi_id}: ID di fatto duplicato {fact_id}")
        seen.add(fact_id)
        facts.append(
            Fact(id=fact_id, text_it=text_it, text_en=text_en, sources=fields.get("fonti", ""))
        )
    return PoiFacts(poi_id=poi_id, title=title, facts=facts)


def load_all(facts_dir: Path) -> dict[str, PoiFacts]:
    """Carica tutte le schede note. Un file mancante non blocca l'avvio:
    il POI risulterà senza fatti e la richiesta fallirà con errore esplicito
    (l'app userà il fallback locale)."""
    registry: dict[str, PoiFacts] = {}
    for poi_id in KNOWN_POI_IDS:
        # Il percorso è costruito SOLO da ID della whitelist, mai dall'input HTTP.
        path = facts_dir / f"{poi_id}.md"
        if not path.is_file():
            logger.error("Scheda mancante per %s: %s", poi_id, path)
            registry[poi_id] = PoiFacts(poi_id=poi_id, title=poi_id, facts=[])
            continue
        registry[poi_id] = parse_facts_file(poi_id, path.read_text(encoding="utf-8"))
        logger.info("Scheda %s: %d fatti verificati", poi_id, len(registry[poi_id].facts))
    return registry
