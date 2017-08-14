//
//  Translate.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

struct Translate: Decodable
{
    let translatedText: String
    let detectedSourceLanguage: String
}

struct Translations: Decodable
{
    let translations: [Translate]
}

struct TranslateModel: Decodable
{
    let data: Translations
}
