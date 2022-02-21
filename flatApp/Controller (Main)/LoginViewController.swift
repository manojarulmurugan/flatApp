//
//  LoginViewController.swift
//  flatApp
//
//  Created by Manoj Arulmurugan on 14/07/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let verificationCode = passwordTextField.text{
            
            func showTextInputPrompt(withMessage message: String,
                                       completionBlock: @escaping ((Bool, String?) -> Void)) {
                let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                  completionBlock(false, nil)
                }
                weak var weakPrompt = prompt
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                  guard let text = weakPrompt?.textFields?.first?.text else { return }
                  completionBlock(true, text)
                }
                prompt.addTextField(configurationHandler: nil)
                prompt.addAction(cancelAction)
                prompt.addAction(okAction)
                present(prompt, animated: true, completion: nil)
              }
            
            func showMessagePrompt(_ message: String) {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
              }
            
            //UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID ?? "errortest",
              verificationCode: verificationCode
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                  let authError = error as NSError
                    
                  let isMFAEnabled = true
                    
                  if isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError
                      .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                      displayNameString += tmpFactorInfo.displayName ?? ""
                      displayNameString += " "
                    }
                    showTextInputPrompt(
                      withMessage: "Select factor to sign in\n\(displayNameString)",
                      completionBlock: { userPressedOK, displayName in
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                          if displayName == tmpFactorInfo.displayName {
                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                          }
                        }
                        PhoneAuthProvider.provider()
                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                             multiFactorSession: resolver
                                               .session) { verificationID, error in
                            if error != nil {
                              print(
                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                              )
                            } else {
                              showTextInputPrompt(
                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                completionBlock: { userPressedOK, verificationCode in
                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                    .credential(withVerificationID: verificationID!,
                                                verificationCode: verificationCode!)
                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                    .assertion(with: credential!)
                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                                    if error != nil {
                                      print(
                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                      )
                                    } else {
                                      self.navigationController?.popViewController(animated: true)
                                    }
                                  }
                                }
                              )
                            }
                          }
                      }
                    )
                  }
                  else {
                    showMessagePrompt(error.localizedDescription)
                    return
                  }
                  // ...
                  return
                }
                // User is signed in
                // ...
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
            }
        }
    }
}
