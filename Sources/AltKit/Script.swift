import Foundation
import Files

///
/// The main entry point of the script.
///

enum Script {

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
    /// - note: The basePath parameter should only be used for unit testing.
    ///

    static func readArguments(resolvingAgainst basePath: String = "") throws -> Arguments {

        // 1) Info Plist

        guard let infoPlistPath = Xcode.infoPlistFile else {
            throw AltError.noInfoPlist
        }

        let infoPlistFile = try File(path: basePath + infoPlistPath)

        // 2) Asset Catalog

        guard let scriptInputFiles = Xcode.scriptInputFiles else {
            throw AltError.noAssetCatalog
        }

        guard scriptInputFiles.count > 0 else {
            throw AltError.noAssetCatalog
        }

        let assetCatalogPath = scriptInputFiles[0]
        let assetCatalogFolder = try Folder(path: basePath + assetCatalogPath)

        // 3) App Bundle

        let buildPath = Xcode.buildProductsDir ?? basePath

        guard let contentsDir = Xcode.contentsFolderPath else {
            throw AltError.noAppBundle
        }

        let appBundlePath = buildPath.appending(pathComponent: contentsDir)

        let infoPlist = try InfoPlist(file: infoPlistFile)
        let assetCatalog = AssetCatalog(folder: assetCatalogFolder)
        let appBundle = try Folder(path: appBundlePath)

        return Arguments(infoPlist: infoPlist,
                         assetCatalog: assetCatalog,
                         appBundle: appBundle)

    }

    ///
    /// Executes the script with the given arguments.
    ///

    static func run(with arguments: Arguments) throws {

        // 1) Read asset catalog

        var appIconSets = try arguments.assetCatalog.listAppIconSets()

        guard let primaryIndex = appIconSets.index(where: { $0.name == "AppIcon" }) else {
            throw AltError.noPrimaryIconSet
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

        let iconImagesNames = try arguments.assetCatalog.listAppIconSets().map { $0.enumerateImageFiles() }
        let iconImages = merge(iconImagesNames)

        for image in iconImages {
            let destinationPath = arguments.appBundle.path.appending(pathComponent: image.destination)
            try FileManager.default.copyItem(atPath: image.source.path, toPath: destinationPath)
        }

    }

}


// MARK: - Utilities

extension String {

    ///
    /// Appends a path component to the string.
    ///

    func appending(pathComponent: String) -> String {

        guard !isEmpty else {
            return self
        }

        let pathJoiner = hasSuffix("/") ? "" : "/"
        return self + pathJoiner + pathComponent

    }

}

///
/// Combines an array of arrays into a single array.
///

func merge<Base>(_ arraysToMerge: @autoclosure () -> [[Base]]) -> [Base] {

    let arrays = arraysToMerge()

    return arrays.reduce([Base]()) {
        result, next in
        var mutableResults = result
        mutableResults.append(contentsOf: next)
        return mutableResults
    }

}
