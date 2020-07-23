//
//  LoginViewController.swift
//  Techcrus-Chat-App
//
//  Created by Joel Thomson on 6/27/20.
//  Copyright © 2020 Techcrus Labs. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let facebookLogin : FBLoginButton = {
        let btn = FBLoginButton()
        btn.permissions = ["email, public_profile"]
        return btn
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = .link
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return btn
    }()
    
    //MARK:- ViewDidLoad Function Here
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        facebookLogin.delegate = self
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //Add Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLogin)
        facebookLogin.layer.cornerRadius = 12
        facebookLogin.layer.masksToBounds = true
    }
    
    //MARK:- ViewDidLayoutSubview Function Here
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width-60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 50, width: scrollView.width-60, height: 52)
        
        facebookLogin.frame = CGRect(x: 30, y: loginButton.bottom + 10, width: scrollView.width-60, height: 52)
        
        facebookLogin.center = scrollView.center
        facebookLogin.frame.origin.y = loginButton.bottom+20
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    //MARK:- Initiate Login Process For Firebase
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // Firebase LOGIN STARTS HERE
        Firebase.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResults, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let results = authResults, error == nil else {
                print("Failed to Login user with Email \(email)")
                return
            }
            
            let user = results.user
            print("Logged in user \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
    }
    
    //MARK:- Handle Aleart Boxes for Login Page
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "Please make sure you've entered the correct details to login", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    //MARK:- Segue to RegisterViewPage
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
//MARK:- Advanced Text Field Extension
extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
    
}

//MARK:- Facebook Login Button Setup Extension
extension LoginViewController: LoginButtonDelegate {
    //MARK: Required Functions for FB
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No Operation
    }
    
    //MARK:- Facebook Request and error handling setup
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        //MARK: Unwrap the Token
        guard let token = result?.token?.tokenString else {
            print("User failed to login with Facebook")
            return
        }
        
        //MARK: Setup Facebook Request with GraphRequest from FBSDKLoginKit
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        
        //MARK: Start FB Request with
        facebookRequest.start(completionHandler: {_, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            //MARK: Saving data from Result Array given by Token
            print("\(result)")
            guard let userName = result["name"] as? String,
                let email = result["email"] as? String else {
                    print("Failed to get email and name from fb results")
                    return
            }
            //MARK: Seperating First Name and Last Name
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            //MARK: Inserting Facebook user into Firebase Database
            //FIXME: Clean the Code Here
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
            })
            
            //MARK: Facebook Authentication and error handling setup
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResults, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResults != nil, error == nil else {
                    if let error = error {
                        print("Facebook credentials login failed, MFA maybe needed - \(error)")
                    }
                    return
                }
                
                print("Successfully Logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            // Facebook Auth Completed
        })
    }
}
