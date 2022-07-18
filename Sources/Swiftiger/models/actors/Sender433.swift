import Foundation

struct Sender433ExecuteRequest: Decodable {
    // let device_id: Int64 - don't really care here
    let command: String
}

struct Sender433ActorData: Decodable {
    let code_on: String
    let code_off: String
    let `protocol`: Int32?
    let pulselength: Int32?
}

class Sender433: Actor {
    func execute(command: Data, device: Device) throws {
        let body = try decoder
            .decode(Sender433ExecuteRequest.self, from: command)
        let data = try decoder
            .decode(Sender433ActorData.self, from: device.actor_data.data(using: .utf8)!)

        let target_state = body.command == "on"

        let code = target_state ? data.code_on : data.code_off
        
        try Process.run(URL(fileURLWithPath: "/usr/bin/env"), arguments: [
            "codesend",
            code,
            "\(data.protocol ?? 4)",
            data.pulselength != nil ? "\(data.pulselength!)" : ""
        ]).waitUntilExit()

        try device.updateState(state: target_state ? "on" : "off")
    }
}