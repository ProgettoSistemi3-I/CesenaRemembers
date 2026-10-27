"""Schemi Pydantic.

- PoiRequest / QuizResponse: contratto HTTP con l'app Flutter. I campi
  esistenti (question, options, correctIndex) sono invariati; `evidence`,
  `factIds` e `meta` sono campi aggiuntivi che QuizQuestion.fromJson in Dart
  ignora (legge solo question/options/correctIndex).
- LlmQuiz / LlmQuestion: struttura richiesta al modello, validata in modo
  rigoroso (tipi stretti, conteggi esatti) prima dei controlli storici.
"""

from __future__ import annotations

from typing import List, Literal

from pydantic import BaseModel, ConfigDict, Field, StrictInt, StrictStr, field_validator


# --------------------------------------------------------------------------
# Contratto HTTP con Flutter (lib/data/quiz_repository_impl.dart)
# --------------------------------------------------------------------------
class PoiRequest(BaseModel):
    id: str = Field(max_length=64)
    name: str = Field(default="", max_length=200)
    # Ricevuta per compatibilità ma NON usata come fonte di fatti: le
    # descrizioni ARB contengono affermazioni non verificate.
    description: str = Field(default="", max_length=4000)
    userXp: int
    languageCode: Literal["it", "en"] = "it"


class QuizQuestionOut(BaseModel):
    question: str
    options: List[str]
    correctIndex: int
    # Frase (o frasi, separate da " | ") copiata esattamente dalla scheda.
    evidence: str
    factIds: List[str]


class QuizMeta(BaseModel):
    poiId: str
    language: str
    difficultyLevel: int
    model: str
    generatedAt: str


class QuizResponse(BaseModel):
    questions: List[QuizQuestionOut]
    meta: QuizMeta


# --------------------------------------------------------------------------
# Output atteso dal modello
# --------------------------------------------------------------------------
class LlmQuestion(BaseModel):
    model_config = ConfigDict(extra="ignore")

    question: StrictStr = Field(min_length=10, max_length=400)
    options: List[StrictStr]
    correctIndex: StrictInt
    factIds: List[StrictStr] = Field(min_length=1, max_length=2)
    evidence: List[StrictStr] = Field(min_length=1, max_length=2)

    @field_validator("options")
    @classmethod
    def _options_non_empty(cls, v: List[str]) -> List[str]:
        if any(not o.strip() or len(o) > 200 for o in v):
            raise ValueError("opzione vuota o troppo lunga")
        return v


class LlmQuiz(BaseModel):
    model_config = ConfigDict(extra="ignore")

    questions: List[LlmQuestion]
