import App
//import Service
import Vapor
//import Foundation
import SwiftyJSON

// The contents of main are wrapped in a do/catch block because any errors that get raised to the top level will crash Xcode
//do {
//    var config = Config.default()
//    var env = try Environment.detect()
//    var services = Services.default()
//
//    try App.configure(&config, &env, &services)
//
//    let app = try Application(
//        config: config,
//        environment: env,
//        services: services
//    )
//
//    try App.boot(app)
//
//    try app.run()
//} catch {
//    print(error)
//    exit(1)
//}

var rooms: [Int: Room] = [:]

let group = MultiThreadedEventLoopGroup(numThreads: 1)

let ws = HTTPServer.webSocketUpgrader(shouldUpgrade: { req in
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

struct MyResponder: HTTPServerResponder {

    func respond(to request: HTTPRequest, on worker: Worker) -> Future<HTTPResponse> {
        let res = HTTPResponse(status: .ok, body: "This is a ZChat WebSocket server")

        return worker.eventLoop.newSucceededFuture(result: res)
    }

}

let server = try HTTPServer.start(hostname: "127.0.0.1", port: 8080, responder: MyResponder(), upgraders: [ws], on: group) { error in
    print("HTTPServer error = \(error)")
}.wait()

try server.onClose.wait()
