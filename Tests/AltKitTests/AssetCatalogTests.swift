import XCTest
import Foundation
import Files
@testable import AltKit

///
/// Tests the Asset Catalog parser.
///

class AssetCatalogTests: FailableTestCase {

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

        let expectedNames = ["AppIcon", "Light", "Sombre"]
        let iconSetNames = iconSets.map { $0.name }.sorted()

        XCTAssertEqual(iconSetNames, expectedNames)

    }

    ///
    /// Tests that all the images are read correctly.
    ///

    func testReadImages() throws {

        let iconSets = try catalog.listAppIconSets()

        for set in iconSets {
            XCTAssertTrue(set.images.count > 0)
        }

    }

    ///
    /// Tests the attribution of names.
    ///

    func testNames() throws {

        let iconSets = try catalog.listAppIconSets()

        guard let appIconSet = iconSets.first(where: { $0.name == "AppIcon" }) else {
            XCTFail("No AppIcon set")
            return
        }

        let expectedNamesSet: Set<String> = [
            "AppIcon20x20",
            "AppIcon29x29",
            "AppIcon40x40",
            "AppIcon57x57",
            "AppIcon60x60",
            "AppIcon50x50",
            "AppIcon72x72",
            "AppIcon76x76",
            "AppIcon83.5x83.5"
        ]

        let names = appIconSet.enumerateImageFiles(unique: true, filter: { _ in return true }).map { $0.name }
        let namesSet = Set<String>(names)

        XCTAssertEqual(namesSet, expectedNamesSet)
        XCTAssertFalse(namesSet.contains("fake.png"))

    }

}
