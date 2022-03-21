# Commons Uploader
Mobile App for uploading Images to Wikimedia Commons. (Future functionality may include different supported media types and different file destinations).

Made with Flutter at the Institute for Software at OST Campus Rapperswil.

# Setting up development env

## Add .env file
For the app to work, a Wikimedia API key is required. For workers at IFS: Our client secret can be found in the Password Excel.
In the 'projects' folder, add a file named '.env' and add the secret token in the following format:
```
SECRET_TOKEN=xXxXxXx
```

## Generate launcher icons

In the terminal, run:
```
flutter pub get
flutter pub run flutter_launcher_icons:main
```