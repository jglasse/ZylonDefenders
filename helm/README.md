# BluComm
<img src="http://forthebadge.com/images/badges/made-with-swift.svg" height="30">

Experiments on iOS CoreBluetooth, CoreLocation and Multipeer Connectivity APIs. All functions are working properly. Testing requires two or more iOS devices.

## Four sections in the test app:
### CoreBluetooth Test
Use the current device to broadcast as a Bluetooth peripheral device.

### Multipeer Connectivity Test
This uses Apple's [MutipeerConnectivity](https://developer.apple.com/reference/multipeerconnectivity) framework. The Multipeer Connectivity framework supports the discovery of services provided by nearby devices and supports communicating with those services through message-based data, streaming data, and resources (such as files). In iOS, the framework uses infrastructure Wi-Fi networks, peer-to-peer Wi-Fi, and Bluetooth personal area networks for the underlying transport. In macOS and tvOS, it uses infrastructure Wi-Fi, peer-to-peer Wi-Fi, and Ethernet. Each `MCSession` supports up to 8 peers, including the local peer.

### iBeacon Receiving Test
This test determines the distance between the current device and a Bluetooth peripheral device. It requires two iOS devices, one acting as a Bluetooth peripheral device and the other as the receiving device.

This class makes use of CBCentralManager (Core Bluetooth).

### Virtual iBeacon Test
This test turns the current device into a virtual iBeacon. The virtual iBeacon broadcasts same information setup in the AppDelegate (```UUID```, ```major``` and ```minor``` values).
 
This class mainly uses ```CoreBluetooth``` framework, however, constructing the beacon requires ```CoreLocation``` framework.
#
The `AppDelegate` stores all managers, sessions, advertisers and browsers. It has an important role for all the tests above.
