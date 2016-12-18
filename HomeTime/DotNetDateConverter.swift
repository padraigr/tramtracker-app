//
//  Copyright (c) 2015 REA. All rights reserved.
//

import Foundation


open class DotNetDateConverter: NSObject {
    open func dateFromDotNetFormattedDateString(_ string: NSString) -> Date! {
        let startPositionRange = string.range(of: "(")
        let endPositionRange = string.range(of: "+")
        if startPositionRange.location != NSNotFound && endPositionRange.location != NSNotFound {
            let startLocation = startPositionRange.location + startPositionRange.length
            let dateAsString = string.substring(with: NSRange(location: startLocation, length: endPositionRange.location - startLocation))
            let unixTimeInterval = (dateAsString as NSString).doubleValue / 1000
            return Date(timeIntervalSince1970: unixTimeInterval)
        }

        return nil
    }

    open func formattedDateFromString(_ string: NSString) -> NSString {
        let date = dateFromDotNetFormattedDateString(string)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date!) as NSString
    }
}
