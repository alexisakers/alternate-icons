import Foundation
import Files

///
/// A set of source images for the different sizes and resolutions of your iOS app icon.
///

class AppIconSet {

    ///
    /// An image from the set.
    ///

    struct Image: Decodable {

        /// The name of the `.png` file.
        let filename: String?

        /// The idiom of the icon.
        let idiom: String

        /// One of the sizes that matches the idiom for the icon.
        let size: String

        /// The scale of the icon.
        let scale: String
        
    }


    // MARK: - Properties

    /// The folder of the icon set.
    let folder: Folder

    /// The variants of the icon.
    let images: [Image]

    /// The name of the icon set.
    var name: String {
        return folder.nameExcludingExtension
    }
    

    // MARK: - Lifecycle

    private struct RawAppIconSet: Decodable {
        let images: [AppIconSet.Image]
    }

    ///
    /// Creates an app icon set reference.
    ///
    /// - parameter folder: The folder containing the icon set.
    ///

    init(folder: Folder) throws {

        let contentsJSON = try folder.file(named: "Contents.json")
        let contentsData = try contentsJSON.read()
        let rawIconSet = try JSONDecoder().decode(RawAppIconSet.self, from: contentsData)

        self.images = rawIconSet.images.filter { $0.filename != nil }
        self.folder = folder

    }


    // MARK: - Files

    ///
    /// Enumerates the image files.
    ///
    /// Returns the source file and the name of the destination file in the app bundle.
    ///

    func enumerateImageFiles() -> [(source: File, destination: String)] {

        var files = [(source: File, destination: String)]()

        for image in images {

            guard let source = try? folder.file(named: image.filename!) else {
                continue
            }

            let designationIdiom = image.idiom == "ipad" ? "~ipad" : ""
            let destinationScale = image.scale == "1x" ? "" : "@" + image.scale

            let destination = name + image.size + destinationScale + designationIdiom + ".png"

            let item = (source, destination)
            files.append(item)

        }

        return files

    }

}

// MARK: - AppIconSet.Image + Hashable

extension AppIconSet.Image: Equatable {

    static func == (lhs: AppIconSet.Image, rhs: AppIconSet.Image) -> Bool {
        return lhs.filename == rhs.filename && lhs.idiom == rhs.idiom && lhs.size == rhs.size && lhs.scale == rhs.scale
    }

}


// MARK: - AppIconSet + Hashable

extension AppIconSet: Hashable {

    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }

    static func == (lhs: AppIconSet, rhs: AppIconSet) -> Bool {
        return lhs === rhs
    }

}
