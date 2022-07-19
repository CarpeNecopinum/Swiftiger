import Foundation

protocol Actor {
    func executeOn(_ device: Device, trait: String, command: String) throws
    func buildDevice(_ name: String, kind: String, actor_data: String) throws -> Device
}

enum ActorError: Error {
    case invalidTrait
    case invalidCommand
}

func actor_by_name(name: String) -> Actor? {
    switch name {
    case "Sender433":
        return Sender433()
    default:
        return nil
    }
}