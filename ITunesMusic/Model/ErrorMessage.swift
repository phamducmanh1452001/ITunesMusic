//
//  ErrorMessage.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/26/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import Foundation

struct ErrorMessage: Error {
    var content: String = ""
    
    init(_ content: String) {
        self.content = content
    }
}
