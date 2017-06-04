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

        let expectedPrimaryIcon = BundleIcon(name: "AppIcon", files: [])

        let expectedAlternateIcons: Set<BundleIcon> = [
            BundleIcon(name: "Light", files: []),
            BundleIcon(name: "Sombre", files: [])
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

        XCTAssertEqual(iconsInInfoPlistAfterRun.primaryIcon, expectedPrimaryIcon)
        XCTAssertEqual(iconsInInfoPlistAfterRun.alternateIcons, expectedAlternateIcons)

        // 3) Verifies the copied files

        let iconFileNames = try arguments.assetCatalog.listAppIconSets().map { $0.enumerateImageFiles().map { $0.destination } }
        let expectedIconFiles = merge(iconFileNames)

        for expectedIconFile in expectedIconFiles {
            XCTAssertTrue(arguments.appBundle.containsFile(named: expectedIconFile), "The '\(expectedIconFile)' file wasn't copied")
        }

    }

}
