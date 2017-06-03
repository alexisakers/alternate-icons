import Foundation

///
/// The list of known errors.
///

enum AltError: LocalizedError {

    /// The Info.plist file could not be read.
    case noInfoPlist

    /// The asset catalog could not be read.
    case noAssetCatalog

    /// The app bundle could not be found.
    case noAppBundle

    /// No app icon set named 'AppIcon' was found.
    case noPrimaryIconSet

}
