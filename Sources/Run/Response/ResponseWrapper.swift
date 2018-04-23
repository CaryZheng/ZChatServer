import Foundation

class ResponseWrapper<T: Codable>: Codable {
    private var code: ProtocolCode!
    private var msg: String = ""
    private var obj: T?
    
    init(protocolCode: ProtocolCode) {
        self.code = protocolCode
        self.msg = protocolCode.getMsg()
    }
    
    init(protocolCode: ProtocolCode, obj: T) {
        self.code = protocolCode
        self.obj = obj
        self.msg = protocolCode.getMsg()
    }
    
    init(protocolCode: ProtocolCode, msg: String) {
        self.code = protocolCode
        self.msg = msg
    }
    
    func makeResponse() -> String {
        var result = ""
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            result = String(data: data, encoding: .utf8)!
            print("result = \(String(describing: result))")
        } catch {
            print("Encode error")
        }
        
        return result
    }
    
}
