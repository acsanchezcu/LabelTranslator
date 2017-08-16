//
//  TranslatorAPI.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import Foundation

class TranslationAPI
{
    // MARK: - Singleton
    
    static let shared = TranslationAPI()
    
    // MARK: - Properties

    private let API_KEY = ""
    private let BASE_URL = "https://translation.googleapis.com/language/translate/v2"
    
    /*
     API
     */
    
    //Get the list of languages available by the API
    
    func getLanguages(completionHandler: @escaping ([Language]?, Error?) -> Void) {
        let urlString = "\(BASE_URL)/languages?key=\(API_KEY)"
        guard let url = URL(string: urlString) else { return }
        
        let params = ["target": "en"]
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, err in
            guard let data = data else {
                completionHandler(nil, err)
                return
            }
            
            do {
                let languages = try JSONDecoder().decode(LanguagesData.self, from: data)
                
                completionHandler(languages.data.languages, nil)
            }
            catch let jsonErr {
                completionHandler(nil, jsonErr)
            }
            
            }.resume()
    }
    
    //Translate the text from english to a determinate language
    
    func translateText(_ text: String, language: String, completionHandler: @escaping (String?, Error?) -> Void) {
        let urlString = "\(BASE_URL)?key=\(API_KEY)"
        
        guard let url = URL(string: urlString) else { return }
        
        let params = ["q" : text, "target" : language]
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, err in
            guard let data = data else {
                completionHandler(nil, err)
                return
            }
            
            do {
                let translateModel = try JSONDecoder().decode(TranslateModel.self, from: data)
                
                var translatedText = ""
                
                if let translate = translateModel.data.translations.first {
                    translatedText = translate.translatedText
                }
                
                completionHandler(translatedText, nil)
            }
            catch let jsonErr {
                completionHandler(nil, jsonErr)
            }
            
            }.resume()
    }
    
}
