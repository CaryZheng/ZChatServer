import App
//import Service
import Vapor
//import Foundation

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

let group = MultiThreadedEventLoopGroup(numThreads: 1)

let ws = MyWebSocketServer().create()

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
