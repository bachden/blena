//
//  WebBluetooth.swift
//  BlenaBrowser
//
//  Copyright 2016-2017 Paul Theriault and David Park. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import CoreBluetooth
import WebKit

protocol WBPicker {
    func showPicker()
    func updatePicker()
    func addRow(_ row: String)
}

protocol ConnectDeviceDelegate: AnyObject {
    func dismissVC()
}


open class WBManager: NSObject, CBCentralManagerDelegate, WKScriptMessageHandler, UITableViewDelegate, UITableViewDataSource
{
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.pickerDevices.count
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let dev = self.pickerDevices[indexPath.row]
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothTableViewColumn", for: indexPath) as? BluetoothTableViewCell else {
//            return UITableViewCell(
//            )
//        }
//        // Configure the cell with the history object
//        cell.configure(with: dev.displayName , uuid: dev.internalUUID.uuidString, description: dev.description, connecAction: {
//            self.selectDeviceAt(indexPath.row)
//            self.centralManager.connect(dev.peripheral)
//        }, closeTableView: {
//            self.connectDeviceViewControllerDelegate?.dismissVC()
//        })
//        cell.selectionStyle = .none
//        return cell
//    }
//
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let tappedCell = tableView.cellForRow(at: indexPath) as? BluetoothTableViewCell else { return }
//
//       // Toggle the details of the tapped cell
//       tappedCell.toggleDetails()
//    }

    // MARK: - UITableViewDataSource & UITableViewDelegate
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // One section for last connected devices and another for nearby devices.
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.lastConnectedDevice.count // Last connected devices
        case 1:
            return self.pickerDevices.count // Nearby devices
        default:
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dev: WBDevice
        let cellIdentifier = "BluetoothTableViewColumn"

        // Determine the device based on the section.
        if indexPath.section == 0 {
            dev = self.lastConnectedDevice[indexPath.row] // Last connected device
        } else {
            dev = self.pickerDevices[indexPath.row] // Nearby device
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BluetoothTableViewCell else {
            return UITableViewCell()
        }

        // Configure the cell with the device details.
        cell.configure(
            with: dev.displayName,
            uuid: dev.internalUUID.uuidString,
            description: dev.description,
            connecAction: {
                self.selectDeviceAt(dev)
                self.centralManager.connect(dev.peripheral)
            },
            closeTableView: {
                self.connectDeviceViewControllerDelegate?.dismissVC()
            }
        )
        cell.selectionStyle = .none
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tappedCell = tableView.cellForRow(at: indexPath) as? BluetoothTableViewCell else {
            return
        }

        // Toggle the details of the tapped cell.
        tappedCell.toggleDetails()

        // Optionally, you might handle connection directly here or use the action set up in `cell.configure`.
    }

