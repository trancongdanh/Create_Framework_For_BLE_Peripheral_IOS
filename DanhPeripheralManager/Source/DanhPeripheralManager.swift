//
//  DanhPeripheralManager.swift
//  DanhPeripheralManager
//
//  Created by Tran Cong Danh on 5/16/20.
//  Copyright © 2020 Tran Cong Danh. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

/**
 # Overview
 The delegate will receive callback from class DanhPeripheralManager.
 */
public protocol DanhPeripheralManagerDelegate: class {
    
    /// Detect when a local peripheral device received an Attribute Protocol (ATT) write request for a characteristic with a dynamic value.
    /// - Parameter peripheral: The peripheral manager that received the request.
    /// - Parameter requests: A list of one or more CBATTRequest objects, each representing a request to write the value of a characteristic. The request include value RED or GREEN.
    func onPeripheralReceiveWrite(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
}

/**
# Overview
The class likes a BLE Peripheral (you can think it as a server in socket programming), having a characteristic to receive the data. If it receives "RED", turn the LED (the circle in the middle of the app) to RED, if it receives "GREEN", turn the LED to green, otherwise let's the LED grey.
*/
open class DanhPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    
    let UUIDServiceStr = "AAB7643F-BD0C-4BFD-8547-4027364BD723"
    let UUIDCharateristicStr = "60FF3470-DAB6-4890-910D-CAC5911ED642"
    
    /// Only one instance of class DanhPeripheralManager is running in app
    public static let shared = DanhPeripheralManager()
    
    weak var delegate: DanhPeripheralManagerDelegate?
    
    private var peripheralManager: CBPeripheralManager!
    private var service: CBUUID!
    
    /// Init, start  the peripheral manager of CoreBluetooth and set delegate
    /// - Parameter newDelegate: set delegate to callback
    /// - Returns: Void
    public func startPeripheralManager(newDelegate: DanhPeripheralManagerDelegate) {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        delegate = newDelegate
    }
    
    //MARK: - Private methods
    func addServices() {
         // 1. Create instance of CBMutableCharcateristic
        let changeCircleColor = CBUUID(string: UUIDCharateristicStr)
        let changeCirlcleChar = CBMutableCharacteristic(type: changeCircleColor, properties: [.write, .read], value: nil, permissions: [.readable, .writeable])
        
        // 2. Create instance of CBMutableService
        service = CBUUID(string: UUIDServiceStr)
        let myService = CBMutableService(type: service, primary: true)
        
        // 3. Add characteristics to the service
        myService.characteristics = [changeCirlcleChar]
        
        // 4. Add service to peripheralManager
        peripheralManager.add(myService)
        
        // 5. Start advertising
        startAdvertising()
    }
    
    /// Tells the peripheral manager  start advertising
    /// - Returns: Void
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey : "DanhBLEPeripheralApp", CBAdvertisementDataServiceUUIDsKey:[service]])
        print("Started Advertising")
    }
    
    // MARK: - CBPeripheralManagerDelegate
    /// Tells the delegate the peripheral manager’s state updated.
    /// - Parameter peripheral: The peripheral manager whose state has changed.
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
            addServices()
        @unknown default:
            print("Unknown State")
        }
    }
    
    /// Tells the delegate that a local peripheral device received an Attribute Protocol (ATT) write request for a characteristic with a dynamic value.
    /// - Parameter peripheral: The peripheral manager that received the request.
    /// - Parameter requests: A list of one or more CBATTRequest objects, each representing a request to write the value of a characteristic.
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        if (delegate != nil) {
            delegate?.onPeripheralReceiveWrite(peripheral, didReceiveWrite: requests)
        }
    }
    
    /// Tells the delegate the peripheral manager started advertising the local peripheral device’s data.
    /// - Parameter peripheral: The peripheral manager adding the service.
    /// - Parameter error: The reason the call failed, or nil if no error occurred.
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if ((error) != nil) {
            print(error ?? "")
        }
    }
}
