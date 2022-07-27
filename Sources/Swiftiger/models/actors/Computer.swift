import Foundation

struct ComputerActorData: Codable {
    var mac: String
    var host: String
}

class Computer: Actor {
    func executeOn(_ device: Device, trait: String, command: String) throws {
        let maybe_trait = device.traits.first { $0.name == trait }
        guard let trait = maybe_trait else {
            throw ActorError.invalidTrait
        }

        let data = try decoder
            .decode(ComputerActorData.self, from: device.actor_data.data(using: .utf8)!)

        if (trait.name == "On") {
            try Process.run(URL(fileURLWithPath: "/usr/bin/env"), arguments: [
                "wakeonlan",
                data.mac
            ]).waitUntilExit() 
        }
    }
}