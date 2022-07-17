import SQLite
import protocol Vapor.Content

struct Device: Content {
    static let table = Table("devices")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let kind = Expression<String>("kind")
    static let actor = Expression<String>("actor")
    static let actor_data = Expression<String>("actor_data")

    var id: Int64
    var name: String
    var kind: String
    var actor: String
    var actor_data: String

    static func getAll() throws -> [Device] {
        let devices = table.select(id, name, kind, actor, actor_data)
        let rows = try db.prepare(devices)
        var result = [Device]()
        for row in rows {
            result.append(Device(
                id: row[id], name: row[name], kind: row[kind], 
                actor: row[actor], actor_data: row[actor_data]))
        }
        return result
    }

    static func get(device_id: Int64) throws -> Device {
        let device = table.filter(self.id == device_id)
        let row = try db.pluck(device)
        guard let row = row else {
            throw NotFoundError("Device with id \(device_id) not found")
        }
        return Device(
            id: row[id], name: row[name], kind: row[kind], 
            actor: row[actor], actor_data: row[actor_data])
    }

    static func setupDb() throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(kind)
            t.column(actor)
            t.column(actor_data)
        })
    }
}