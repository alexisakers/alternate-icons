import Foundation

///
/// An icon from the app bundle.
///

struct BundleIcon: Hashable {

    let name: String
    let files: [String]

    var hashValue: Int {
        return name.hashValue
    }

    static func == (lhs: BundleIcon, rhs: BundleIcon) -> Bool {
        return lhs.name == rhs.name
    }
    
}


// MARK: - Info Plist Parsing

extension InfoPlist {

    ///
    /// Parses the icon information contained in the `Info.plist`.
    ///
    /// - returns: The primary icon and its alternate icons
    ///

    func parseIcons() -> (primaryIcon: BundleIcon, alternateIcons: Set<BundleIcon>)? {

        guard let icons = infoDictionary[InfoPlist.iconsKey] as? [AnyHashable: Any] else {
            return nil
        }

        // 1) Primary icon

        guard let primaryIconInfo = icons[InfoPlist.primaryIconKey] as? [AnyHashable: Any] else {
            return nil
        }

        guard let primaryIconFiles = primaryIconInfo[InfoPlist.iconFilesKey] as? [String] else {
            return nil
        }

        let primaryIcon = BundleIcon(name: "AppIcon", files: primaryIconFiles)

        // 2) Alternate icons

        guard let alternateIconsDictionary = icons[InfoPlist.alternateIconsKey] as? [String: [AnyHashable: Any]] else {
            return (primaryIcon, [])
        }

        let alternateIconsArray: [BundleIcon] = alternateIconsDictionary.flatMap {

            guard let files = $0.value[InfoPlist.iconFilesKey] as? [String] else {
                return nil
            }

            return BundleIcon(name: $0.key, files: files)

        }
        
        let alternateIcons = Set<BundleIcon>(alternateIconsArray)
        return (primaryIcon, alternateIcons)
        
    }

}
