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
    
    func getLanguage() -> Language {
        let defaultLanguage = Language(language: "es", name: "Spanish")
        let decoder = JSONDecoder()
        
        guard let data = UserDefaults.standard.object(forKey: kUserLanguage) as? Data,
            let language = try? decoder.decode(Language.self, from: data) else {
                return defaultLanguage }
        
        return language
    }
    
    func saveUserLanguage(language: Language) {
        let encoder = JSONEncoder()
        
        if let enconded = try? encoder.encode(language) {
            UserDefaults.standard.setValue(enconded, forKey: kUserLanguage)
        }
    }
}
