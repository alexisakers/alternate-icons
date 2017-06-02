import Foundation
import Files

///
/// The main entry point of the script.
///

enum AlternateIcons {

    ///
    /// The arguments required to execute the program.
    ///

    struct Arguments: Equatable {

        /// The information plist file.
        let infoPlist: InfoPlist

        /// The asset catalog folder containing the alternate icons.
        let assetCatalog: AssetCatalog

        /// The app bundle.
        let appBundle: Folder

        static func == (lhs: Arguments, rhs: Arguments) -> Bool {
            return lhs.infoPlist == rhs.infoPlist && lhs.assetCatalog == rhs.assetCatalog && lhs.appBundle == rhs.appBundle
        }

    }


    // MARK: - Execution

    ///
    /// Reads the arguments from the current context.
    ///

    static func readArguments() throws -> Arguments {

        // 1) Info Plist

        guard let infoPlistPath = Xcode.infoPlistFile else {
            throw NSError() // noInfoPlist
        }

        let infoPlistFile = try File(path: infoPlistPath)

        // 2) Asset Catalog

        guard let scriptInputFiles = Xcode.scriptInputFiles else {
            throw NSError() // noAssetCatalog
        }

        guard scriptInputFiles.count > 0 else {
            throw NSError() // noAssetCatalog
        }

        let assetCatalogPath = scriptInputFiles[0]
        let assetCatalogFolder = try Folder(path: assetCatalogPath)

        // 3) App Bundle

        guard let buildPath = Xcode.buildProductsDir else {
            throw NSError() // noAppBundle
        }

        guard let contentsDir = Xcode.contentsFolderPath else {
            throw NSError() // noAppBundle
        }

        let pathJoiner = buildPath.hasPrefix("/") ? "" : "/"
        let appBundlePath = buildPath + pathJoiner + contentsDir

        let infoPlist = try InfoPlist(file: infoPlistFile)
        let assetCatalog = AssetCatalog(folder: assetCatalogFolder)
        let appBundle = try Folder(path: appBundlePath)

        return Arguments(infoPlist: infoPlist, assetCatalog: assetCatalog, appBundle: appBundle)

    }

    ///
    /// Executes the script with the given arguments.
    ///

    static func run(with arguments: Arguments) throws {

        // 1) Read asset catalog

        var appIconSets = try arguments.assetCatalog.listAppIconSets()

        guard let primaryIndex = appIconSets.index(where: { $0.name == "AppIcon.appiconset" }) else {
            throw NSError() // noPrimary
        }

        let primaryIconSet = appIconSets.remove(at: primaryIndex)
        let alternateIconSets = appIconSets


        // 2) Update Info.plist

        let primaryIcon = BundleIcon(name: nil, filePrefix: primaryIconSet.name)
        let alternateIconsArray = alternateIconSets.map { BundleIcon(name: $0.name, filePrefix: $0.name) }
        let alternateIcons = Set<BundleIcon>(alternateIconsArray)

        arguments.infoPlist.update(primaryIcon: primaryIcon, alternateIcons: alternateIcons)
        try arguments.infoPlist.commitChanges()

        // 3) Copy all icons into app bundle

        var iconImages = primaryIconSet.enumerateImageFiles()
        let alternateIconImages = merge(alternateIconSets.map { $0.enumerateImageFiles() })
        iconImages.append(contentsOf: alternateIconImages)

        for primaryImage in iconImages {
            let toPath = arguments.appBundle.path.appending(pathComponent: primaryImage.destination)
            try FileManager.default.moveItem(atPath: primaryImage.source.path, toPath: toPath)
        }

    }

}


// MARK: - Utilities

extension String {

    ///
    /// Appends a path component to the string.
    ///

    func appending(pathComponent: String) -> String {
        let pathJoiner = hasSuffix("/") ? "" : "/"
        return self + pathJoiner + pathComponent
    }

}

///
/// Combines an array of arrays into a single array.
///

func merge<Base>(_ arrays: @autoclosure [[Base]]) -> [Base] {

    return arrays.reduce([Base]()) {
        result, next in
        var mutableResults = result
        mutableResults.append(contentsOf: next)
        return mutableResults
    }

}
