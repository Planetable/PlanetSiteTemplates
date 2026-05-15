import Foundation
import PathKit
import Stencil
import XCTest
@testable import PlanetSiteTemplates

final class PlanetSiteTemplatesTests: XCTestCase {
    func testBuiltInTemplatesLoadBundledMetadata() {
        let templates = PlanetSiteTemplates.builtInTemplates

        XCTAssertFalse(templates.isEmpty)

        for template in templates {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: template.blog.path),
                "\(template.name) should include templates/blog.html"
            )
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: template.assets.path),
                "\(template.name) should include an assets directory"
            )
        }
    }

    func testBuiltInTemplateStencilSyntaxRendersWithPreviewContext() throws {
        var failures: [String] = []

        for template in PlanetSiteTemplates.builtInTemplates.sorted(by: { $0.name < $1.name }) {
            let templatesDirectory = template.base.appendingPathComponent("templates", isDirectory: true)
            let templateFiles = try stencilTemplateFiles(in: templatesDirectory)
            let environment = Environment(
                loader: FileSystemLoader(paths: [Path(templatesDirectory.path)]),
                extensions: [TestStencilExtension.common]
            )
            let context = TestPreviewContext.make(templateName: template.name)

            XCTAssertFalse(templateFiles.isEmpty, "\(template.name) should include Stencil template files")

            for fileURL in templateFiles {
                let templateName = relativeTemplateName(for: fileURL, in: templatesDirectory)

                do {
                    _ = try environment.renderTemplate(name: templateName, context: context)
                } catch {
                    failures.append("\(template.name)/templates/\(templateName): \(error)")
                }
            }
        }

        XCTAssertTrue(failures.isEmpty, failures.joined(separator: "\n"))
    }

    private func stencilTemplateFiles(in templatesDirectory: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: templatesDirectory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []

        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true else {
                continue
            }

            files.append(fileURL)
        }

        return files.sorted { $0.path < $1.path }
    }

    private func relativeTemplateName(for fileURL: URL, in templatesDirectory: URL) -> String {
        let directoryPath = templatesDirectory.standardizedFileURL.path
        let filePath = fileURL.standardizedFileURL.path
        let prefix = directoryPath + "/"

        guard filePath.hasPrefix(prefix) else {
            return fileURL.lastPathComponent
        }

        return String(filePath.dropFirst(prefix.count))
    }
}

private enum TestArticleType: Int, Codable {
    case blog = 0
    case page = 1
}

private struct TestPublicArticle: Codable {
    var articleType: TestArticleType? = .blog
    let id: UUID
    let link: String
    var slug: String? = ""
    var articleNumber: Int? = nil
    var articleReference: String? = nil
    var externalLink: String? = ""
    let title: String
    let content: String
    let contentRendered: String?
    let created: Date
    var modified: Date? = nil
    let hasVideo: Bool?
    let videoFilename: String?
    let hasAudio: Bool?
    let audioFilename: String?
    let audioDuration: Int?
    let audioByteLength: Int?
    let attachments: [String]?
    let heroImage: String?
    let heroImageWidth: Int?
    let heroImageHeight: Int?
    let heroImageURL: String?
    let heroImageFilename: String?
    var cids: [String: String]? = [:]
    var tags: [String: String]? = [:]
    var originalSiteName: String? = nil
    var originalSiteDomain: String? = nil
    var originalPostID: String? = nil
    var originalPostDate: Date? = nil
    var pinned: Date? = nil
}

private struct TestPublicPlanet: Codable {
    let id: UUID
    let name: String
    let about: String
    let ipns: String
    let created: Date
    let updated: Date
    let articles: [TestPublicArticle]
    let plausibleEnabled: Bool?
    let plausibleDomain: String?
    let plausibleAPIServer: String?
    let juiceboxEnabled: Bool?
    let juiceboxProjectID: Int?
    let juiceboxProjectIDGoerli: Int?
    let acceptsDonation: Bool?
    let acceptsDonationMessage: String?
    let acceptsDonationETHAddress: String?
    let twitterUsername: String?
    let githubUsername: String?
    let telegramUsername: String?
    let mastodonUsername: String?
    let discordLink: String?
    let podcastCategories: [String: [String]]?
    let podcastLanguage: String?
    let podcastExplicit: Bool?
    let tags: [String: String]?
}

private struct TestNavigationItem: Codable {
    let id: UUID
    let title: String
    let slug: String
    let externalLink: String
}

