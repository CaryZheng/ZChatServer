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

var clientConnections: [String: WebSocket] = [:]

let group = MultiThreadedEventLoopGroup(numThreads: 1)

let ws = HTTPServer.webSocketUpgrader(shouldUpgrade: { req in
    if req.url.path == "/deny" {
        return nil
    }

    return [:]
}, onUpgrade: { ws, req in

    let path = req.url.pathComponents

    let clientUserId = path[1]
    let connection = clientConnections[clientUserId]
    if nil == connection {
        clientConnections[clientUserId] = ws
    }

    ws.send("Hello Client from ZChatServer")

    ws.onText { ws, string in
        print("Receive text: \(string)")

        let json = JSON(data: string.data(using: .utf8)!)
        
        let code = json["code"].intValue
        if 1001 == code {
            // singin
            let userId = json["data"]["userId"].stringValue
            
            for (key, wsValue) in clientConnections {
                if key == userId {
                    continue
                } else {
                    wsValue.send("The user_\(userId) is online")
                }
            }
        }
        
//        let targetUserId = json["userId"].string
//        if let targetUserId = targetUserId {
//            if let connection = clientConnections[targetUserId] {
//                connection.send("Send UserId: \(clientUserId) msg: Hi")
//            } else {
//                ws.send("The user_\(targetUserId) is not online")
//            }
//        } else {
//            ws.send("Error")
//        }
    }

    ws.onBinary { ws, data in
        print("Receive data: \(data)")
    }

    ws.onClose.always {
        print("Closed, clientUserId = \(clientUserId)")

        clientConnections[clientUserId] = nil
    }

})

struct MyResponder: HTTPServerResponder {

    func respond(to request: HTTPRequest, on worker: Worker) -> Future<HTTPResponse> {
       let res = HTTPResponse(status: .ok, body: "This is a WebSocket server")

        return worker.eventLoop.newSucceededFuture(result: res)
    }

}

let server = try HTTPServer.start(hostname: "127.0.0.1", port: 8080, responder: MyResponder(), upgraders: [ws], on: group) { error in

    print("HTTPServer error = \(error)")
}.wait()

try server.onClose.wait()
