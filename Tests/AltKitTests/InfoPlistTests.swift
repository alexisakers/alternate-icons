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

        let icons = try assetCatalog.listAppIconSets()
        alternateIconsInfo.update(alternateIcons: icons)

        guard let alternateIcons = alternateIconsInfo.parseIcons() else {
            XCTFail("Could not parse icons.")
            return
        }

        let expectedAlternateIcons: Set<BundleIcon> = [
            BundleIcon(name: "AppIcon", files: makeFilesList(for: "AppIcon")),
            BundleIcon(name: "Light", files: makeFilesList(for: "Light")),
            BundleIcon(name: "Sombre", files: makeFilesList(for: "Sombre"))
        ]

        XCTAssertEqual(alternateIcons, expectedAlternateIcons)

    }

    func makeFilesList(for iconName: String) -> [String] {

        return [
            "\(iconName)20x20@2x",
            "\(iconName)20x20@3x",
            "\(iconName)29x29",
            "\(iconName)29x29@2x",
            "\(iconName)29x29@3x",
            "\(iconName)40x40@2x",
            "\(iconName)40x40@3x",
            "\(iconName)57x57",
            "\(iconName)57x57@2x",
            "\(iconName)60x60@2x",
            "\(iconName)60x60@3x",
            "\(iconName)20x20~ipad",
            "\(iconName)20x20@2x~ipad",
            "\(iconName)29x29~ipad",
            "\(iconName)29x29@2x~ipad",
            "\(iconName)40x40~ipad",
            "\(iconName)40x40@2x~ipad",
            "\(iconName)50x50~ipad",
            "\(iconName)50x50@2x~ipad",
            "\(iconName)72x72@2x~ipad",
            "\(iconName)72x72~ipad",
            "\(iconName)76x76@2x~ipad",
            "\(iconName)76x76~ipad",
            "\(iconName)83.5x83.5@2x~ipad"
        ]

    }

}

// MARK: - Info Plist Parsing

extension InfoPlist {

    ///
    /// Parses the icon information contained in the `Info.plist`.
    ///
    /// - returns: The alternate icons in the `Info.plist`.
    ///

    func parseIcons() -> Set<BundleIcon>? {

        guard let iphoneIcons = parseIcons(forVariant: InfoPlist.iconsKey) else {
            return nil
        }

        guard let ipadIcons = parseIcons(forVariant: InfoPlist.ipadIconsKey) else {
            return nil
        }

        let alternateIconsArray = merge([iphoneIcons, ipadIcons])

        let alternateIcons = Set<BundleIcon>(alternateIconsArray)
        return alternateIcons

    }

    private func parseIcons(forVariant variant: String) -> [BundleIcon]? {

        guard let icons = infoDictionary[variant] as? [AnyHashable: Any] else {
            return nil
        }

        guard let alternateIconsDictionary = icons[InfoPlist.alternateIconsKey] as? [String: [AnyHashable: Any]] else {
            return nil
        }

        return alternateIconsDictionary.flatMap {

            guard let files = $0.value[InfoPlist.iconFilesKey] as? [String] else {
                return nil
            }

            return BundleIcon(name: $0.key, files: files)

        }

    }

}
