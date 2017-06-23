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
            "AppIcon20x20@2x.png",
            "AppIcon20x20@3x.png",
            "AppIcon29x29.png",
            "AppIcon29x29@2x.png",
            "AppIcon29x29@3x.png",
            "AppIcon40x40@2x.png",
            "AppIcon40x40@3x.png",
            "AppIcon57x57.png",
            "AppIcon57x57@2x.png",
            "AppIcon60x60@2x.png",
            "AppIcon60x60@3x.png",
            "AppIcon20x20~ipad.png",
            "AppIcon20x20@2x~ipad.png",
            "AppIcon29x29~ipad.png",
            "AppIcon29x29@2x~ipad.png",
            "AppIcon40x40~ipad.png",
            "AppIcon40x40@2x~ipad.png",
            "AppIcon50x50~ipad.png",
            "AppIcon50x50@2x~ipad.png",
            "AppIcon72x72@2x~ipad.png",
            "AppIcon72x72~ipad.png",
            "AppIcon76x76@2x~ipad.png",
            "AppIcon76x76~ipad.png",
            "AppIcon83.5x83.5@2x~ipad.png"
        ]

        let names = appIconSet.enumerateImageFiles().map { $0.destination }
        let namesSet = Set<String>(names)

        XCTAssertEqual(namesSet, expectedNamesSet)
        XCTAssertFalse(namesSet.contains("fake.png"))

    }

}