    // MARK: - Section Header Titles (Optional)
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Previously Connected Devices"
        case 1:
            return "Unknown Devices"
        default:
            return nil
        }
    }



    // MARK: - Embedded types
    enum ManagerRequests: String {
        case device, requestDevice, getAvailability, vibrate, log
    }

    // MARK: - Properties
    let debug = true
    let centralManager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    var devicePicker: WBPicker
    var connectDeviceViewControllerDelegate : ConnectDeviceDelegate?


    /*! @abstract The devices selected by the user for use by this manager. Keyed by the UUID provided by the system. */
    var devicesByInternalUUID = [UUID: WBDevice]()

    /*! @abstract The devices selected by the user for use by this manager. Keyed by the UUID we create and pass to the web page. This seems to be for security purposes, and seems sensible. */
    var devicesByExternalUUID = [UUID: WBDevice]()

    /*! @abstract The outstanding request for a device from the web page, if one is outstanding. Ony one may be outstanding at any one time and should be policed by a modal dialog box. TODO: how modal is the current solution?
     */
    var requestDeviceTransaction: WBTransaction? = nil

    /*! @abstract Filters in use on the current device request transaction.  If nil, that means we are accepting all devices.
     */
    var filters: [[String: AnyObject]]? = nil
    var lastConnectedDevice = [WBDevice]()
    var pickerDevices = [WBDevice]()
    var deviceCachedName = ""

    var bluetoothAuthorized: Bool {
        get {
            switch CBCentralManager.authorization {
            case CBManagerAuthorization.allowedAlways:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Constructors / destructors
    init(devicePicker: WBPicker, connectDeviceDelegate: ConnectDeviceDelegate) {
        self.devicePicker = devicePicker
        self.connectDeviceViewControllerDelegate = connectDeviceDelegate
        super.init()
        self.centralManager.delegate = self
    }

    // MARK: - Public API
    public func selectDeviceAt(_ device: WBDevice) {
        device.view = self.requestDeviceTransaction?.webView
        self.requestDeviceTransaction?.resolveAsSuccess(withObject: device)
        self.deviceWasSelected(device)
    }
    public func cancelDeviceSearch() {
        NSLog("User cancelled device selection")
        // ⚠️ The user cancelled message is detected by the javascript layer to send the right
        // error to the application, so it will need to be changed there as well if changing here.
        self.requestDeviceTransaction?.resolveAsFailure(withMessage: "User cancelled")
        self.stopScanForPeripherals()
        self._clearPickerView()
    }

    public func refreshData() {
        self.cancelDeviceSearch()
        if(self.filters == nil){
            self.scanForAllPeripherals()
        } else {
            scanForPeripherals(with: self.filters!)
        }
    }

    // MARK: - WKScriptMessageHandler
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let trans = WBTransaction(withMessage: message) else {
            /* The transaction will have handled the error */
            return
        }
        self.triage(transaction: trans)
    }

    // MARK: - CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        NSLog("Bluetooth is \(central.state == CBManagerState.poweredOn ? "ON" : "OFF")")
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {

        if let filters = self.filters,
            !self._peripheral(peripheral, isIncludedBy: filters) {
            return
        }

        guard self.pickerDevices.first(where: {$0.peripheral.identifier.uuidString == peripheral.identifier.uuidString}) == nil else {
            return
        }

        let device = WBDevice(
            peripheral: peripheral, advertisementData: advertisementData,
            RSSI: RSSI, manager: self)
        if(advertisementData[CBAdvertisementDataLocalNameKey] as? String != nil){
            NSLog("Advertisement data: \(advertisementData)")
        }
        
        for deviceItem in LastConnectedDevicesList.shared.getDevices() {
            if deviceItem.address == device.peripheral.identifier.uuidString {
                // Check if the device already exists in the `lastConnectedDevice` list
                if let index = self.lastConnectedDevice.firstIndex(where: { $0.peripheral.identifier.uuidString == device.peripheral.identifier.uuidString }) {
                    // Replace the existing device at the found index
                    self.lastConnectedDevice[index] = device
                } else {
                    // If the device doesn't exist in the list, add it
                    self.lastConnectedDevice.append(device)
                }
                // Update the picker data after the change
                self.updatePickerData()
                return
            }
        }
        
        if let index = self.pickerDevices.firstIndex(where: { $0.peripheral.identifier.uuidString == device.peripheral.identifier.uuidString }) {
            // Replace the existing device at the found index
            self.pickerDevices[index] = device
        } else {
            // If the device doesn't exist in the list, add it
            self.pickerDevices.append(device)
        }
        // Update the picker data after the change
        self.updatePickerData()
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard
            let device = self.devicesByInternalUUID[peripheral.identifier]
        else {
            NSLog("Unexpected didConnect notification for \(peripheral.name ?? "<no-name>") \(peripheral.identifier)")
            return
        }
        NSLog("Connected to /\(device.peripheral.identifier.uuidString)")
        device.didConnect()
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard
            let device = self.devicesByInternalUUID[peripheral.identifier]
            else {
                NSLog("Unexpected didDisconnect notification for unknown device \(peripheral.name ?? "<no-name>") \(peripheral.identifier)")
                return
        }
        device.didDisconnect(error: error)
        self.devicesByInternalUUID[peripheral.identifier] = nil
        self.devicesByExternalUUID[device.deviceId] = nil
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("FAILED TO CONNECT PERIPHERAL UNHANDLED \(error?.localizedDescription ?? "<no error>")")
    }

    // MARK: - UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // dummy response for making screen shots from the simulator
        // return row == 0 ? "Puck.js 69c5 (82DF60A5-3C0B..." : "Puck.js c728 (9AB342DA-4C27..."
        return self._pv(pickerView, titleForRow: row, forComponent: component)
    }
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // dummy response for making screen shots from the simulator
        // return 2
        return self.pickerDevices.count
    }

    // MARK: - Private
    private func triage(transaction: WBTransaction){

        guard
            transaction.key.typeComponents.count > 0,
            let managerMessageType = ManagerRequests(
                rawValue: transaction.key.typeComponents[0])
        else {
            transaction.resolveAsFailure(withMessage: "Request type components not recognised \(transaction.key)")
            return
        }

        switch managerMessageType
        {
        case .device:

            guard let view = WBDevice.DeviceTransactionView(transaction: transaction) else {
                transaction.resolveAsFailure(withMessage: "Bad device request")
                break
            }

            let devUUID = view.externalDeviceUUID
            guard let device = self.devicesByExternalUUID[devUUID]
            else {
                transaction.resolveAsFailure(
                    withMessage: "No known device for device transaction \(transaction)"
                )
                break
            }
            device.triage(view)
        case .getAvailability:
            transaction.resolveAsSuccess(withObject: self.bluetoothAuthorized)
        case .requestDevice:
            guard transaction.key.typeComponents.count == 1
            else {
                transaction.resolveAsFailure(withMessage: "Invalid request type \(transaction.key)")
                break
            }
            let acceptAllDevices = transaction.messageData["acceptAllDevices"] as? Bool ?? false

            let filters = transaction.messageData["filters"] as? [[String: AnyObject]]

            // PROTECT force unwrap see below
            guard acceptAllDevices || filters != nil
            else {
                transaction.resolveAsFailure(withMessage: "acceptAllDevices false but no filters passed: \(transaction.messageData)")
                break
            }
            guard self.requestDeviceTransaction == nil
            else {
                transaction.resolveAsFailure(withMessage: "Previous device request is still in progress")
                break
            }

            if self.debug {
                NSLog("Requesting device with filters \(filters?.description ?? "nil")")
            }

            self.requestDeviceTransaction = transaction
            if acceptAllDevices {
                self.scanForAllPeripherals()
            }
            else {
                // force unwrap, but protected by guard above marked PROTECT
                self.scanForPeripherals(with: filters!)
            }
            transaction.addCompletionHandler {_, _ in
                self.stopScanForPeripherals()
                self.requestDeviceTransaction = nil
            }
            self.devicePicker.showPicker()
        case .vibrate:
            vibrate(style: VibrateStyle.test)
        case .log:
            NSLog(transaction.messageData.jsonify())
        }
    }

    func clearState() {
        NSLog("WBManager clearState()")
        self.stopScanForPeripherals()
        self.requestDeviceTransaction?.abandon()
        self.requestDeviceTransaction = nil
        // the external and internal devices are the same, but tidier to do this in one loop; calling clearState on a device twice is OK.
        for var devMap in [self.devicesByExternalUUID, self.devicesByInternalUUID] {
            for (_, device) in devMap {
                device.clearState()
            }
            devMap.removeAll()
        }
        self._clearPickerView()
    }

    public func disconnectAllDevices() {
        for (_, device) in devicesByInternalUUID {
                let peripheral = device.peripheral
                if peripheral.state == .connected {
                    centralManager.cancelPeripheralConnection(peripheral)
                    print("Disconnecting device: \(device.name ?? "<no name>")")
                }
            }
        }

    private func deviceWasSelected(_ device: WBDevice) {
        // TODO: think about whether overwriting any existing device is an issue.
        self.devicesByExternalUUID[device.deviceId] = device;
        self.devicesByInternalUUID[device.internalUUID] = device;
    }

    func scanForAllPeripherals() {
        disconnectAllDevices()
        self._clearPickerView()
        self.filters = nil
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func scanForPeripherals(with filters:[[String: AnyObject]]) {
        disconnectAllDevices()
        let services = filters.reduce([String](), {
            (currReduction, nextValue) in
            if let nextServices = nextValue["services"] as? [String] {
                return currReduction + nextServices
            }
            return currReduction
        })

        let servicesCBUUID = self._convertServicesListToCBUUID(services)

        if (self.debug) {
            NSLog("Scanning for peripherals... (services: \(servicesCBUUID))")
        }

        self._clearPickerView();
        self.filters = filters
        centralManager.scanForPeripherals(withServices: servicesCBUUID, options: nil)
    }
    private func stopScanForPeripherals() {
        if self.centralManager.state == .poweredOn {
            self.centralManager.stopScan()
        }
        self._clearPickerView()

    }

    func updatePickerData(){
        self.pickerDevices.sort(by: {
            if $0.name != nil && $1.name == nil {
                // $1 is "bigger" in that its name is nil
                return true
            }
            // cannot be sorting ids that we haven't discovered
            if $0.name == $1.name {
                return $0.internalUUID.uuidString < $1.internalUUID.uuidString
            }
            if $0.name == nil {
                // $0 is "bigger" as it's nil and the other isn't
                return false
            }
            // forced unwrap protected by logic above
            return $0.name! < $1.name!
        })
        self.devicePicker.updatePicker()
    }

    private func _convertServicesListToCBUUID(_ services: [String]) -> [CBUUID] {
        return services.map {
            servStr -> CBUUID? in
            guard let uuid = UUID(uuidString: servStr.uppercased()) else {
                return nil
            }
            return CBUUID(nsuuid: uuid)
            }.filter{$0 != nil}.map{$0!};
    }

    private func _peripheral(_ peripheral: CBPeripheral, isIncludedBy filters: [[String: AnyObject]]) -> Bool {
        for filter in filters {

            if let name = filter["name"] as? String {
                guard peripheral.name == name else {
                    continue
                }
            }
            if let namePrefix = filter["namePrefix"] as? String {
                guard
                    let pname = peripheral.name,
                    pname.hasPrefix(namePrefix)
                else {
                    continue
                }
            }
            // All the checks passed, don't need to check another filter.
            return true
        }
        return false
    }

    private func _pv(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {

        let dev = self.pickerDevices[row]
        let id = dev.internalUUID
        guard let name = dev.name
        else {
            return "(\(id))"
        }
        return "\(name) (\(id))"
    }
    private func _clearPickerView() {
        self.pickerDevices = []
        self.lastConnectedDevice = []
        self.updatePickerData()
    }
}


