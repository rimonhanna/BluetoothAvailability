//
//  ViewController.swift
//  BluetoothAvailability
//
//  Created by Rimon Hanna on 01/11/2017.
//  Copyright © 2017 Rimon Hanna. All rights reserved.
//

import UIKit

internal class MainViewController: UIViewController {
    
    // MARK: Properties
    
    var activityIndicator: UIActivityIndicatorView? {
        guard let activityIndicator = activityIndicatorBarButtonItem.customView as? UIActivityIndicatorView else {
            return nil
        }
        return activityIndicator
    }
    
    private let activityIndicatorBarButtonItem = UIBarButtonItem(customView: UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white))
    
    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator?.color = UIColor.black
        navigationItem.title = "View Controller"
        navigationItem.rightBarButtonItem = activityIndicatorBarButtonItem
        bluetoothAvailability.addAvailabilityObserver(self)
    }
}

// MARK: BluetoothAvailabilityObserver
extension MainViewController: BluetoothAvailabilityObserver {
    
    func availabilityObserver(_ availabilityObservable: BluetoothAvailabilityObservable, availabilityDidChange availability: BluetoothAvailability.State) {
        if availability == .available {
            activityIndicator?.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
        }
    }
}


