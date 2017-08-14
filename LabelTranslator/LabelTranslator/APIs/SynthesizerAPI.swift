//
//  SynthesizerAPI.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import AVFoundation

class SynthesizerAPI
{
    // MARK: - Singleton
    
    static let shared = SynthesizerAPI()
    
    // MARK: - Public Methods
    
    func synthesizer(_ text: String, language: String?) {
        let utterance = AVSpeechUtterance(string: text)
        
        if let language = language {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
