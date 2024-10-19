//
//  PeerBrowser.swift
//  ActorDeveloper
//
//  Created by YuCheng on 2021/5/20.
//

import Foundation
import Theatre
import MultipeerConnectivity

protocol BrowserProtocol {
    @discardableResult
    func beBrowser(
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) -> Self
    @discardableResult
    func beBrowser(lostPeer peerID: MCPeerID) -> Self
}
fileprivate class RoleOfBrowser: NSObject {
    
    private var browser: MCNearbyServiceBrowser!
    var delegate: BrowserProtocol?
    
    func actRoleOfBrowser(name: String,type:String) {
        browser = MCNearbyServiceBrowser(
            peer: MCPeerID(displayName: name), serviceType: type
        )
        browser.delegate = self
    }
    func startBrowsingForPeers() {
        browser.startBrowsingForPeers()
    }
    func stopBrowsingForPeers() {
        browser.stopBrowsingForPeers()
    }
    func invitePeer(
        _ peerID: MCPeerID, _ session: MCSession, _ context: Data?, _ timeout: TimeInterval
    ) {
        browser.invitePeer(peerID, to: session, withContext: context, timeout: timeout)
    }
}

extension RoleOfBrowser: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        delegate?.beBrowser(foundPeer: peerID, withDiscoveryInfo: info)
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.beBrowser(lostPeer: peerID)
    }
}
class PeerBrowser: Actor {
    private let browser = RoleOfBrowser()
    
    init(
        _ sender: BrowserProtocol, peerName: String,
        serviceType:String
    ) {
        browser.actRoleOfBrowser(name: peerName, type: serviceType)
        browser.delegate = sender
    }
    func beStartBrowsing() {
        act { [unowned self] in
            browser.startBrowsingForPeers()
        }
    }
    func beStopBrowsing() {
        act { [unowned self] in
            browser.stopBrowsingForPeers()
        }
    }
    func beInvite(
        peerID: MCPeerID, to session: MCSession,
        context: Data?, timeout: TimeInterval
    ) {
        act { [unowned self] in
            browser.invitePeer(peerID, session, context, timeout)
        }
    }
}
