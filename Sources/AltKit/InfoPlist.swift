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
            throw NSError()
        }

        self.file = file
        self.infoDictionary = infoDictionary

    }


    // MARK: - I/O

    ///
    /// Parses the icon information contained in the `Info.plist`.
    ///
    /// - returns: The primary icon and its alternate icons
    ///

    func parseIcons() -> (primaryIcon: BundleIcon, alternateIcons: Set<BundleIcon>)? {

        guard let icons = infoDictionary[InfoPlist.iconsKey] as? [AnyHashable: Any] else {
            return nil
        }

        func parseIcon(in dictionary: [AnyHashable: Any], name: String?) -> BundleIcon? {

            guard let files = dictionary[InfoPlist.iconFilesKey] as? [String] else {
                return nil
            }

            guard files.count > 0 else {
                return nil
            }

            return BundleIcon(name: name, filePrefix: files[0])

        }

        // 1) Primary icon

        guard let primaryIconDictionary = icons[InfoPlist.primaryIconKey] as? [AnyHashable: Any] else {
            return nil
        }

        guard let primaryIcon = parseIcon(in: primaryIconDictionary, name: nil) else {
            return nil
        }


        // 2) Alternate icons

        guard let alternateIconsDictionary = icons[InfoPlist.alternateIconsKey] as? [String: [AnyHashable: Any]] else {
            return (primaryIcon, [])
        }

        let alternateIconsArray: [BundleIcon] = alternateIconsDictionary.flatMap {
            parseIcon(in: $0.value, name: $0.key)
        }

        let alternateIcons = Set<BundleIcon>(alternateIconsArray)
        return (primaryIcon, alternateIcons)

    }

    ///
    /// Updates the Info.plist file with a new set of icons.
    ///
    /// - parameter primaryIcon: The new primary icon.
    /// - parameter alternateIcons: The list of alternate app icons to use.
    ///

    func update(primaryIcon: BundleIcon, alternateIcons: Set<BundleIcon>) {

        let alternateIconsFiles = alternateIcons.reduce([AnyHashable: Any]()) {
            result, next in

            guard let name = next.name else {
                return result
            }

            var resultCopy = result
            resultCopy[name] = next.makeAlternateAppIconDictionary()

            return resultCopy

        }

        let dictionary: [AnyHashable: Any] = [
            InfoPlist.primaryIconKey: [
                InfoPlist.iconFilesKey: [
                    primaryIcon.filePrefix
                ]
            ],
            InfoPlist.alternateIconsKey: alternateIconsFiles
        ]

        infoDictionary[InfoPlist.iconsKey] = dictionary

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

    /// The primary icon dictionary.
    static var primaryIconKey = "CFBundlePrimaryIcon"

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
