//
//  LanguagesViewController.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 16/08/2017.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import UIKit


enum LanguageType {
    case from
    case to
}

class LanguagesViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    // MARK: - Properties
    var type: LanguageType = .from
    var languages: [Language] = [] {
        didSet {
            tableView?.reloadData()
            
            let userLanguage = Settings.shared.getLanguage(type: type)
            
            for (index, language) in languages.enumerated() {
                if language.language == userLanguage.language {
                    let indexPath = IndexPath.init(row: index, section: 0)
                    
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
                    
                    break
                }
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLanguages()
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let language = languages[indexPath.row]
            
            Settings.shared.saveUserLanguage(language: language, type: type)
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func getLanguages() {
        activityIndicator.startAnimating()
        
        TranslationAPI.shared.getLanguages { [weak self] (languages, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                guard let languages = languages else { return }
                
                self?.languages = languages
            }
        }
    }
    
    
}

// MARK: - UITableViewDataSource

extension LanguagesViewController: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let language = languages[indexPath.row]
        
        if let titleLabel = cell.viewWithTag(1) as? UILabel {
            titleLabel.text = language.name ?? language.language
        }
        
        return cell
    }
    
}
