//
//  NewConversationViewController.swift
//  Techcrus-Chat-App
//
//  Created by Joel Thomson on 6/27/20.
//  Copyright © 2020 Techcrus Labs. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users"
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel : UILabel = {
        let lbl = UILabel()
        lbl.text = "No Results"
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 21, weight: .medium)
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewConversationViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
    }
}
