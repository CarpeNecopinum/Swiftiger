import Foundation
import Swifter

func registerDeviceRoutes(_ server: HttpServer) {
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
}
