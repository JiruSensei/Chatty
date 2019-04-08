//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        //TODO: Log in the user
        // On affiche comme un sablier car l'authentification potentiellement
        // peut prendre du temps
        SVProgressHUD.show()
        
        // On utilise également la classe de Firebase du nom Auth
        
        Auth.auth().signIn(withEmail: emailTextfield.text!
        , password: passwordTextfield.text!) { (result, error) in
            
            if let error = error {
                print("Login failed, reason is \(error)")
            }
            else {
                print("Login succeed for user \(result!.user)")
                // On supprilme le sablier
                SVProgressHUD.dismiss()
                // On cherche à aller vers l'écran Chat
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }

        }
        
    }
    


    
}  
