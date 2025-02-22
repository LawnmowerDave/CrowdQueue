//
//  LoginViewController.swift
//  Musivote
//
//  Created by Matthew Loucks on 2/22/23.
//

import UIKit
import Supabase
import GoTrue

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        
        self.emailField.text = "loucks12345@gmail.com"
        self.passwordField.text = "password123"
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func loginClicked(_ sender: Any) {
        
        guard let email = self.emailField.text else { return }
        guard let password = self.passwordField.text else { return }
        
        // next, update their device Token
        let deviceToken: String = getDeviceToken()
        
        let jsonData: [String: AnyJSON]? = [
            "deviceToken": AnyJSON.string(deviceToken)
        ]
        
        let attributes: UserAttributes = UserAttributes(data: jsonData)
    
        let client = getSupabaseConnection()
        
        Task {
            do {
                try await client!.auth.signIn(email: email, password: password)
                let session = try await client!.auth.session
                
//                set access token
                struct DefaultsKeys {
                    static let accessToken = "accessToken"
                    static let refreshToken = "refreshToken"
                    static let userId = "userId"
                }
                
                let defaults = UserDefaults.standard
                defaults.set(session.accessToken, forKey: DefaultsKeys.accessToken)
                defaults.set(session.refreshToken, forKey: DefaultsKeys.refreshToken)
                defaults.set(session.user.id.uuidString, forKey: DefaultsKeys.userId)
                
                print("### Session Info: \(session)")
                print("LOGGED IN")
                
                try await client?.auth.update(user: attributes)
                //              self.performSegue(withIdentifier: "goToNext", sender: self)
                
                SceneDelegate.shared!.transitionToMainController()
                
            } catch {
                print("### Login Error: \(error)")
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
