//
//  PeerHost.swift
//  ActorDeveloper
//
//  Created by YuCheng on 2021/5/20.
//

import Foundation
import Theatre
import MultipeerConnectivity

protocol PeerHostProtocol {
    
    func beSession(peer peerID: MCPeerID, didChange state: MCSessionState)
    func beSession(didReceive data: Data, fromPeer peerID: MCPeerID)
    func beSession(
        didReceive stream: InputStream,
        withName streamName: String, fromPeer peerID: MCPeerID
    )
    func beSession(
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress
    )
    func beSession(
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?
    )
}
fileprivate class RoleOfHost: NSObject {
    
    private var session: MCSession!
    var delegate: PeerHostProtocol?
    
    func actPeerHost(
        name: String,serviceType:String,
        encryptionPreference: MCEncryptionPreference
    ) {
        session = MCSession(
            peer: MCPeerID(displayName: name), securityIdentity: nil,
            encryptionPreference: encryptionPreference
        )
        session.delegate = self
    }
    func sendData(
        _ data: Data,toPeers:[MCPeerID],mode: MCSessionSendDataMode
    ) {
        do {
            try session.send(data, toPeers: toPeers, with: mode)
        } catch let error {
            fatalError("send data error:\(error.localizedDescription)")
        }
    }
    func disconnect() {
        session.disconnect()
    }
    func mcSession() -> MCSession {
        return session
    }
}
extension RoleOfHost: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        delegate?.beSession(peer: peerID, didChange: state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.beSession(didReceive: data, fromPeer: peerID)
    }
    
    func session(
        _ session: MCSession, didReceive stream: InputStream,
        withName streamName: String, fromPeer peerID: MCPeerID
    ) {
        delegate?.beSession(didReceive: stream, withName: streamName, fromPeer: peerID)
    }
    
    func session(
        _ session: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress
    ) {
        delegate?.beSession(
            didStartReceivingResourceWithName: resourceName,
            fromPeer: peerID, with: progress
        )
    }
    
    func session(
        _ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?
    ) {
        delegate?.beSession(
            didFinishReceivingResourceWithName: resourceName,
            fromPeer: peerID, at: localURL, withError: error
        )
    }
}
class PeerHost: Actor {
    private let host = RoleOfHost()
    init(
        _ sender: PeerHostProtocol, peerName: String,
        serviceType: String,
        encryption: MCEncryptionPreference
    ) {
        host.actPeerHost(
            name: peerName, serviceType: serviceType,
            encryptionPreference: encryption)
        host.delegate = sender
    }
    func beHostSession() -> MCSession {
        let myTel = install(MCSession())
        act { [unowned self] in
            myTel.portal = host.mcSession()
        }
        return myTel.portal
    }
    
    func beSend(
        data: Data, toPeers peers:[MCPeerID],
        mode: MCSessionSendDataMode
    ) {
        act { [unowned self] in
            host.sendData(data, toPeers: peers, mode: mode)
        }
    }
    func beDisconnect() {
        act { [unowned self] in
            host.disconnect()
        }
    }
}
