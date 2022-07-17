import Kitura
import Dispatch

let router = Router()

router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}

router.get("/devices/list") {
    request, response, next in
    let devices = try Device.getAll()
    response.send(json: devices)
    next()
}

Kitura.addHTTPServer(onPort: 3000, with: router)
Kitura.run()