import SQLite

struct Group: Codable {
    static let table = Table("groups")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let devices = Expression<String>("devices")

    var id: Int64? = nil
    var name: String
    var devices: [Int64]

    mutating func save() throws {
        if id == nil {
            let insert = Group.table.insert(
                Group.name <- name,
                Group.devices <- devices.map { String($0) }.joined(separator: ","))
            id = try db.run(insert)
        } else {
            let update = Group.table
                .filter(Group.id == id!)
                .update(
                    Group.name <- name,
                    Group.devices <- devices.map { String($0) }.joined(separator: ","))
            try db.run(update)
        }
    }

    static func drop(_ id: Int64) throws {
        let delete = Group.table.filter(Group.id == id).delete()
        try db.run(delete)
    }

    static func getAll() throws -> [Group] {
        let groups = table.select(*)
        let rows = try db.prepare(groups)
        var result = [Group]()
        for row in rows {
            result.append(Group(
                id: row[id], name: row[name], 
                devices: row[devices].split(separator: ",").map { Int64($0)! }
            ))
        }
        return result
    }

    static func setupDb() throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(devices)
        })
    }
}