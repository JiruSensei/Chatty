//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray: [Message] = []
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        // Ici on trouve le code qui permet d'appler la méthode DidENding
        // et masquer le Keyboard
        // On définit un TapGesture qui appellera notre méthode, définie plus loin,
        // Quand on tapera dans l'écran
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(tableViewTapped))
        // Et on enregistre cette tapGesture dans la TableView
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        // On crée une UINib avec en paramètre le nomde notre fichier .xib
        // tandis que pour l'identifier on récupère celui qu'on a positionné
        // dans les properties pour cette objet MessaggeCell.xib
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        print("Call retrieve message")
        retrieveMessages()
        
        // On suupprime la ligne entre les message
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // C'est le coté un peu tricky je trouve
        // On récupère la cell à partir de la Table en indiquant la Row
        // ainsi que le Type
        // et on applique un cast avec as! pour ne pas récupérer un Optional
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        let message = self.messageArray[indexPath.row]
        cell.messageBody.text = message.body
        cell.senderUsername.text = message.sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        // Pour choisir la couleur on regarde si le message vient du User courant
        if cell.senderUsername.text == Auth.auth().currentUser?.email as? String {
            cell.avatarImageView.backgroundColor = UIColor.flatLime()
            cell.backgroundColor = UIColor.flatPlum()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    // Cette méthode sert à configurer les cell pour, dans notre cas, adaptent leur hauteur
    // à la taille du texte présent à l'intérieur
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    // Ces deux méthode sont optionnelles donc Xcode ne se plaint pas si
    // on ne les implémente pas

    //TODO: Declare textFieldDidBeginEditing here:
    // Sera appelé quand on clic dans TF je pense
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // On force la taille de la View où se trouve le TF à
        // grandir pour contenir le Keyboard en plus du TF
        
        // L'ensemble peut être mis dans la méthode animate afin de donner
        // un aspect visuel plus sympa
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308 // KB est 258
            // et l'on force a redéssiner
            self.view.layoutIfNeeded()
            
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    // On doit faire l'inverse de la méthode précédente pour remettre
    // en l'état la View
    // La grande différence avec la méthode précédente est que celle la
    // n'est pas appelée automatiquement mais doit l'être manuellement.
    // On le fait dans viewDidLoad() pour ce qui est le caas quand on clic
    // en dehors du TF
    // On appel simplement la méthode messageTextfield. endEditing() quand
    // on presse le bouton "send"
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50 // TF sans KB
            
            // et l'on force a redéssiner
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        // Pour faire disparaitre le clavier virtuel
        messageTextfield.endEditing(true)
        
        // On inhibe les éléments graphique que l'on ne veut pas que l'utilisateur
        // utilise pendant que le send() se fait comme par exemple appyuer plusieurs
        // fois sur le boutton send
        sendButton.isEnabled = false
        messageTextfield.isEnabled = false
        
        //TODO: Send the message to Firebase and save it in our database
        // En premier on crée un DB spécifique pour les Messages
        // Cette DB est une enfant de notre DB principale (obtenue avec reference()).
        let messageDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text]
        
        // On sauvegarde le message dans notre base
        // en générant un ID automatique d'où cette syntaxe
        messageDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print("Saving message failed!!! \(error!)")
            }
            else {
                print("Saving message succeed")
                
                self.sendButton.isEnabled = true
                self.messageTextfield.isEnabled = true
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    // C'est une méthode vraiment importante car c'est elle qui va répondre
    // au changement dans la base de données, donc le post de message.
    func retrieveMessages() {
        // On récupère déjà la base de donnée créée précédemment
        let messageDB = Database.database().reference().child("Messages")
    
        // On s'enregistre pour un type d'événement bien particulier
        // L'ajout d'une donnée .cildAdded (ça ne fait pas de polling)
        messageDB.observe(.childAdded) {
            (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            // On récupère le message publié sous forme de Dictionary
            let sender = snapshotValue["Sender"]!
            let text = snapshotValue["MessageBody"]!
            
            // On ajout le message dans notre tableau
            self.messageArray.append(Message(from: sender, with: text))
            // et il fut penser à recharger la table mais avant à aussi la
            // configurer pour avoir la bonne taille
            self.configureTableView()
            self.messageTableView.reloadData()
            
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        // Pour ce log out Firebase fourni la méthode signOut()
        // Cette dernière peut lever une exception
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("Problème danss le logout \(error)")
        }
        
    }
    

}
