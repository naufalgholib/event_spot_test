#!/bin/bash

# Load environment variables
source .env

# Replace API key in web/index.html
sed -i "s/GOOGLE_MAPS_API_KEY/$GOOGLE_MAPS_API_KEY/g" web/index.html

# Replace API key in AndroidManifest.xml
sed -i "s/GOOGLE_MAPS_API_KEY/$GOOGLE_MAPS_API_KEY/g" android/app/src/main/AndroidManifest.xml

# Build the app
flutter build apk
flutter build web 

chmod +x scripts/build.sh 