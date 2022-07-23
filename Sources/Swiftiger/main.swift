import Swifter
import Dispatch
import Foundation

try Device.setupDb()
try Group.setupDb()

let server = HttpServer()

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let decoder = JSONDecoder()


registerStaticRoutes(server)
registerDeviceRoutes(server)
registerGroupRoutes(server)

let semaphore = DispatchSemaphore(value: 0)
do {
    server.listenAddressIPv4 = "0.0.0.0"
    try server.start(3000, forceIPv4: true)
    print("Server has started ( port = \(try server.port()) ). Try to connect now...")
    semaphore.wait()
} catch {
    print("Server start error: \(error)")
    semaphore.signal()
}