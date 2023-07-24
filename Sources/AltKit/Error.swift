import Foundation

///
/// The list of known errors.
///

enum AltError: String, LocalizedError {

    /// The Info.plist file could not be read.
    case noInfoPlist = "The Info.plist file could not be read."

    /// The Info.plist file is not a valid XML Property List.
    case invalidInfoPlist = "The Info.plist file is not a valid XML Property List."

    /// The asset catalog could not be read.
    case noAssetCatalog = "The asset catalog could not be read."

    /// The app bundle could not be found.
    case noAppBundle = "The app bundle could not be found."

    /// No app icon set named 'AppIcon' was found.
    case noPrimaryIconSet = "No app icon set named 'AppIcon' was found."

    /// The Info.plist file could not be read.
    case noOutputPlistPath = "No output path for the updated Info.plist was specified."

    var errorDescription: String? {
        return rawValue
    }

}
