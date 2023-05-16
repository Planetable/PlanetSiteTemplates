import Foundation
import os

public struct BuiltInTemplate: Codable, Identifiable, Hashable {
    public var name: String
    public var id: String { "\(name)" }
    public var description: String
    public var author: String
    public var version: String
    public var buildNumber: Int? = 0

    public var base: URL!
    public var blog: URL {
        base.appendingPathComponent("templates", isDirectory: true)
            .appendingPathComponent("blog.html", isDirectory: false)
    }
    public var assets: URL {
        base.appendingPathComponent("assets", isDirectory: true)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case author
        case version
        case buildNumber
    }

    static func from(url: URL) -> BuiltInTemplate {
        let metadata = url.appendingPathComponent("template.json")
        let data = try! Data(contentsOf: metadata)
        var template = try! JSONDecoder().decode(BuiltInTemplate.self, from: data)
        template.base = url
        return template
    }
}

public struct PlanetSiteTemplates {
    static let logger = Logger()

    public static var builtInTemplates: [BuiltInTemplate] = {
        logger.info("Loading built in templates")
        let resources = Bundle.module.url(forResource: "Resources", withExtension: nil)!
        let baseURLs = try! FileManager.default.listSubdirectories(url: resources)
        let templates = baseURLs.map(BuiltInTemplate.from)
        logger.info("Loaded \(templates.count) built in templates")
        return templates
    }()
}

extension FileManager {
    func listSubdirectories(url: URL) throws -> [URL] {
        let files = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        return files.filter { fileURL in
            fileURL.hasDirectoryPath
        }
    }
}
