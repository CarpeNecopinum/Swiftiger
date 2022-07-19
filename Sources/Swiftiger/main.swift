import Swifter
import Dispatch
import Foundation

try Device.setupDb()

let server = HttpServer()

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let decoder = JSONDecoder()

server.GET["/"] = { r in
    return HttpResponse.movedPermanently("/static/index.html")
}

let env = ProcessInfo.processInfo.environment
let static_server = serveStatic(env["WWW_ROOT"] ?? "./static", prefix: "/static/")
server["/static/:a"] = static_server
server["/static/:a/:b"] = static_server
server["/static/:a/:b/:c"] = static_server

server.GET["/devices/list"] = { request in
    do {
        let devices = try Device.getAll()
        let json = try encoder.encode(devices)
        return HttpResponse.ok(.data(json, contentType: "application/json"))
    } catch {
        return HttpResponse.internalServerError
    }
}

struct ExecutePostRequest: Decodable {
    let device_id: Int64
    let trait_name: String
    let command: String
}

server.POST["/devices/execute"] = { request in
    do {
        let data = Data(request.body)
        let body = try decoder.decode(ExecutePostRequest.self, from: data)
        let device = try Device.get(device_id: body.device_id)

        let actor = actor_by_name(name: device.actor)
        if let actor = actor {
            try actor.executeOn(device, trait: body.trait_name, command: body.command)
        } else {
            return HttpResponse.notFound
        }

        return HttpResponse.ok(.text("OK"))
    } catch {
        print("Error \(error)")
        return HttpResponse.internalServerError
    }
}

if (try Device.getAll().count == 0) {
    try Sender433().buildDevice("Stecker 1A", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "14088368", code_off: "14107552").stringify()).save()
    try Sender433().buildDevice("Stecker 1B", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "14088372", code_off: "14107556").stringify()).save()
    try Sender433().buildDevice("Stecker 1C", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "14088380", code_off: "14107564").stringify()).save()
    try Sender433().buildDevice("Stecker 1D", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "14107554", code_off: "14088370").stringify()).save()
    try Sender433().buildDevice("Stecker 2A", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "12882032", code_off: "12776720").stringify()).save()
    try Sender433().buildDevice("Stecker 2B", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "12882036", code_off: "13560228").stringify()).save()
    try Sender433().buildDevice("Stecker 2C", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "12882044", code_off: "13560236").stringify()).save()
    try Sender433().buildDevice("Stecker 2D", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "13560226", code_off: "12882034").stringify()).save()
    try Sender433().buildDevice("Stecker 3A", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "772976", code_off: "438928").stringify()).save()
    try Sender433().buildDevice("Stecker 3B", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "906036", code_off: "438932").stringify()).save()
    try Sender433().buildDevice("Stecker 3C", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "906044", code_off: "438940").stringify()).save()
    try Sender433().buildDevice("Stecker 3D", kind: "outlet", 
        actor_data: Sender433ActorData(code_on: "438930", code_off: "772978").stringify()).save()
}

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