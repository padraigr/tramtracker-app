//
//  TramCell.swift
//  HomeTime
//
//  Created by Padraig Robinson on 20/12/16.
//  Copyright © 2016 REA. All rights reserved.
//

import UIKit

class TramCell: UITableViewCell {

    @IBOutlet weak var tramNumberLabel: UILabel!
    @IBOutlet weak var tramDestinationLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!

    var tram: Tram? {
        didSet {
            if let tram = tram {
                refresh(with: tram)
            } else {
                clear()
            }
        }
    }

    func refresh(with tram: Tram) {
        tramNumberLabel.text      = tram.routeNo
        tramDestinationLabel.text = tram.destination
        if tram.predictedArrivalDate.timeIntervalSinceNow < 60 {
            minutesLabel.text = "Now"
        } else if tram.predictedArrivalDate.timeIntervalSinceNow < 3600 {
            let seconds = tram.predictedArrivalDate.timeIntervalSinceNow
            let minutes = Int(ceil(seconds / 60.0))
            minutesLabel.text = (minutes > 1) ? "\(minutes) mins" : "1 min"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm"
            minutesLabel.text = dateFormatter.string(from: tram.predictedArrivalDate)
        }
    }

    func clear() {
        tramNumberLabel.text      = nil
        tramDestinationLabel.text = nil
        minutesLabel.text         = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        clear()
    }
}
