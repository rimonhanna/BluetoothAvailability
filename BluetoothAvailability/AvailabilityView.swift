//
//  AvailabilityView.swift
//  BluetoothAvailability
//
//  Created by Rimon Hanna on 01/11/2017.
//  Copyright © 2017 Rimon Hanna. All rights reserved.
//

import UIKit

internal class AvailabilityView: UIView {

    // Properties
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    // Initialization
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let view = Bundle.main.loadNibNamed("AvailabilityView", owner: self, options: nil)?[0] as? UIView else {
            return
        }

        self.addSubview(view)
        view.frame = self.bounds

        borderView.backgroundColor = UIColor.gray
        statusLabel.attributedText = attributedStringForAvailability(.unavailable(cause: .unknown))
        statusLabel.textAlignment = NSTextAlignment.center
        bluetoothAvailability.addAvailabilityObserver(self)
    }

    // MARK: Functions
    internal func attributedStringForAvailability(_ availability: BluetoothAvailability.State) -> NSAttributedString {
        let leadingText = "Bluetooth: "
        let trailingText = availabilityLabelTrailingTextForAvailability(availability)
        let string = leadingText + trailingText as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 14), range: NSRange(location: 0, length: string.length))
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: string.range(of: leadingText))
        switch availability {
        case .available: attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.green, range: string.range(of: trailingText))
        case .unavailable: attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: string.range(of: trailingText))
        }
        return attributedString
    }

    private func availabilityLabelTrailingTextForAvailability(_ availability: BluetoothAvailability.State) -> String {
        switch availability {
            case .available: return "Available"
            case .unavailable(cause: .poweredOff): return "Unavailable (Powered off)"
            case .unavailable(cause: .resetting): return "Unavailable (Resetting)"
            case .unavailable(cause: .unsupported): return "Unavailable (Unsupported)"
            case .unavailable(cause: .unauthorized): return "Unavailable (Unauthorized)"
            case .unavailable(cause: .any): return "Unavailable"
            case .unavailable(cause: .unknown): return "Unknown"
        }
    }

}

// MARK: BluetoothAvailabilityObserver
extension AvailabilityView: BluetoothAvailabilityObserver {

    internal func availabilityObserver(_ availabilityObservable: BluetoothAvailabilityObservable, availabilityDidChange availability: BluetoothAvailability.State) {
        statusLabel.attributedText = attributedStringForAvailability(availability)
    }

    internal func availabilityObserver(_ availabilityObservable: BluetoothAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BluetoothAvailability.UnavailabilityCause) {
        statusLabel.attributedText = attributedStringForAvailability(.unavailable(cause: unavailabilityCause))
    }
}
