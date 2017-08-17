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
    
    let kUserFromLanguage = "kUserFromLanguage"
    let kUserToLanguage = "kUserToLanguage"
    
    // MARK: - Public Methods
    
    func getLanguage(type: LanguageType) -> Language {
        let key = type == .from ? kUserFromLanguage : kUserToLanguage
        let defaultLanguage = type == .from ? Language(language: "en", name: "English") : Language(language: "es", name: "Spanish")
        let decoder = JSONDecoder()
        
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
            let language = try? decoder.decode(Language.self, from: data) else {
                return defaultLanguage }
        
        return language
    }
    
    func saveUserLanguage(language: Language, type: LanguageType) {
        let encoder = JSONEncoder()
        
        let key = type == .from ? kUserFromLanguage : kUserToLanguage
        
        if let enconded = try? encoder.encode(language) {
            UserDefaults.standard.setValue(enconded, forKey: key)
        }
    }
}
