import Foundation

///
/// An icon from the app bundle.
///

struct BundleIcon {

    ///
    /// The name of the file.
    ///
    /// This value will be the name used in `UIApplication.shared.setAlternateIconName`.
    ///

    let name: String?

    /// The common base name of the icon files (excluding size modifiers like @2x).
    let filePrefix: String


    // MARK: - Plist Support

    func makeAlternateAppIconDictionary() -> [AnyHashable: Any] {

        return [
            InfoPlist.iconFilesKey: [
                filePrefix
            ]
        ]

    }

}


// MARK: - BundleIcon + Equatable

extension BundleIcon: Hashable {

    var hashValue: Int {
        return (name?.hashValue ?? 0) ^ filePrefix.hashValue
    }

    static func == (lhs: BundleIcon, rhs: BundleIcon) -> Bool {
        return lhs.name == rhs.name && lhs.filePrefix == rhs.filePrefix
    }

}
