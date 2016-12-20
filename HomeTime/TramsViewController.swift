//
//  TramsViewController.swift
//  HomeTime
//
//  Created by Padraig Robinson on 18/12/16.
//  Copyright © 2016 REA. All rights reserved.
//

import UIKit
import BrightFutures

class TramsViewController: UIViewController {
    let southStopId = "4155"
    let northStopId = "4055"

    @IBOutlet weak private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var northBound = [Tram]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var southBound = [Tram]() {
        didSet {
            tableView.reloadData()
        }
    }

    @IBAction func loadTapped(_ sender: Any) {
        NetworkManager().loadTrams(for: southStopId)
            .onSuccess { trams in
                self.southBound = trams
            }
            .onFailure { print($0) }
        
        NetworkManager().loadTrams(for: northStopId)
            .onSuccess { trams in
                self.northBound = trams
            }
            .onFailure { print($0) }
    }

    @IBAction func clearTapped(_ sender: Any) {
        northBound = []
        southBound = []
    }
    
}

extension TramsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "North" : "South"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0 where northBound.count > 0:
                return northBound.count
            
            case 1 where southBound.count > 0:
                return southBound.count
            
            default:
                return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TramCell") as? TramCell else {
            fatalError("TramCell not registered for this table")
        }

        switch indexPath.section {
            case 0 where northBound.count > 0:
                cell.tram = northBound[indexPath.row]
            
            case 1 where southBound.count > 0:
                cell.tram = southBound[indexPath.row]
            
            default:
                cell.tram = nil
        }
        
        return cell
    }
}
