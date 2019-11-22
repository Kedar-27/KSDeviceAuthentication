# KSDeviceAuthenticator

KSDeviceAuthenticator provides wrapper around LocalAuthentication.framework for authentication device using touchId , faceId and passcode.


**Note:** - Face ID authentication requires user's permission to be add in info.plist.
```swift
<key>NSFaceIDUsageDescription</key>
<string>This app requires Face ID permission to authenticate using Face recognition.</string>
```
## Installation

### CocoaPods

To be added soon

### Manual

Drag and drop files from Sources folder into your project

## Usage

### Authenticate with biometric

```swift
KSDeviceAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in

    switch result {
    case .success( _):
        print("Authentication Successful")
    case .failure(let error):
        print("Authentication Failed")
    }
}
```
- When reason specified as empty - default will be used based on the device. Ex. for iPhone X - **"Confirm your face to authenticate."**,  For other devices - **"Confirm your fingerprint to authenticate."**

### Can Authenticate with biometric

- Alternatively you can check before authentication by following. This will check that if device supports Touch ID or Face ID authentication and your app can use that as of now.

```swift
if KSDeviceAuthenticator.canAuthenticate() {

    KSDeviceAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
        // check result -> success or failure
    }
}
```
### Check for Face ID
- Check if device supports face recognition or not.
```swift
if KSDeviceAuthenticator.shared.faceIDAvailable() {
    // device supports face id recognition.
}
```
### Check for Touch ID
- Check if device supports touch id authentication or not.
```swift
if BioMetricAuthenticator.shared.touchIDAvailable() {
    // device supports touch id authentication
}
```

### Fallback Reason
- Fallback reason title will be shown when first authentication attempt is failed.
- You can give alternate authentication options like enter 'username & password' when user clicks on fallback button.
- Default reason is empty, which will hide fallback button.

```swift
KSDeviceAuthenticator.authenticateWithBioMetrics(reason: "Biometric Authentication", fallbackTitle: "Enter Credentials") { (result) in

    switch result {
    case .success( _):
        // proceed further

    case .failure(let error):

        switch error {
        case .fallback:

            print("Authentication Failed")

            // show alternatives on fallback button clicked
            // for ex. - enter username/email and password

        default:
            break
        }
    }
}
```

### BiometryLockedout
- When biometry authentication is locked out after multiple failed attempts. You can unlock it by passcode authentication.
- Provide your own passcode authentication reason here, default will be used if not provided.

```swift
KSDeviceAuthenticator.authenticateWithPasscode(reason: message) { (result) in
    switch result {
    case .success( _):
        // passcode authentication success
    case .failure(let error):
        print(error.message())
    }
}
```

### Error Handling
- There are various cases when biometric authentication can be failed.

1. **fallback**
    - Called when user clicks on provided fallback button.
2. **biometryNotEnrolled**
    - Called when no fingerprints or face is registered with the device.
    - You can show message to register a new face or fingerprint here.
    - Default message will be shown if not provided.
3. **canceledByUser**
    - Called when authentication canceled by user.
4. **canceledBySystem**
    - Called when authentication canceled by system when app goes into background or any other reason.
5. **passcodeNotSet**
    - Called when device passcode is not set and trying to use biometry authentication.
    - We can ask user to set device passcode here by opening Settings Application.
6. **failed**
    - Called when multiple failed attempts made by user.
    - You can show error message to user here.
    - Default message can be shown if not provided.
7. **biometryLockedout**
    - Called when more than 5 failed attempts made using biometric authentication. This will locked your biometry system.
    - You'll restrict user when this error is occured.
    - Aleternatively you can ask user to enter device passcode to unlock biometry.
8. **biometryNotAvailable**
    - Called when device does not support Face ID or Touch ID authentication.

### Example

```swift
KSDeviceAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in

    switch result {
    case .success( _):

        // authentication successful
        self?.showLoginSucessAlert()

    case .failure(let error):

        switch error {

        // device does not support biometric (face id or touch id) authentication
        case .biometryNotAvailable:
            self?.showErrorAlert(message: error.message())

        // No biometry enrolled in this device, ask user to register fingerprint or face
        case .biometryNotEnrolled:
            self?.showGotoSettingsAlert(message: error.message())

        // show alternatives on fallback button clicked
        case .fallback:
            self?.txtUsername.becomeFirstResponder() // enter username password manually

        // Biometry is locked out now, because there were too many failed attempts.
        // Need to enter device passcode to unlock.
        case .biometryLockout:
            self?.showPasscodeAuthentication(message: error.message())

        // do nothing on canceled by system or user
        case .canceledBySystem, .canceledByUser:
            break

        // show error for any other reason
        default:
            self?.showErrorAlert(message: error.message())
        }
    }
}
```
## Credits
https://github.com/rushisangani/BiometricAuthentication

## License

KSDeviceAuthentication is released under the MIT license.
