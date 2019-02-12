import XCTest
@testable import HiveMindEngine

final class CollectionExtensionTests: XCTestCase {

    static var allTests = [
        ("testCollectionIsNotEmpty", testCollectionIsNotEmpty),
    ]

    func testCollectionIsNotEmpty() {
        var collection: [String] = []
        XCTAssert(collection.isNotEmpty == false)
        collection.append("Hello, world!")
        XCTAssert(collection.isNotEmpty == true)
    }
}
