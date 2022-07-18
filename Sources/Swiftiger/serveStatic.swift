import Swifter
import Foundation

public func serveStatic(_ directoryPath: String, prefix: String) -> ((HttpRequest) -> HttpResponse) {
    return { request in

        let full_path = request.path
        print("full_path: \(full_path)")
        guard full_path.starts(with: prefix) else { return .internalServerError}

        let relative_path = full_path[prefix.endIndex..<full_path.endIndex]
        guard relative_path.contains("..") == false else { return .badRequest(nil) }
        print("relative_path: \(relative_path)")
        
        let filePath = directoryPath + String.pathSeparator + relative_path

        print("filePath: \(filePath)")

        if let file = try? filePath.openForReading() {
            let mimeType = filePath.mimeType()
            var responseHeader: [String: String] = ["Content-Type": mimeType]

            if let attr = try? FileManager.default.attributesOfItem(atPath: filePath),
                let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                responseHeader["Content-Length"] = String(fileSize)
            }

            return .raw(200, "OK", responseHeader, { writer in
                try? writer.write(file)
                file.close()
            })
        }
        return .notFound
    }
}