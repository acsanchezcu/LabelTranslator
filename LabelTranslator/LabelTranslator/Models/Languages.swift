//
//  Languages.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

struct Language: Encodable,Decodable {
    let language: String
    let name: String?
}

struct Languages: Decodable {
    let languages: [Language]
}

struct LanguagesData: Decodable {
    let data: Languages
}
