//
//  String+ValidCommands.swift
//  cookingCompanion
//
//  Created by Raymond Kim on 5/23/17.
//  Copyright © 2017 Raymond Kim. All rights reserved.
//

import Foundation

extension String {
    
    func containsValidNextSubstring() -> Bool {
        return self.contains("Next") || self.contains("next") || self.contains("done") || self.contains("Done")
    }
    
    func containsValidBackSubstring() -> Bool {
        return self.contains("Back") || self.contains("back") || self.contains("Previous") || self.contains("previous") || self.contains("Before") || self.contains("before")
    }
}
