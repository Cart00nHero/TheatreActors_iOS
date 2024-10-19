//
//  PeerAdvertiser.swift
//  ActorDeveloper
//
//  Created by YuCheng on 2021/5/20.
//

import Foundation
import Theatre
import MultipeerConnectivity

protocol AdvertiserProtocol {
    func beAdvertiser(
        didReceiveInvitationFrom peerID: MCPeerID,
        context: Data?,
        replyInvitation: @escaping (Bool, MCSession?) -> Void
    )
}

fileprivate class RoleOfAdvertiser: NSObject {
    
    private var advertiser: MCNearbyServiceAdvertiser!
    var delegate: AdvertiserProtocol?
    
    func actRoleOfAdvertiser(name: String, type:String) {
        /** The serviceType parameter is a short text string used to describe the app's networking protocol.
         It should be in the same format as a Bonjour service type:
         up to 15 characters long and valid characters include ASCII lowercase letters, numbers, and the hyphen.
         A short name that distinguishes itself from unrelated services is recommended;
         for example, a text chat app made by ABC company could use the service type "abc-txtchat". * */
        advertiser = MCNearbyServiceAdvertiser(
            peer: MCPeerID(displayName: name),
            discoveryInfo: nil, serviceType: type
        )
        advertiser.delegate = self
    }
    func startAdvertisingPeer() {
        advertiser.startAdvertisingPeer()
    }
    func stopAdvertisingPeer() {
        advertiser.stopAdvertisingPeer()
    }
}

extension RoleOfAdvertiser: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        delegate?.beAdvertiser(
            didReceiveInvitationFrom: peerID, context: context, replyInvitation: invitationHandler
        )
    }
    
}
class PeerAdvertiser: Actor {
    private let advertiser = RoleOfAdvertiser()
    
    init(
        _ sender: AdvertiserProtocol,
        peerName: String, serviceType:String
    ) {
        advertiser.actRoleOfAdvertiser(name: peerName, type: serviceType)
        advertiser.delegate = sender
    }
    func beStartAdvertising() {
        act { [unowned self] in
            advertiser.startAdvertisingPeer()
        }
    }
    func beStopAdvertising() {
        act { [unowned self] in
            advertiser.stopAdvertisingPeer()
        }
    }
}
