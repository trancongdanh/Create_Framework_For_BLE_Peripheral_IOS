#  Danh Peripheral Manager Framework

Swift-iOS app, acting likes a BLE Peripheral (you can think it as a server in socket programming), advertising "BLE" 10 times/s, having a characteristic to receive the data. If it receives "RED", turn the LED (the circle in the middle of the app) to RED, if it receives "GREEN", turn the LED to green, otherwise let's the LED grey.

Design Requirements

Library: contains only the business logic (Bluetooth, events...) - no GUI in the lib, will produce the APIs wrapped in a Framework for iOS.
Application: consumes the library, take the logic from the library and use it to display on the GUI.


## Requirement

- Minimum IOS 10.3.


## How to install

- Create a new swift project.
- Drag and drop DanhPeripheralManager.swift to app.
+ Open xcode:
    + If you run  Xcode 11+ :
        + The only thing to do is to add the framework to the General->Frameworks, Libraries And Embedded Content section in the General tab of your app target.
        + Make sure you select the 'Embed & Sign' option.
        + [Image for xcode 11](https://i.stack.imgur.com/ZuCyy.png)
        
    + If you run Xcode v6 -> Xcode v10 :
        + The only thing to do is to add the framework to the Embedded binaries section in the General tab of your app target.
        + [Image for xcode v6 -> v10](https://i.stack.imgur.com/T4g6I.png)

+  Open Info.plist:
    + Add key NSBluetoothAlwaysUsageDescription.
    + Add key NSBluetoothPeripheralUsageDescription.


## How to work

### Open file ViewController.swift:

- Add DanhPeripheralManagerDelegate to class ViewController:

 ```swift
 class ViewController: UIViewController, DanhPeripheralManagerDelegate
 ```
 - Add protocol of DanhPeripheralManagerDelegate to class. In the protocol, you need parse value from bytes[] to String with utf-8 encoding.
 You can receive value RED or GREEN.
 
 ```swift
 func onPeripheralReceiveWrite(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

     if let value = requests.first?.value {
         let myBytes = [UInt8](value)
         let valueStr = String(bytes: myBytes, encoding: .utf8)
         if ("RED" == valueStr) {
             circleView.backgroundColor = UIColor.red
             AudioServicesPlaySystemSound (systemSoundID)

         } else if ("GREEN" == valueStr) {
             circleView.backgroundColor = UIColor.green
             AudioServicesPlaySystemSound (systemSoundID)

         } else {
             circleView.backgroundColor = UIColor.gray
             AudioServicesPlaySystemSound (systemSoundID)
         }
     }
 }
 ```

-  In func viewDidLoad(), call  startPeripheralManager method of the framework:
     
     ```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        DanhPeripheralManager.shared.startPeripheralManager(newDelegate: self)
    }
    ```

## Feedback

If you like the framework, please send email trandanh882006@gmail.com to info me.

And if you don’t like it, please also let me know what you would like improved, so I can fix it!
