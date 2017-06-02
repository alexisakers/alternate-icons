import XCTest
import Foundation
import Files
@testable import AltKit

///
/// Tests the Asset Catalog parser.
///

class AssetCatalogTests: XCTestCase {

    /// The asset catalog.
    var catalog: AssetCatalog!


    // MARK: - Lifecycle
    
    override func setUp() {

        let bundle = Bundle(for: InfoPlistTests.self)
        let catalogPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/Images.xcassets"

        guard let catalogFolder = try? Folder(path: catalogPath) else {
            XCTFail("Could not open the Images.xcassets folder.")
            return
        }

        catalog = AssetCatalog(folder: catalogFolder)

    }

    override func tearDown() {
        catalog = nil
    }


    // MARK: - Tests

    ///
    /// Tests that the parser returns the correct list of app icon sets.
    ///

    func testListIconSets() throws {

        let iconSets = try catalog.listAppIconSets()

        let expectedNames = ["Dark.appiconset", "Light.appiconset", "Sombre.appiconset"]
        let iconSetNames = iconSets.map { $0.name }.sorted()

        XCTAssertEqual(iconSetNames, expectedNames)

    }

    ///
    /// Tests that all the images are read correctly.
    ///

    func testReadImages() throws {

        let iconSets = try catalog.listAppIconSets()

        for set in iconSets {
            XCTAssertEqual(set.images.count, 24)
        }

    }

}
