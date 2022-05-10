# Commons Uploader
Mobile App for uploading Images to Wikimedia Commons. 

Find nearby commons categories, take images of them and upload them to Wikimedia Commons with your own account. Information can be added to an image, such as fitting categories, date of capture, description in different languages and more. If you are new to Wikimedia, it is also possible to only have access to the most important features and fields for a more streamlined experience with our "Simple Mode". Multiple articles in the app also provide help regarding copyright law, licences and more. Future functionality may include different supported media types and uploading to diffrent plattforms.

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
