//
//  Room.swift
//  App
//
//  Created by CaryZheng on 2018/4/23.
//

import Foundation
import Vapor
import SwiftyJSON

class JSONUtility {
    
    static func convertToString(_ value: Any) -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions()) {
            if let result = String(data: jsonData, encoding: .utf8) {
                return result
            }
        }
        
        return ""
    }
    
}

public class Room {
    private var mClientConnections: [String: WebSocket] = [:]
    
    public init() {}
    
    public func addUser(userId: String, ws: WebSocket) {
        let connection = mClientConnections[userId]
        if nil == connection {
            mClientConnections[userId] = ws
        }
        
        let result: [String: Any] = [
            "code": ProtocolCode.enterRoom.rawValue,
            "data": [
                "userId": userId
            ]
        ]
        
        let msg = JSONUtility.convertToString(result)
        
        sendMsgToOthers(excludeUserId: userId, msg: msg)
    }
    
    public func removeUser(userId: String) {
        mClientConnections[userId] = nil
        
        let result: [String: Any] = [
            "code": ProtocolCode.leaveRoom.rawValue,
            "data": [
                "userId": userId
            ]
        ]
        
        let msg = JSONUtility.convertToString(result)
        
        sendMsgToOthers(excludeUserId: userId, msg: msg)
    }
    
    /// Send message to other users
    func sendMsgToOthers(excludeUserId: String, msg: String) {
        for (key, wsValue) in mClientConnections {
            if key == excludeUserId {
                continue
            } else {
                wsValue.send(msg)
            }
        }
    }
    
    /// Send message to target user
    public func sendMsg(targetUserId: String, msg: String) {
        if let ws = mClientConnections[targetUserId] {
            ws.send(msg)
        }
    }
    
}
