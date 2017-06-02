import XCTest
import Foundation
import Files
@testable import AltKit

///
/// Tests the script execution.
///

class RunTests: XCTestCase {

    /// The arguments to use to test the script.
    var arguments: AlternateIcons.Arguments!

    /// The Info.plist file before any modifications.
    var initialInfoPlistData: Data!

    /// The path to the XCTest bundle.
    var basePath: String!


    // MARK: - Lifecycle

    override func setUp() {

        let bundle = Bundle(for: InfoPlistTests.self)
        basePath = bundle.bundlePath + "/Contents/Resources/TestFixtures/"

        let infoPlistPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/NoAlternateInfo.plist"
        let catalogPath = bundle.bundlePath + "/Contents/Resources/TestFixtures/Images.xcassets"
        let appBundlePath = bundle.bundlePath + "/Contents/Resources/TestFixtures/AppBundle"

        do {

            try FileManager.default.createDirectory(atPath: appBundlePath, withIntermediateDirectories: false, attributes: nil)

            let infoPlistFile = try File(path: infoPlistPath)
            let catalogFolder = try Folder(path: catalogPath)
            let appBundleFolder = try Folder(path: appBundlePath)

            let infoPlist = try InfoPlist(file: infoPlistFile)
            let catalog = AssetCatalog(folder: catalogFolder)

            initialInfoPlistData = try infoPlistFile.read()
            arguments = AlternateIcons.Arguments(infoPlist: infoPlist, assetCatalog: catalog, appBundle: appBundleFolder)

        } catch {
            dump(error)
            XCTFail("Could not set up")
        }

    }

    override func tearDown() {

        do {
            print(arguments)
            try arguments.appBundle.delete()
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

        let readArguments = try AlternateIcons.readArguments(resolvingAgainst: basePath)
        XCTAssertEqual(readArguments.appBundle, arguments.appBundle)
        XCTAssertEqual(readArguments.infoPlist, arguments.infoPlist)
        XCTAssertEqual(readArguments.assetCatalog, arguments.assetCatalog)

    }

    ///
    /// Tests running the script.
    ///

    func testRun() throws {

        let expectedIcons = [
            BundleIcon(name: nil, filePrefix: "AppIcon"),
            BundleIcon(name: "Light", filePrefix: "Light"),
            BundleIcon(name: "Sombre", filePrefix: "Sombre")
        ]

        try AlternateIcons.run(with: arguments)



    }

}
