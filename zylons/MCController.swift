//
//  MCController.swift
//  Helm & Zylon Defenders
//
//  Created by Jeff Glasse on 3/28/17.
//

import Foundation
import MultipeerConnectivity


protocol CommandDelegate: class {
    func execute(command: String)
}

class MCController: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate  {
    
    static var sharedInstance = MCController()
    let kServiceType = "zylons"
    let myPeerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        session.delegate = self
        return session
    }()
    
    
    var serviceStarted = false
    weak var myCommandDelegate: CommandDelegate?
    
    func setup() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: kServiceType)
        self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: kServiceType)
        self.advertiser.delegate = self
        self.browser.delegate = self
        self.toggleService()
    }
    
    func sendCommand(text: String) {
        
        let data = text.data(using: .utf8)!
        
        do {
            try session.send(data, toPeers: self.session.connectedPeers, with: .reliable)            
            
        } catch {
            print(error)
        }
        
    }

    func toggleService(){
        if !serviceStarted
        {
            serviceStarted = true
            advertiser.startAdvertisingPeer()
            browser.startBrowsingForPeers()
            print("MC Services Running")
            self.myCommandDelegate = self
        }
        else
        {
            serviceStarted = false
            session.disconnect()
            advertiser.stopAdvertisingPeer()
            browser.stopBrowsingForPeers()
            print("stoppedBrowsing")
        }
    }
	
    // MARK: - Advertiser Delegate
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
        
    }
	
    // MARK: - Browser Delegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        print("Found Peer: \(peerID.displayName)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        
        print("Lost Peer: \(peerID.displayName)")

    }
    
    // MARK: - Session Delegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        print("Peer \(peerID.displayName) status changed: \(state.rawValue)")
        if state == .connected
        {
            // Connected
            print("Connected!")
        }
    }
    
    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        let receivedCommand = String(data: data, encoding: .utf8)
        self.myCommandDelegate?.execute(command: receivedCommand!)
    }
    
    // Received byte stream from remote peer.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    
    // Start receiving a resource from remote peer.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    
    // Finished receiving a resource
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}

extension MCController: CommandDelegate
{
    func execute(command:String){
        print("Received command: \(command)")
    }

}


