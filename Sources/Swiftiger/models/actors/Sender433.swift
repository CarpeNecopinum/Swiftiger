import Foundation

struct Sender433ExecuteRequest: Decodable {
    // let device_id: Int64 - don't really care here
    let command: String
}

struct Sender433ActorData: Decodable {
    let code_on: String
    let code_off: String
}

class Sender433: Actor {
    func execute(command: Data, actor_data: Data) throws {
        let body = try decoder.decode(Sender433ExecuteRequest.self, from: command)
        let data = try decoder.decode(Sender433ActorData.self, from: actor_data)

        print("Executing command for device \(body.command) with code_on \(data.code_on) and code_off \(data.code_off)")
    }
}