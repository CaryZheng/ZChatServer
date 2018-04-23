//
//  MyWebSocketServer.swift
//  Run
//
//  Created by CaryZheng on 2018/4/23.
//

import Foundation
import Vapor
import SwiftyJSON

var rooms: [Int: Room] = [:]

class MyWebSocketServer {
    
    func create() -> HTTPProtocolUpgrader {
        return HTTPServer.webSocketUpgrader(shouldUpgrade: { req in
            if req.url.path == "/deny" {
                return nil
            }
            
            return [:]
        }, onUpgrade: { ws, req in
            
            ws.send("Hello World from ZChatServer")
            
            var currentRoomId: Int = 0
            var currentClientUserId: String = ""
            
            ws.onText { ws, string in
                print("Receive text: \(string)")
                
                let json = JSON(data: string.data(using: .utf8)!)
                
                let code = json["code"].intValue
                if ProtocolCode.enterRoom.rawValue == code {
                    // Enter room
                    guard let roomNum = json["data"]["roomNum"].int else { return }
                    guard let userId = json["data"]["userId"].string else { return }
                    
                    var room: Room? = rooms[roomNum]
                    if nil == room {
                        room = Room()
                        
                        rooms[roomNum] = room
                        
                        currentClientUserId = userId
                        currentRoomId = roomNum
                    }
                    
                    room!.addUser(userId: userId, ws: ws)
                } else if ProtocolCode.leaveRoom.rawValue == code {
                    // Leave room
                    guard let roomNum = json["data"]["roomNum"].int else { return }
                    guard let userId = json["data"]["userId"].string else { return }
                    
                    guard let room: Room = rooms[roomNum] else { return }
                    
                    room.removeUser(userId: userId)
                    
                    let peopleInRoomCount = room.peopleCount()
                    if peopleInRoomCount == 0 {
                        rooms[roomNum] = nil
                    }
                }
            }
            
            ws.onBinary { ws, data in
                print("Receive data: \(data)")
            }
            
            ws.onClose.always {
                print("Closed, clientUserId = \(currentClientUserId)")
                
                if let room = rooms[currentRoomId] {
                    if room.isUserInRoom(userId: currentClientUserId) {
                        room.removeUser(userId: currentClientUserId)
                        
                        let peopleInRoomCount = room.peopleCount()
                        if peopleInRoomCount == 0 {
                            rooms[currentRoomId] = nil
                        }
                    }
                }
            }
            
        })
    }
    
}
