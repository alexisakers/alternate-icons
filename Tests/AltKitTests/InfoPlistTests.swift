import XCTest
import Foundation
import Files
@testable import AltKit

///
/// Tests the InfoPlist wrapper.
///

class InfoPlistTests: XCTestCase {

    /// The file containing valid alternate icons.
    var alternateIconsInfo: InfoPlist!


    // MARK: - Lifecycle

    override func setUp() {

        let bundle = Bundle(for: InfoPlistTests.self)
        let alternateIconsInfoPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/AlternateInfo.plist"

        guard let alternateIconsInfoFile = try? File(path: alternateIconsInfoPath) else {
            XCTFail("Could not open the AlternateInfo.plist file.")
            return
        }

        guard let alternateIconsInfo = try? InfoPlist(file: alternateIconsInfoFile) else {
            XCTFail("Could not parse the AlternateInfo.plist file.")
            return
        }

        self.alternateIconsInfo = alternateIconsInfo


    }

    override func tearDown() {
        alternateIconsInfo = nil
    }


    // MARK: - Tests

    ///
    /// Tests that parsing can recognize primary and alternate icons.
    ///

    func testParsing() {

        let expectedPrimary = BundleIcon(name: nil, filePrefix: "ic_none")

        let expectedAlternate: Set<BundleIcon> = [
            BundleIcon(name: "barca", filePrefix: "ic_barca"),
            BundleIcon(name: "ams", filePrefix: "ic_ams"),
            BundleIcon(name: "paris", filePrefix: "ic_paris")
        ]

        guard let iconInfo = alternateIconsInfo.parseIcons() else {
            XCTFail("Could not read icon infos.")
            return
        }

        XCTAssertEqual(iconInfo.primaryIcon, expectedPrimary)
        XCTAssertEqual(iconInfo.alternateIcons, expectedAlternate)

    }

    ///
    /// Tests that removing and adding bundle icons when updating works correctly.
    ///

    func testUpdatingExistingInfo() {

        let primaryIcon = BundleIcon(name: nil, filePrefix: "ic_main")

        let alternateIcons: Set<BundleIcon> = [
            BundleIcon(name: "paris", filePrefix: "ic_paris"),
            BundleIcon(name: "north_pole", filePrefix: "ic_north_pole"),
            BundleIcon(name: "south_pole", filePrefix: "ic_south_pole")
        ]

        alternateIconsInfo.update(primaryIcon: primaryIcon, alternateIcons: alternateIcons)

        guard let iconInfo = alternateIconsInfo.parseIcons() else {
            XCTFail("Could not parse icons.")
            return
        }

        XCTAssertEqual(iconInfo.primaryIcon, primaryIcon)
        XCTAssertEqual(iconInfo.alternateIcons, alternateIcons)

    }

}
