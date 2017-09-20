import Foundation
import Files

///
/// The representation of the information Property List of an app (`Info.plist`).
///

class InfoPlist {

    /// The handle to the underlying `Info.plist` file.
    var file: File

    /// The properties in the `Info.plist` file.
    var infoDictionary: [AnyHashable: Any]


    // MARK: - Lifecycle

    ///
    /// Creates an InfoPlist object from an `Info.plist` file.
    ///
    /// - parameter file: The `Info.plist` file to parse.
    ///

    init(file: File) throws {

        let fileData = try file.read()
        let infoObject = try PropertyListSerialization.propertyList(from: fileData, options: [], format: nil)

        guard let infoDictionary = infoObject as? [AnyHashable: Any] else {
            throw AltError.invalidInfoPlist
        }

        self.file = file
        self.infoDictionary = infoDictionary

    }

    ///
    /// Updates the Info.plist file with a new set of icons.
    ///
    /// - parameter alternateIcons: The list of alternate app icons to use.
    ///

    func update(alternateIcons: Set<AppIconSet>) {

        let alternateIconsFiles = getAlternateIconFiles(in: alternateIcons) { $0.idiom == "iphone" }
        let alternateiPadIconsFiles = getAlternateIconFiles(in: alternateIcons) { $0.idiom == "ipad" }

        var icons = infoDictionary[InfoPlist.iconsKey] as? [AnyHashable: Any] ?? [:]
        var ipadIcons = infoDictionary[InfoPlist.ipadIconsKey] as? [AnyHashable: Any] ?? [:]

        icons[InfoPlist.alternateIconsKey] = alternateIconsFiles
        ipadIcons[InfoPlist.alternateIconsKey] = alternateiPadIconsFiles

        infoDictionary[InfoPlist.iconsKey] = icons
        infoDictionary[InfoPlist.ipadIconsKey] = ipadIcons

    }

    ///
    /// Get the alternate icon files dictionary for the given subset of icons.
    ///
    /// - parameter alternateIc
    ///

    func getAlternateIconFiles(in alternateIcons: Set<AppIconSet>, filter: (AppIconSet.Image) -> Bool) -> [AnyHashable: Any] {

        return alternateIcons.reduce([AnyHashable: Any]()) {
            result, next in

            let files = next.enumerateImageFiles(unique: true, filter: filter).map { $0.name }

            var resultCopy = result
            resultCopy[next.name] = [
                InfoPlist.iconFilesKey: files
            ]

            return resultCopy

        }

    }

    ///
    /// Writes any changes made to the info dictionary to the original `Info.plist` file.
    ///
    /// - note: This method is de-coupled from `update(primaryIcon:,alternateIcons:)` for
    /// testing purposes.
    ///

    func commitChanges() throws {
        let plistData = try PropertyListSerialization.data(fromPropertyList: infoDictionary, format: .xml, options: 0)
        try file.write(data: plistData)
    }

}


// MARK: - Keys

extension InfoPlist {

    /// The app icons dictionary.
    static var iconsKey = "CFBundleIcons"

    /// The iPad app icons dictionary.
    static var ipadIconsKey = "CFBundleIcons~ipad"

    /// The alternate icon dictionary.
    static var alternateIconsKey = "CFBundleAlternateIcons"

    /// The icon file names.
    static var iconFilesKey = "CFBundleIconFiles"

}


// MARK: - InfoPlist + Equatable

extension InfoPlist: Equatable {

    static func == (lhs: InfoPlist, rhs: InfoPlist) -> Bool {
        return lhs.file == rhs.file
    }

}
