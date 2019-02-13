# TeamPulse
This example app demonstrates an iOS and WatchOS app that publishes a user's heart rate (pulse) to a team dashboard via MQTT and AWS IoT.

## Requirements
* Xcode 10
* Swift 4
* At least one iOS device running iOS 12 and one Apple Watch running WatchOS 5
* An [AWS](http://aws.amazon.com) account and access to AWS IoT Core via the AWS Console

## Setup the iOS Project
Clone this repository locally.

Run pod install to get the [Cocoapods](http://www.cocoapods.org) used for AWS IoT installed into the project.  In terminal, navigate to the project root and run:
```
pod install
```

Open the workspace file in Xcode 10.

Build and run the project in Xcode 10 and confirm that it builds successfully and can be installed on your device.  You should be able to install the Watch app and extension on a paired Watch connected to your iOS device.

## Setup AWS IoT
Create a new Thing in the AWS console. 

For each intance of the app that you will install, you'll create an AWS thing, certificate and associate it with the AWS IoT policy you'll create below.  You'll need to follow the below steps for each instance of the app you use.

Create a certificate

Export as .p12 via openssl

```
openssl pkcs12 -export -in certificate.pem.crt -inkey private.pem.key -out awsiot-team-pulse-01.p12
```

Setup an AWS IoT policy to allow publishing and subscribing to heartrate topic
Attach the policy to the certificate for your device


Append .tp to the end so that iOS doesn't try to install the .p12 to keychain
Transfer file to your iOS device via iCloud Files, Email, etc.

Get the AWS endpoint from the AWS console to be configured in the app

Update the App to point to the AWS IoT endpoint you've configured.

### Authorize Health Data in iOS

Inside the app running on your iPhone, navigate to the Settings screen.  Tap on the "Authrorize Health Data" item to prompt iOS to grant access to heart rate data for this app.  iOS restricts access to the health data like heart rate and the user must grant your app access to that data.

### Apple Watch app
Run the Apple Watch app to monitor heart rate
Start a workout to be able to monitor more frequently and keep monitoring

## Dashboard

Once you've configured your app to monitor heart rate via the Apple Watch, it will be sending updates to the iOS app, which in turn will publish the updates to the MQTT topic on AWS IoT.  Since the Dashboard screen is subscribed to that channel, any updates to heart rate should show up on the Dashboard screen.  Heart rates for each user are shown as a tile and are updated as new values are posted to MQTT.  A unique user id GUIDD that is created at app install is used when publishing the messages so that new values are recognized as updates to the same user.