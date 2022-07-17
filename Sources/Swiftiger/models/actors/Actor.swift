import Foundation

protocol Actor {
    func execute(command: Data, actor_data: Data) throws
}

func actor_by_name(name: String) -> Actor? {
    switch name {
    case "Sender433":
        return Sender433()
    default:
        return nil
    }
}