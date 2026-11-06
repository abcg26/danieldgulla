import re
from pathlib import Path

import joblib
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field


MODEL_PATH = Path(__file__).with_name("kp_model.joblib")
BUNDLE = joblib.load(MODEL_PATH)
MODELS = BUNDLE["models"]
PLACES = BUNDLE["PLACES"]
OFFICIAL = BUNDLE["OFFICIAL"]
WEAPON = BUNDLE["WEAPON"]
OVERSEAS = BUNDLE["OVERSEAS"]
TARGETS = ["dispute_category", "urgency_score", "exclusion"]
SERIOUS_VIOLENCE = re.compile(
    r"\b(?:"
    r"stab(?:bed|bing)?|sinaksak|saksak|gunshot|"
    r"shot\s+(?:dead|him|her|them)|"
    r"(?:lethal|fatal)\s+(?:stabbing|attack|injur\w*|wound\w*)|"
    r"life[- ]threatening\s+(?:stabbing|attack|injur\w*|wound\w*)"
    r")\b",
    re.IGNORECASE,
)

app = FastAPI(title="DANIELDGULLA Triage API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class Complaint(BaseModel):
    text: str = Field(min_length=10, max_length=10000)


def rule_flags(text: str) -> dict[str, bool]:
    lowered = text.lower()
    return {
        "cross_municipality": len({place for place in PLACES if place in lowered}) >= 2,
        "public_official": bool(re.search(OFFICIAL, lowered)),
        "weapon": bool(re.search(WEAPON, lowered)),
        "overseas": bool(re.search(OVERSEAS, lowered)),
    }


def triage(text: str, review_threshold: float = 0.60) -> dict:
    probabilities = {
        target: MODELS[target].predict_proba([text])[0] for target in TARGETS
    }
    predictions = {
        target: MODELS[target].classes_[probability.argmax()]
        for target, probability in probabilities.items()
    }
    confidence = {
        target: float(probability.max())
        for target, probability in probabilities.items()
    }

    flags = rule_flags(text)
    reasons = []
    exclusion = predictions["exclusion"]

    if SERIOUS_VIOLENCE.search(text):
        return {
            "category": "Physical Injury/Threats",
            "urgency": "Immediate Intervention",
            "eligible": False,
            "exclusion": "Serious violence requires emergency response",
            "recommended_action": (
                "Contact local emergency medical services and police immediately. "
                "Do not use barangay conciliation for an immediate danger."
            ),
            "confidence": confidence,
            "rule_reasons": [
                "Serious-violence safety rule overrides the model prediction"
            ],
            "needs_staff_review": True,
        }

    if exclusion == "None":
        if flags["cross_municipality"]:
            exclusion = "Cross-Municipality"
            reasons.append("Two different cities/municipalities mentioned")
        elif flags["public_official"]:
            exclusion = "Public Official Involved"
            reasons.append("Public official keyword detected")
        elif flags["overseas"]:
            exclusion = "Sec. 408 Crime Penalty > 1 Yr"
            reasons.append("Possible illegal recruitment/estafa")

    if (
        exclusion == "None"
        and predictions["dispute_category"] == "Physical Injury/Threats"
        and flags["weapon"]
    ):
        exclusion = "Sec. 408 Crime Penalty > 1 Yr"
        reasons.append("Weapon/serious harm keyword in physical-injury complaint")

    eligible = exclusion == "None"
    return {
        "category": predictions["dispute_category"],
        "urgency": predictions["urgency_score"],
        "eligible": eligible,
        "exclusion": None if eligible else exclusion,
        "recommended_action": (
            "Local Barangay Conciliation"
            if eligible
            else "Direct Referral to PNP/MTC"
        ),
        "confidence": confidence,
        "rule_reasons": reasons,
        "needs_staff_review": bool(
            min(confidence.values()) < review_threshold or reasons
        ),
    }


@app.get("/")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/triage")
def run_triage(complaint: Complaint) -> dict:
    return triage(complaint.text)
