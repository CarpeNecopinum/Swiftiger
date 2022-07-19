import Foundation

struct Sender433ActorData: Codable {
    var code_on: String
    var code_off: String
    var `protocol`: Int32? = nil
    var pulselength: Int32? = nil

    func stringify() -> String {
        let data = try! JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8)!
    }
}

class Sender433: Actor {
    func executeOn(_ device: Device, trait: String, command: String) throws {
        let trait = device.traits.first { $0.name == trait }
        guard (trait != nil && trait!.name == "OnOff") else {
            throw ActorError.invalidTrait
        }

        let data = try decoder
            .decode(Sender433ActorData.self, from: device.actor_data.data(using: .utf8)!)

        let command = command.lowercased()
        let target_state = command == "on"
        if (!target_state && command != "off") {
            throw ActorError.invalidCommand
        }

        let code = target_state ? data.code_on : data.code_off
        
        try Process.run(URL(fileURLWithPath: "/usr/bin/env"), arguments: [
            "codesend",
            code,
            "\(data.protocol ?? 4)",
            data.pulselength != nil ? "\(data.pulselength!)" : ""
        ]).waitUntilExit()

        try trait!.updateState(state: target_state ? "on" : "off")
    }

    func buildDevice(_ name: String, kind: String, actor_data: String) throws -> Device {
        let traits = [
            Trait(name: "OnOff", state: "off")
        ]

        return Device(
            name: name, kind: kind, actor: "Sender433", 
            actor_data: actor_data, traits: traits)
    }
}