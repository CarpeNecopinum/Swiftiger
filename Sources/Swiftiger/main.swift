import Vapor
import Dispatch
import class Foundation.JSONEncoder

try! Device.setupDb()

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
defer { app.shutdown() }

app.get { req in
    return "Hello, world!"
}

app.get("devices", "list") { req in
    return try Device.getAll()
}

app.http.server.configuration.port = 3000
try app.run()