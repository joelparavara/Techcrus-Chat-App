//
//  StorageManager.swift
//  Techcrus-Chat-App
//
//  Created by Joel Thomson on 8/11/20.
//  Copyright © 2020 Techcrus Labs. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/email-email-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload Picture to Firebase Storage and return completion url string to download
    public func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(filename)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                //failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(filename)").putData(data, metadata: nil, completion: { url, error in
                guard let url = url else {
                    print("Failed to get url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                //let urlString = 
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
    
        
}
    
