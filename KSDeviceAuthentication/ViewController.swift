//
//  ViewController.swift
//  KSDeviceAuthentication
//
//  Created by Kedar Sukerkar on 22/11/19.
//  Copyright © 2019 Kedar Sukerkar. All rights reserved.
//

import UIKit
import ObjectiveC.NSObjCRuntime


class ViewController: UIViewController {

    // MARK: - Constants
    static let storyboardIdentifier = "ViewController"
    static let storyboardName       = "Main"
    
    // MARK: - Outlets
    @IBOutlet weak var deviceAuthenticationButton: UIButton!
    @IBOutlet weak var biometricAuthenticationButton: UIButton!
    
    // MARK: - Properties
    
    
    
    // MARK: - Data Injections
    
    
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    func setupVC(){
        
        
        
        
    }
    
    func setupUI(){
        
        
        
        
        
        
        
        
    }
    
    // MARK: - IBActions
    @IBAction func deviceAuthenticationButtonClicked(_ sender: Any) {
        // start authentication
        
        KSDeviceAuthenticator.authenticateWithPasscode(reason: "") {[weak self] (result) in
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
                     // enter username password manually
                    
                    break
                    
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
        
    }
    
    
    @IBAction func biometricAuthenticationButtonClicked(_ sender: Any) {
        // Set AllowableReuseDuration in seconds to bypass the authentication when user has just unlocked the device with biometric
        KSDeviceAuthenticator.shared.allowableReuseDuration = 30
        
        

        // start authentication
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
                     // enter username password manually
                    
                    break
                    
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
        
        
    }
    
    // show passcode authentication
    func showPasscodeAuthentication(message: String) {
        
        KSDeviceAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
            switch result {
            case .success( _):
                self?.showLoginSucessAlert() // passcode authentication success
            case .failure(let error):
                print(error.message())
            }
        }
    }
    
    


}

// MARK: - Alerts
extension ViewController {
    
    func showAlert(title: String, message: String) {
        
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: false) { (button) in
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoginSucessAlert() {
        showAlert(title: "Success", message: "Login successful")
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showGotoSettingsAlert(message: String) {
        let settingsAction = AlertAction(title: "Go to settings")
        
        let alertController = getAlertViewController(type: .alert, with: "Error", message: message, actions: [settingsAction], showCancel: true, actionHandler: { (buttonText) in
            if buttonText == CancelTitle { return }
            
            // open settings
            let url = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:])
            }
            
        })
        present(alertController, animated: true, completion: nil)
    }
}


let CancelTitle     =   "Cancel"
let OKTitle         =   "OK"
typealias AlertViewController = UIAlertController

struct AlertAction {
    
    var title: String = ""
    var type: UIAlertAction.Style? = .default
    var enable: Bool? = true
    var selected: Bool? = false
    
    init(title: String, type: UIAlertAction.Style? = .default, enable: Bool? = true, selected: Bool? = false) {
        self.title = title
        self.type = type
        self.enable = enable
        self.selected = selected
    }
}

extension UIViewController {
    
    // Show Alert or Action sheet
    func getAlertViewController(type: UIAlertController.Style, with title: String?, message: String?, actions:[AlertAction], showCancel: Bool , actionHandler:@escaping ((_ title: String) -> ())) -> AlertViewController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: type)
        
        // items
        var actionItems: [UIAlertAction] = []
        
        // add actions
        for (index, action) in actions.enumerated() {
            
            let actionButton = UIAlertAction(title: action.title, style: action.type!, handler: { (actionButton) in
                actionHandler(actionButton.title ?? "")
            })
            
            actionButton.isEnabled = action.enable!
            if type == .actionSheet { actionButton.setValue(action.selected, forKey: "checked") }
            actionButton.setAssociated(object: index)
            
            actionItems.append(actionButton)
            alertController.addAction(actionButton)
        }
        
        // add cancel button
        if showCancel {
            let cancelAction = UIAlertAction(title: CancelTitle, style: .cancel, handler: { (action) in
                actionHandler(action.title!)
            })
            alertController.addAction(cancelAction)
        }
        return alertController
    }
}

extension UIAlertController {
}


/// NSObject associated object
public extension NSObject {
    
    /// keys
    private struct AssociatedKeys {
        static var descriptiveName = "associatedObject"
    }
    
    /// set associated object
    @objc func setAssociated(object: Any) {
        objc_setAssociatedObject(self, &AssociatedKeys.descriptiveName, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// get associated object
    @objc func associatedObject() -> Any? {
        return objc_getAssociatedObject(self, &AssociatedKeys.descriptiveName)
    }
}
