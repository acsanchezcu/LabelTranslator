//
//  Settings.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import Foundation

class Settings
{
    // MARK: - Singleton
    
    static let shared = Settings()
    
    // MARK: - Properties
    
    let kUserLanguage = "kUserLanguage"
    
    // MARK: - Public Methods
    
    //'en' language by default
    
    func getUserLanguage() -> String {
        guard let language = UserDefaults.standard.string(forKey: kUserLanguage) else { return "en" }
        
        return language
    }
    
    func saveUserLanguage(language: String) {
        UserDefaults.standard.setValue(language, forKey: kUserLanguage)
    }
}
