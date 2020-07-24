//
//  ViewController.swift
//  Techcrus-Chat-App
//
//  Created by Joel Thomson on 6/17/20.
//  Copyright © 2020 Techcrus Labs. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateAuth()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func validateAuth(){
        if Auth.auth().currentUser?.email == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}

