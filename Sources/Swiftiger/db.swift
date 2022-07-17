import SQLite

let db = try! Connection("db.sqlite")

class NotFoundError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}