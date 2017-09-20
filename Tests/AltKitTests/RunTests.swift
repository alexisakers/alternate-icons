import XCTest
import Foundation
import Files
@testable import AltKit

///
/// Tests the script execution.
///

class RunTests: FailableTestCase {

    /// The arguments to use to test the script.
    var arguments: Script.Arguments!

    /// The Info.plist file before any modifications.
    var initialInfoPlistData: Data!

    /// The path to the XCTest bundle.
    var basePath: String!


    // MARK: - Lifecycle

    override func setUp() {

        let bundle = Bundle(for: InfoPlistTests.self)
        basePath = bundle.bundlePath + "/Contents/Resources/TestFixtures/"

        let infoPlistPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/AppBundle/Info.plist"
        let catalogPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/Images.xcassets"
        let appBundlePath = bundle.bundlePath + "/Contents/Resources/TestFixtures/AppBundle"

        do {

            let infoPlistFile = try File(path: infoPlistPath)
            let catalogFolder = try Folder(path: catalogPath)
            let appBundleFolder = try Folder(path: appBundlePath)

            let infoPlist = try InfoPlist(file: infoPlistFile)
            let catalog = AssetCatalog(folder: catalogFolder)

            initialInfoPlistData = try infoPlistFile.read()
            arguments = Script.Arguments(infoPlist: infoPlist, assetCatalog: catalog, appBundle: appBundleFolder)

        } catch {
            XCTFail("Could not set up: \(error)")
        }

    }

    override func tearDown() {

        do {

            for file in arguments.appBundle.files {
                try file.delete()
            }

            try arguments.infoPlist.file.write(data: initialInfoPlistData)

            arguments = nil
            basePath = nil

        } catch {
            XCTFail("Could not clean up.")
        }

    }


    // MARK: - Tests

    ///
    /// Tests that arguments can be read from the environment.
    ///

    func testReadArguments() throws {

        let readArguments = try Script.readArguments(resolvingAgainst: basePath)
        XCTAssertEqual(readArguments.appBundle, arguments.appBundle)
        XCTAssertEqual(readArguments.infoPlist, arguments.infoPlist)
        XCTAssertEqual(readArguments.assetCatalog, arguments.assetCatalog)

    }

    ///
    /// Tests running the script.
    ///

    func testRun() throws {

        // 1) Run the script

        let expectedAlternateIcons: Set<BundleIcon> = [
            BundleIcon(name: "AppIcon", files: makeFilesList(for: "AppIcon")),
            BundleIcon(name: "Light", files: makeFilesList(for: "Light")),
            BundleIcon(name: "Sombre", files: makeFilesList(for: "Sombre"))
        ]

        try Script.run(with: arguments)

        // 2) Verify Info.plist

        let infoPlistPath = basePath + "AppBundle/Info.plist"
        let infoPlistFile = try File(path: infoPlistPath)
        let infoPlist = try InfoPlist(file: infoPlistFile)

        guard let iconsInInfoPlistAfterRun = infoPlist.parseIcons() else {
            XCTFail("Icons section not found in Info.plist")
            return
        }

        XCTAssertEqual(iconsInInfoPlistAfterRun, expectedAlternateIcons)

        // 3) Verify the copied files

        let iconFileNames = try arguments.assetCatalog.listAppIconSets().map {
            $0.enumerateImageFiles(unique: false) { _ in return true }.map { $0.destination }
        }
        
        let expectedIconFiles = merge(iconFileNames)

        for expectedIconFile in expectedIconFiles {
            XCTAssertTrue(arguments.appBundle.containsFile(named: expectedIconFile), "The '\(expectedIconFile)' file wasn't copied")
        }

        // 4) Verified Deleted Files

        let deletedIconPath = basePath + "AppBundle/AppIconOld@2x.png"
        XCTAssertFalse(FileManager.default.fileExists(atPath: deletedIconPath))

    }

    func makeFilesList(for iconName: String) -> [String] {

        return [
            "\(iconName)20x20@2x.png",
            "\(iconName)20x20@3x.png",
            "\(iconName)29x29.png",
            "\(iconName)29x29@2x.png",
            "\(iconName)29x29@3x.png",
            "\(iconName)40x40@2x.png",
            "\(iconName)40x40@3x.png",
            "\(iconName)57x57.png",
            "\(iconName)57x57@2x.png",
            "\(iconName)60x60@2x.png",
            "\(iconName)60x60@3x.png",
            "\(iconName)20x20~ipad.png",
            "\(iconName)20x20@2x~ipad.png",
            "\(iconName)29x29~ipad.png",
            "\(iconName)29x29@2x~ipad.png",
            "\(iconName)40x40~ipad.png",
            "\(iconName)40x40@2x~ipad.png",
            "\(iconName)50x50~ipad.png",
            "\(iconName)50x50@2x~ipad.png",
            "\(iconName)72x72@2x~ipad.png",
            "\(iconName)72x72~ipad.png",
            "\(iconName)76x76@2x~ipad.png",
            "\(iconName)76x76~ipad.png",
            "\(iconName)83.5x83.5@2x~ipad.png"
        ]

    }

}
