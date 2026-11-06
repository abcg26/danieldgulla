# D.A.N.I.E.L.D.G.U.L.L.A – Flutter Web

Screens: Landing, File a Complaint, Track Complaint, About, Officer Dashboard, Complaint Detail.

## Run
From the project root, follow the AI triage instructions below to start the API and app.
Build for deployment: `flutter build web`

Routes: `/` `/complaint` `/track` `/about` `/officer` `/officer/complaint`
Cases are stored in the current browser's local storage. The dashboard starts empty rather than
showing fabricated case records. Local records are not shared across browsers or devices.

## AI triage integration

The complaint form sends the narrative to the FastAPI model in `api/` (`POST /triage`). Its
category, urgency, jurisdiction recommendation, confidence, and review flags appear in the
dashboard and case detail. Eligible cases automatically enter the conciliation workflow;
ineligible cases are marked as referred. These are model-driven routing recommendations, not
official legal determinations. If the service is unavailable, the case is still saved and can be
retried from its tracking page.

The API also has a deterministic safety override for explicit serious-violence terms (including
stabbing): it forces immediate-intervention urgency and recommends contacting emergency medical
services and police instead of conciliation, regardless of the model's predicted category. This
keyword rule is a safeguard, not a substitute for emergency dispatch, legal advice, or a complete
review of the complaint; it can miss descriptions phrased differently and may flag some historical
incidents for urgent staff review. Test API changes with `python -m unittest discover -s api`.

Run the API from the project root:

```
cd api
pip install -r requirements.txt
uvicorn app:app --port 8000
```

In another terminal, run the web app with the API URL:

```
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Set `API_BASE_URL` to the deployed service's HTTPS URL when hosting the app. The included
`api/kp_model.joblib` requires the scikit-learn version pinned in `api/requirements.txt`.
Complaint narratives are sent to the configured API, so only use an endpoint you trust.

Case records and workflow updates persist in browser local storage after refresh. They do not sync
between a resident's device and an officer's device. The officer workspace can schedule hearings,
save notes, change referral/resolution status, and copy clearly marked document drafts. It does not
upload evidence files, send referrals, issue official notices, or replace a shared authenticated
database; those require a deployed backend, staff identity, and barangay-specific contact and
legal-process configuration.
