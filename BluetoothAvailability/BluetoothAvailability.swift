//
//  BluetoothAvailability.swift
//  BluetoothAvailability
//
//  Created by Rimon Hanna on 01/11/2017.
//  Copyright © 2017 Rimon Hanna. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
 Bluetooth LE availability.
 - Available: Bluetooth LE is available.
 - Unavailable: Bluetooth LE is unavailable.
 The unavailable case can be accompanied by a cause.
 */

public class BluetoothAvailability: NSObject, CBCentralManagerDelegate, BluetoothAvailabilityObservable {

    public enum State: Equatable {

        case available
        case unavailable(cause: UnavailabilityCause)

        internal init(manager: CBCentralManager) {
            switch manager.state {
                case .poweredOn: self = .available
                default: self = .unavailable(cause: UnavailabilityCause(manager: manager))
            }
        }

        /// Returns a Boolean value indicating whether two FCBluetoothAvailabilityvalues are equal.
        /// - Parameters:
        ///   - lhs: A FCBluetoothAvailability value to compare.
        ///   - rhs: Another FCBluetoothAvailability value to compare.
        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
                case (.available, .available): return true
                case (.unavailable(cause: .any), .unavailable): return true
                case (.unavailable, .unavailable(cause: .any)): return true
                case (.unavailable(let lhsCause), .unavailable(let rhsCause)): return lhsCause == rhsCause
                default: return false
            }
        }
    }

    /**
     Bluetooth LE unavailability cause.
     - Any: When initialized with nil.
     - Resetting: Bluetooth is resetting.
     - Unsupported: Bluetooth LE is not supported on the device.
     - Unauthorized: The app isn't allowed to use Bluetooth.
     - PoweredOff: Bluetooth is turned off.
     */
    public enum UnavailabilityCause {

        case any
        case resetting
        case unsupported
        case unauthorized
        case poweredOff
        case unknown

        public init(nilLiteral: Void) {
            self = .any
        }

        internal init(manager: CBCentralManager) {
            switch manager.state {
                case .poweredOff: self = .poweredOff
                case .resetting: self = .resetting
                case .unauthorized: self = .unauthorized
                case .unsupported: self = .unsupported
                default: self = .unknown
            }
        }

    }

    // MARK: Properties
    private var centralManager: CBCentralManager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: NSNumber(value:false)])
    private var oldCause: UnavailabilityCause = .unknown

    /// Current availability observers.
    public var availabilityObservers = [BluetoothAvailabilityObserver]()

    /// Bluetooth LE availability, derived from the underlying CBCentralManager.
    public var availability: State {
        return State(manager: centralManager)
    }

    // MARK: Initialization
    // Can't init singleton hence private
    private override init() {
        super.init()
        centralManager.delegate = self
    }

    // MARK: Shared Instance
    public static let shared = BluetoothAvailability()

    // MARK: Internal Functions
    internal func setUnavailable(_ cause: UnavailabilityCause, oldCause: UnavailabilityCause = .unknown) {
        if oldCause == .unknown {
            for availabilityObserver in availabilityObservers {
                availabilityObserver.availabilityObserver(self, availabilityDidChange: .unavailable(cause: cause))
            }
        } else if oldCause != cause {
            for availabilityObserver in availabilityObservers {
                availabilityObserver.availabilityObserver(self, unavailabilityCauseDidChange: cause)
            }
        }
    }

    // MARK: CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ centralManager: CBCentralManager) {
        switch centralManager.state {
            case .unsupported, .unauthorized, .resetting, .poweredOff, .unknown:
                let newCause = UnavailabilityCause(manager: centralManager)
                setUnavailable(newCause, oldCause: oldCause)
                oldCause = newCause

            case .poweredOn:
                oldCause = .unknown
                for availabilityObserver in availabilityObservers {
                    availabilityObserver.availabilityObserver(self, availabilityDidChange: .available)
                }
        }
    }
}

/**
 Classes that can be observed for Bluetooth LE availability implement this protocol.
 */
public protocol BluetoothAvailabilityObservable: class {
    var availabilityObservers: [BluetoothAvailabilityObserver] { get set}
    func addAvailabilityObserver(_ availabilityObserver: BluetoothAvailabilityObserver)
    func removeAvailabilityObserver(_ availabilityObserver: BluetoothAvailabilityObserver)
}

public extension BluetoothAvailabilityObservable {

    /**
     Add a new availability observer. The observer will be weakly stored. If the observer is already subscribed the call will be ignored.
     - parameter availabilityObserver: The availability observer to add.
     */
    func addAvailabilityObserver(_ availabilityObserver: BluetoothAvailabilityObserver) {
        if !availabilityObservers.contains(where: { $0 === availabilityObserver }) {
            availabilityObservers.append(availabilityObserver)
        }
    }

    /**
     Remove an availability observer. If the observer isn't subscribed the call will be ignored.
     - parameter availabilityObserver: The availability observer to remove.
     */
    func removeAvailabilityObserver(_ availabilityObserver: BluetoothAvailabilityObserver) {
        if availabilityObservers.contains(where: { $0 === availabilityObserver }) {
            availabilityObservers.remove(at: availabilityObservers.index(where: { $0 === availabilityObserver })!)
        }
    }
}

/**
 Observers of Bluetooth LE availability should implement this protocol.
 */
public protocol BluetoothAvailabilityObserver: class {

    var bluetoothAvailability: BluetoothAvailability { get }

    /**
     Informs the observer about a change in Bluetooth LE availability.
     - parameter availabilityObservable: The object that registered the availability change.
     - parameter availability: The new availability value.
     */
    func availabilityObserver(_ availabilityObservable: BluetoothAvailabilityObservable, availabilityDidChange availability: BluetoothAvailability.State)

    /**
     Informs the observer that the cause of Bluetooth LE unavailability changed.
     - parameter availabilityObservable: The object that registered the cause change.
     - parameter unavailabilityCause: The new cause of unavailability.
     */
    func availabilityObserver(_ availabilityObservable: BluetoothAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BluetoothAvailability.UnavailabilityCause)
}

public extension BluetoothAvailabilityObserver {
    var bluetoothAvailability: BluetoothAvailability {
        get {
            return BluetoothAvailability.shared
        }
    }

    func availabilityObserver(_ availabilityObservable: BluetoothAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BluetoothAvailability.UnavailabilityCause) {
        // leaving this empty to make the delegate method optional
    }
}
