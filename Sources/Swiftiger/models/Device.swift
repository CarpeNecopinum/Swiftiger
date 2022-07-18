import SQLite

struct Device: Codable {
    static let table = Table("devices")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let kind = Expression<String>("kind")
    static let actor = Expression<String>("actor")
    static let actor_data = Expression<String>("actor_data")
    static let state = Expression<String>("state")

    var id: Int64
    var name: String
    var kind: String
    var actor: String
    var actor_data: String
    var state: String

    static func getAll() throws -> [Device] {
        let devices = table.select(*)
        let rows = try db.prepare(devices)
        var result = [Device]()
        for row in rows {
            result.append(Device(
                id: row[id], name: row[name], kind: row[kind], 
                actor: row[actor], actor_data: row[actor_data], state: row[state]))
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
            actor: row[actor], actor_data: row[actor_data], state: row[state])
    }

    static func setupDb() throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(kind)
            t.column(actor)
            t.column(actor_data)
            t.column(state)
        })
    }

    func updateState(state: String) throws {
        let update = Device.table
            .filter(Device.id == self.id)
            .update(Device.state <- state)
        try db.run(update)
    }
}