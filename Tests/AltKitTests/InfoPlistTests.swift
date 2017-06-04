import XCTest
import Foundation
import Files
@testable import AltKit

///
/// Tests the InfoPlist wrapper.
///

class InfoPlistTests: FailableTestCase {

    /// The file containing valid alternate icons.
    var alternateIconsInfo: InfoPlist!

    /// The asset catalog.
    var assetCatalog: AssetCatalog!


    // MARK: - Lifecycle

    override func setUp() {

        let bundle = Bundle(for: InfoPlistTests.self)
        let alternateIconsInfoPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/AlternateInfo.plist"
        let imagesAssetCatalogPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/Images.xcassets"

        guard let alternateIconsInfoFile = try? File(path: alternateIconsInfoPath) else {
            XCTFail("Could not open the AlternateInfo.plist file.")
            return
        }

        guard let alternateIconsInfo = try? InfoPlist(file: alternateIconsInfoFile) else {
            XCTFail("Could not parse the AlternateInfo.plist file.")
            return
        }

        guard let assetCatalogFolder = try? Folder(path: imagesAssetCatalogPath) else {
            XCTFail("Could not open the Images.xcassets file.")
            return
        }

        self.alternateIconsInfo = alternateIconsInfo
        self.assetCatalog = AssetCatalog(folder: assetCatalogFolder)

    }

    override func tearDown() {
        alternateIconsInfo = nil
        assetCatalog = nil
    }


    // MARK: - Tests

    ///
    /// Tests that removing and adding bundle icons when updating works correctly.
    ///

    func testUpdatingExistingInfo() throws {

        var icons = try assetCatalog.listAppIconSets()

        guard let primaryIndex = icons.index(where: { $0.name == "AppIcon" }) else {
            XCTFail("No primary app icon.")
            return
        }

        let primaryIcon = icons.remove(at: primaryIndex)
        alternateIconsInfo.update(primaryIcon: primaryIcon, alternateIcons: icons)

        guard let iconInfo = alternateIconsInfo.parseIcons() else {
            XCTFail("Could not parse icons.")
            return
        }

        let expectedPrimaryIcon = BundleIcon(name: "AppIcon")

        let expectedAlternateIcons: Set<BundleIcon> = [
            BundleIcon(name: "Light"),
            BundleIcon(name: "Sombre")
        ]

        XCTAssertEqual(iconInfo.primaryIcon, expectedPrimaryIcon)
        XCTAssertEqual(iconInfo.alternateIcons, expectedAlternateIcons)

    }

}
