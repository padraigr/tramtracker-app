//
//  Copyright (c) 2015 REA. All rights reserved.
//

import Foundation

extension String {
    func dateFromDotNetFormatted() -> Date? {
        let nsString = self as NSString
        let startPositionRange = nsString.range(of: "(")
        let endPositionRange = nsString.range(of: "+")
        if startPositionRange.location != NSNotFound && endPositionRange.location != NSNotFound {
            let startLocation = startPositionRange.location + startPositionRange.length
            let dateAsString = nsString.substring(with: NSRange(location: startLocation, length: endPositionRange.location - startLocation))
            let unixTimeInterval = (dateAsString as NSString).doubleValue / 1000
            return Date(timeIntervalSince1970: unixTimeInterval)
        }

        return nil
    }
}
