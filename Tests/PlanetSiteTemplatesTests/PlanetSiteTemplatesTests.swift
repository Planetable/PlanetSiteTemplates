import XCTest
@testable import PlanetSiteTemplates

final class PlanetSiteTemplatesTests: XCTestCase {
    func testBuiltInTemplates() {
        XCTAssertEqual(PlanetSiteTemplates.builtInTemplates.count, 1)
    }
}
