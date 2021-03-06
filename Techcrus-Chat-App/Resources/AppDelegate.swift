//
//  AppDelegate.swift
//  Techcrus-Chat-App
//
//  Created by Joel Thomson on 6/17/20.
//  Copyright © 2020 Techcrus Labs. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
        
    }
    
    //MARK:- Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Did sign in with google: \(user)")
        
        guard   let email = user.profile.email,
            let firstname = user.profile.givenName,
            let lastName = user.profile.familyName else {
                return
        }
        
        DatabaseManager.shared.userExists(with: email, completion: { exists in
            if !exists {
                //MARK:-Insert User into Database
                let chatUser = ChatAppUser(firstName: firstname, lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        
                        //Get ImageURL
                        if user.profile.hasImage {
                            
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: {
                                data, _, _ in
                                guard let data = data else {
                                    return
                                }
                                
                                let filename = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, filename: filename, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage Manager error \(error)")
                                    }
                                })
                                }).resume()
                        }
                    }
                })
            }
        })
        
        guard let authentication = user.authentication else {
            
            print("Missing auth object of google user")
            return
            
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { AuthResult, error in
            guard AuthResult != nil, error == nil else {
                print("Something went wrong!, Failed to login with google credentials")
                return
            }
            
            print("Successfully logged in with google credentials")
            
            //Sending notification to Dissmiss Login/Register Window
            NotificationCenter.default.post(name: .didLoginNotiification, object: nil)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google User was disconnected")
    }
    
}



