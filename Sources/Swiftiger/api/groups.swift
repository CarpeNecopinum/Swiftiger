import Foundation
import Swifter


func registerGroupRoutes(_ server: HttpServer)
{
    server.GET["/groups/list"] = { r in 
        do {
            let groups = try Group.getAll()
            let json = try encoder.encode(groups)
            return HttpResponse.ok(.data(json, contentType: "application/json"))
        } catch {
            return HttpResponse.internalServerError
        }
    }

    server.POST["/groups/save"] = { r in
        do {
            let data = Data(r.body)
            var body = try decoder.decode(Group.self, from: data)
            try body.save()
            return HttpResponse.ok(.text("OK"))
        } catch {
            return HttpResponse.internalServerError
        }
    }

    struct DropGroupRequest: Codable {
        let id: Int64
    }

    server.POST["/groups/drop"] = { r in 
        do {
            let data = Data(r.body)
            let body = try decoder.decode(DropGroupRequest.self, from: data)
            try Group.drop(body.id)
            return HttpResponse.ok(.text("OK"))
        } catch {
            return HttpResponse.internalServerError
        }
    }
}
