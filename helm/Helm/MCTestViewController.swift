//
//  ViewController.swift
//  Helm
//
//  Created by Jeff Glasse
//

import UIKit
import MultipeerConnectivity

class MCTestViewController: UIViewController, UITextFieldDelegate {


    override var prefersStatusBarHidden: Bool { return true}
    let apDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let myMCController = self.apDel.mcController
        myMCController.setup()

        }
    
    
    @IBAction func sendCommand(_ sender: UIButton) {
        let command = sender.titleLabel!.text
        self.apDel.mcController.sendCommand(text: command!)
        print("command Sent: \(command!)")
        
    }
    
    
    
    
    
    
    
 

}
