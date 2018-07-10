#  Verifai SDK iOS Example

## Installation
In order to install the example you will need the following:

- CocoaPods
- A valid Verifai licence (you can get this at [verifai.com](https://www.verifai.com)). The bundle identifier should be the same as the bundle identifier of the app. Change the bundle identifier of the app if needed.
- A valid model file which can be obtained [here](https://dashboard.verifai.com/downloads/neural-network/)

### Installation steps:

- `pod install` in the main directory
- Create a new file in `verifai-example/Resources/licencefile.txt` in which you put the licence you obtained.
- Download the local models and add them to the project (how to [here](https://docs.verifai.com/ios_docs/ios-sdk-latest.html?swift#loading-a-local-neural-model))
- Build and install app.

More information: https://docs.verifai.com/ios_docs/ios-sdk-latest.html
