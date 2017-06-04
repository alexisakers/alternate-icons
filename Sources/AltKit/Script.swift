import Foundation
import Files

///
/// The main entry point of the script.
///

public enum Script {

    ///
    /// The arguments required to execute the program.
    ///

    public struct Arguments: Equatable {

        /// The information plist file.
        let infoPlist: InfoPlist

        /// The asset catalog folder containing the alternate icons.
        let assetCatalog: AssetCatalog

        /// The app bundle.
        let appBundle: Folder

        public static func == (lhs: Arguments, rhs: Arguments) -> Bool {
            return lhs.infoPlist == rhs.infoPlist && lhs.assetCatalog == rhs.assetCatalog && lhs.appBundle == rhs.appBundle
        }

    }


    // MARK: - Execution

    ///
    /// Reads the arguments from the current context.
    ///
    /// - note: The basePath parameter should only be used for unit testing.
    ///

    public static func readArguments(resolvingAgainst basePath: String = "") throws -> Arguments {

        // 1) Asset Catalog

        guard let scriptInputFiles = Xcode.scriptInputFiles else {
            throw AltError.noAssetCatalog
        }

        guard scriptInputFiles.count > 0 else {
            throw AltError.noAssetCatalog
        }

        let assetCatalogPath = scriptInputFiles[0]
        let assetCatalogFolder = try Folder(path: basePath + assetCatalogPath)

        // 2) App Bundle

        let buildPath = Xcode.buildProductsDir ?? basePath

        guard let contentsDir = Xcode.contentsFolderPath else {
            throw AltError.noAppBundle
        }

        let appBundlePath = buildPath.appending(pathComponent: contentsDir)

        // 3) Info Plist

        let infoPlistPath = appBundlePath.appending(pathComponent: "Info.plist")
        let infoPlistFile = try File(path: infoPlistPath)

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

    public static func run(with arguments: Arguments) throws {

        // 1) Read asset catalog

        var appIconSets = try arguments.assetCatalog.listAppIconSets()

        guard let primaryIndex = appIconSets.index(where: { $0.name == "AppIcon" }) else {
            throw AltError.noPrimaryIconSet
        }

        let primaryIconSet = appIconSets.remove(at: primaryIndex)
        let alternateIconSets = appIconSets

        // 2) Cleanup

        if let infoPlistContents = arguments.infoPlist.parseIcons() {

            let removedAlternateIcons = infoPlistContents.alternateIcons.filter { icon in !alternateIconSets.contains(where: { $0.name == icon.name }) }

            for removedAlternateIcon in removedAlternateIcons {

                for removedImagePath in removedAlternateIcon.files {

                    let destinationPath = arguments.appBundle.path.appending(pathComponent: removedImagePath + ".png")

                    if FileManager.default.fileExists(atPath: destinationPath) {
                        try FileManager.default.removeItem(atPath: destinationPath)
                    }

                }

            }

        }

        // 3) Update Info.plist

        arguments.infoPlist.update(primaryIcon: primaryIconSet, alternateIcons: alternateIconSets)
        try arguments.infoPlist.commitChanges()

        // 4) Copy all icons into app bundle

        let iconImagesNames = try arguments.assetCatalog.listAppIconSets().map { $0.enumerateImageFiles() }
        let iconImages = merge(iconImagesNames)

        for image in iconImages {

            let destinationPath = arguments.appBundle.path.appending(pathComponent: image.destination)

            if FileManager.default.fileExists(atPath: destinationPath) {
                try FileManager.default.removeItem(atPath: destinationPath)
            }

            try FileManager.default.copyItem(atPath: image.source.path, toPath: destinationPath)

        }

    }

    ///
    /// Shows an error message and exits the script.
    ///

    public static func fail(reason: String) -> Never {

        let message = "💥  \(reason)\n".utf8
        let messageData = Data(message)

        FileHandle.standardError.write(messageData)
        exit(1)
        
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

    /// The name of the item (excluding any extension).
    var excludingExtension: String {
        guard let `extension` = `extension` else {
            return self
        }

        let startIndex = index(endIndex, offsetBy: -`extension`.characters.count - 1)
        return replacingCharacters(in: startIndex..<endIndex, with: "")
    }

    /// Any extension that the item has.
    var `extension`: String? {
        let components = self.components(separatedBy: ".")

        guard components.count > 1 else {
            return nil
        }
        
        return components.last
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
