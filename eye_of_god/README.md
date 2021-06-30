# How to run

## Flutter Project:

`eye_of_god`

## OpenCV CPP Setup:

Download OpenCV framework for iOS:https://docs.opencv.org/4.5.2/d5/da3/tutorial_ios_install.html
Copy or create symlinks: opencv2.framework to native_opencv/ios
Open Runner.xcworkspace and copy OpenCV framework to Runnner(.xcproject) and Runner(.xcworkspace).

## Google Maps Setup:

Paste Google Maps API Key ios/Runner/AppDelegate.swift: GMSServices.provideAPIKey("YOUR-API-KEY")

## Xcode Setup:

Change the development team in Targets/Runner/Signing&Capabilities to your Apple ID.
Add a unique Bundle identifier

## Model Files:

Incase the model files ("*.tflite") are missing from eye_of_god/assets folder, download it from here and place it in eye_of_god/assets: https://drive.google.com/drive/folders/1UU3Cknl5Ns4tQJxeLE_aPkNXSMrRk8VF?usp=sharing

Run the app using flutter run in the main directory of the project eye_of_god.