private enum TestPreviewContext {
    static func make(templateName: String) -> [String: Any] {
        let articleID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let pageID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        let content = """
            Demo Article Content

            ### List

            - Item A
            - Item B
            - Item C

            ### Code Block

            ```python
            from flask import Flask

            app = Flask(__name__)
            ```
            """
        let contentRendered = """
            <p>Demo Article Content</p>
            <h3>List</h3>
            <ul><li>Item A</li><li>Item B</li><li>Item C</li></ul>
            <h3>Code Block</h3>
            <pre><code>from flask import Flask

            app = Flask(__name__)
            </code></pre>
            """
        let article = TestPublicArticle(
            id: articleID,
            link: "\(articleID.uuidString)/",
            slug: "demo-article",
            articleNumber: 1,
            articleReference: "Demo Reference",
            externalLink: "",
            title: "Template Preview \(templateName)",
            content: content,
            contentRendered: contentRendered,
            created: created,
            modified: created,
            hasVideo: true,
            videoFilename: "demo.mov",
            hasAudio: true,
            audioFilename: "demo.mp3",
            audioDuration: 90,
            audioByteLength: 1024,
            attachments: ["photo.jpg"],
            heroImage: "photo.jpg",
            heroImageWidth: 1200,
            heroImageHeight: 800,
            heroImageURL: "https://example.com/photo.jpg",
            heroImageFilename: "photo.jpg",
            cids: ["photo.jpg": "bafyexample"],
            tags: ["swift": "Swift", "templates": "Templates"],
            pinned: created
        )
        let page = TestPublicArticle(
            articleType: .page,
            id: pageID,
            link: "\(pageID.uuidString)/",
            slug: "about",
            articleNumber: 2,
            articleReference: "",
            externalLink: "",
            title: "About",
            content: "About page",
            contentRendered: "<p>About page</p>",
            created: created,
            modified: created,
            hasVideo: false,
            videoFilename: nil,
            hasAudio: false,
            audioFilename: nil,
            audioDuration: nil,
            audioByteLength: nil,
            attachments: [],
            heroImage: nil,
            heroImageWidth: nil,
            heroImageHeight: nil,
            heroImageURL: nil,
            heroImageFilename: nil,
            tags: [:]
        )
        let articles = [article, page]
        let planet = TestPublicPlanet(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            name: "Template Preview \(templateName)",
            about: "Template Preview \(templateName)",
            ipns: "k51qzi",
            created: created,
            updated: created,
            articles: articles,
            plausibleEnabled: false,
            plausibleDomain: nil,
            plausibleAPIServer: "plausible.io",
            juiceboxEnabled: true,
            juiceboxProjectID: 42,
            juiceboxProjectIDGoerli: 207,
            acceptsDonation: false,
            acceptsDonationMessage: "",
            acceptsDonationETHAddress: "",
            twitterUsername: "PlanetableXYZ",
            githubUsername: "Planetable",
            telegramUsername: "Planetable",
            mastodonUsername: "",
            discordLink: "https://discord.example",
            podcastCategories: [:],
            podcastLanguage: "en-US",
            podcastExplicit: false,
            tags: ["swift": "Swift", "templates": "Templates"]
        )
        let navigation = [
            TestNavigationItem(id: page.id, title: page.title, slug: page.slug ?? "", externalLink: ""),
        ]

        return [
            "assets_prefix": "../",
            "template_settings": [:],
            "user_settings": [
                "highlightColor": "#3366ff",
                "showRef": "true",
            ],
            "article": article,
            "articles": articles,
            "archive": ["2023": articles],
            "tag_articles": ["swift": articles, "templates": [article]],
            "tag_key": "swift",
            "content_html": contentRendered,
            "page_title": article.title,
            "page_description": "Template preview for \(templateName)",
            "page_description_html": "Template preview for <strong>\(templateName)</strong>",
            "planet": planet,
            "my_planet": planet,
            "planet_ipns": "k51qzi",
            "site_navigation": navigation,
            "has_avatar": true,
            "has_podcast": true,
            "article_id": article.id.uuidString,
            "article_type": TestArticleType.blog.rawValue,
            "article_title": article.title,
            "article_summary": "A preview article used by template render tests.",
            "build_timestamp": 1_700_000_000,
            "style_css_sha256": "preview-sha256",
            "current_item_type": "blog",
            "current_page": 1,
            "total_pages": 2,
            "next_page": "page2.html",
            "previous_page": "",
            "custom_code_head": "",
            "custom_code_body_start": "",
            "custom_code_body_end": "",
            "social_image_url": "https://example.com/social.png",
        ]
    }
}

private enum TestStencilExtension {
    static let common: Extension = {
        let ext = Extension()

        ext.registerFilter("md2html") { value in
            value
        }
        ext.registerFilter("absoluteImageURL") { value, _ in
            value
        }
        ext.registerFilter("formatDate") { value in
            guard let date = value as? Date else {
                return value
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter.string(from: date)
        }
        ext.registerFilter("formatDateC") { value in
            guard let date = value as? Date else {
                return value
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            return formatter.string(from: date)
        }
        ext.registerFilter("ymd") { value in
            guard let date = value as? Date else {
                return value
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        ext.registerFilter("mdyydot") { value in
            guard let date = value as? Date else {
                return value
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "M.d.yy"
            return formatter.string(from: date)
        }
        ext.registerFilter("hhmmss") { value in
            guard let seconds = value as? Int else {
                return "00:00:00"
            }
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let remainingSeconds = seconds % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        }
        ext.registerFilter("rfc822") { value in
            guard let date = value as? Date else {
                return value
            }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            return formatter.string(from: date)
        }
        ext.registerFilter("escapejs") { value in
            guard let string = value as? String else {
                return ""
            }
            return string.escapedForJavaScript()
        }
        ext.registerFilter("escape") { value in
            guard let string = value as? String else {
                return value
            }
            return string.escapedForHTML()
        }

        return ext
    }()
}

private extension String {
    func escapedForJavaScript() -> String {
        var escaped = ""
        for scalar in unicodeScalars {
            switch scalar {
            case "\\":
                escaped += "\\u005C"
            case "'":
                escaped += "\\u0027"
            case "\"":
                escaped += "\\u0022"
            case ">":
                escaped += "\\u003E"
            case "<":
                escaped += "\\u003C"
            case "&":
                escaped += "\\u0026"
            case "=":
                escaped += "\\u003D"
            case "-":
                escaped += "\\u002D"
            case ";":
                escaped += "\\u003B"
            case "\u{2028}":
                escaped += "\\u2028"
            case "\u{2029}":
                escaped += "\\u2029"
            default:
                if scalar.value < 32 {
                    escaped += String(format: "\\u%04X", scalar.value)
                } else {
                    escaped.append(Character(scalar))
                }
            }
        }
        return escaped
    }

    func escapedForHTML() -> String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
