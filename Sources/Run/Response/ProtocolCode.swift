enum ProtocolCode: Int, Codable {
    case signin = 1001
    case enterRoom = 2001
    case leaveRoom = 2002
    
    func getMsg() -> String {
        return "\(self)"
    }
    
    func getCode() -> Int {
        return self.rawValue
    }
    
}

