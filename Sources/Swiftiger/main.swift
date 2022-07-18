import Swifter
import Dispatch
import Foundation

let server = HttpServer()

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let decoder = JSONDecoder()

server.GET["/"] = { r in
    return HttpResponse.movedPermanently("/index.html")
}

let env = ProcessInfo.processInfo.environment
server["/static/:path"] = directoryBrowser(env["WWW_ROOT"] ?? "./static")

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
    // command: parsed in the actor
}

server.POST["/devices/execute"] = { request in
    do {
        let data = Data(request.body)
        let body = try decoder.decode(ExecutePostRequest.self, from: data)
        let device = try Device.get(device_id: body.device_id)

        let actor = actor_by_name(name: device.actor)
        if let actor = actor {
            try actor.execute(command: data, device: device)
        } else {
            return HttpResponse.notFound
        }

        return HttpResponse.ok(.text("OK"))
    } catch {
        print("Error \(error)")
        return HttpResponse.internalServerError
    }
}

let semaphore = DispatchSemaphore(value: 0)
do {
    try server.start(3000)
    print("Server has started ( port = \(try server.port()) ). Try to connect now...")
    semaphore.wait()
} catch {
    print("Server start error: \(error)")
    semaphore.signal()
}