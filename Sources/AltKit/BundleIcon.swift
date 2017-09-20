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
