# D.A.N.I.E.L.D.G.U.L.L.A – Flutter Web

Screens: Landing, File a Complaint, Track Complaint, About, Officer Dashboard, Complaint Detail.

## Run
```
cd daniel_portal
flutter create . --platforms=web      # adds icons / missing web files (keeps lib/)
flutter pub get
flutter run -d chrome
```
Build for deployment: `flutter build web`

Routes: `/` `/complaint` `/track` `/about` `/officer` `/officer/complaint`
Data is in-memory sample data (lib/data.dart). Submitting the form adds a case you can track.
Optional hero photo: put `hero.jpg` in assets/images/.
