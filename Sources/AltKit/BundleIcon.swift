import Foundation

///
/// An icon from the app bundle.
///

struct BundleIcon: Hashable {

    let name: String
    let files: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(files)
    }

    static func == (lhs: BundleIcon, rhs: BundleIcon) -> Bool {
        return lhs.name == rhs.name
    }
    
}
