# Commons Uploader
Mobile App for uploading Images to Wikimedia Commons. (Future functionality may include different supported media types and different file destinations).

Made with Flutter at the Institute for Software at OST Campus Rapperswil.

# Setting up development env

## Add .env file
For the app to run in this state, the following is required: 
 - a Wikimedia API key. For workers at IFS: Our client secret can be found in the Password Excel.
 - A sentry dns url for reporting errors. (This is not needed if the SentryHandler in main is replaced with something else from the catcher library.)
In the 'projects' folder, add a file named '.env' and add these things in the following format (also see the `.env.example` file):
```
SECRET_TOKEN=0123456789
SENTRY_DNS=https://examplePublicKey@o0.ingest.sentry.io/0
```

## Generate launcher icons

In the terminal, run:
```
flutter pub get
flutter pub run flutter_launcher_icons:main
```