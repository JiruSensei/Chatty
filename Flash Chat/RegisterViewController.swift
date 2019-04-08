//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        //TODO: Set up a new user on our Firbase database
        // On fait apparaitre le sablier
        SVProgressHUD.show()
        
        // On récupère le singleton si je ne m'abuse puis on
        //la méthode createUser qui prend un email et un password
        // Comme cette méthode se fait en background on peut enregistrer
        // une closure qui sera appelée à la terminaison
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            (user, error) in
            if let erreur = error {
                print(erreur)
            }
            else {
                print("registration succeed")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
    } 
    
    
}
