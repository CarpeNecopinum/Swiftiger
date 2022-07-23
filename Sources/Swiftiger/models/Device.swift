import SQLite

struct DetachedTraitError: Error {}
struct Trait: Codable {
    var name: String
    var device_id: Int64?
    var state: String

    static let table = Table("device_traits")
    static let name = Expression<String>("name")
    static let device_id = Expression<Int64>("device_id")
    static let state = Expression<String>("state")

    static func byDevice(_ device: Int64) throws -> [Trait] {
        let query = table.filter(Trait.device_id == device)
        return try db.prepare(query).map { row in
            Trait(name: row[name], device_id: row[device_id], state: row[state])
        }
    }

    func updateState(state: String) throws {
        guard device_id != nil else {
            throw DetachedTraitError()
        }
        let update = Trait.table
            .filter(Trait.device_id == self.device_id!)
            .update(Trait.state <- state)
        try db.run(update)
    }
}

struct Device: Codable {
    static let table = Table("devices")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let kind = Expression<String>("kind")
    static let actor = Expression<String>("actor")
    static let actor_data = Expression<String>("actor_data")

    var id: Int64?
    var name: String
    var kind: String
    var actor: String
    var actor_data: String
    var traits: [Trait]

    static func getAll() throws -> [Device] {
        let devices = table.select(*)
        let rows = try db.prepare(devices)
        var result = [Device]()
        for row in rows {
            result.append(Device(
                id: row[id], name: row[name], kind: row[kind], 
                actor: row[actor], actor_data: row[actor_data], 
                traits: try Trait.byDevice(row[id])))
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
            actor: row[actor], actor_data: row[actor_data], 
            traits: try Trait.byDevice(row[id]))
    }

    static func setupDb() throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name, unique: true)
            t.column(kind)
            t.column(actor)
            t.column(actor_data)
        })

        try db.run(Trait.table.create(ifNotExists: true) { t in
            t.column(Trait.name)
            t.column(Trait.device_id, references: Device.table, Device.id)
            t.column(Trait.state)
            t.primaryKey(Trait.name, Trait.device_id)
        })
    }

    mutating func save() throws {
        if let new_id = self.id {
            try db.run(Device.table.insert(or: .replace,
            Device.id <- new_id, Device.name <- name, Device.kind <- kind, 
            Device.actor <- actor, Device.actor_data <- actor_data))
        } else {
            self.id = try db.run(Device.table.insert(or: .replace,
            Device.name <- name, Device.kind <- kind, 
            Device.actor <- actor, Device.actor_data <- actor_data))
        }

        try db.run(Trait.table.filter(Trait.device_id == self.id!).drop())
        try db.run(Trait.table.insertMany(traits.map { trait in
            return [
                Trait.device_id <- self.id!,
                Trait.name <- trait.name,
                Trait.state <- trait.state 
            ]
        }))
    } 
}