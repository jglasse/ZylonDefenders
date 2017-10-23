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

    @IBOutlet weak var comView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let myMCController = self.apDel.mcController
        myMCController.setup()

        }

    @IBAction func sendCommand(_ sender: UIButton) {
        let command = sender.titleLabel!.text
        self.apDel.mcController.sendCommand(text: command!)
        print("command Sent: \(command!)")

    }

    @IBAction func showMode() {
        self.comView.isHidden = false
    }

    @IBAction func hideMode() {
        self.comView.isHidden = true

    }

}
