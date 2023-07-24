import Foundation
import Files

/// The list of files contained in an app icon set.
typealias AppIconFiles = [(name: String, source: File, destination: String)]

///
/// A set of source images for the different sizes and resolutions of your iOS app icon.
///

class AppIconSet {

    ///
    /// An image from the set.
    ///

    struct Image: Decodable, Hashable {

        /// The name of the `.png` file.
        let filename: String?

        /// The idiom of the icon.
        let idiom: String

        /// One of the sizes that matches the idiom for the icon.
        let size: String

        /// The scale of the icon.
        let scale: String

        func hash(into hasher: inout Hasher) {
            hasher.combine(filename)
            hasher.combine(idiom)
            hasher.combine(size)
            hasher.combine(scale)
        }

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
    /// - parameter filter: Whether the image should be included.
    ///
    /// Returns the source file and the name of the destination file in the app bundle.
    ///

    func enumerateImageFiles(unique: Bool, filter: (Image) -> Bool) -> AppIconFiles {

        var files = AppIconFiles()

        for image in images.filter(filter) {

            let fileName = name + image.size

            if unique && files.contains(where: { $0.name == fileName }) {
                continue
            }

            guard let source = try? folder.file(named: image.filename!) else {
                continue
            }

            let designationIdiom = image.idiom == "ipad" ? "~ipad" : ""
            let destinationScale = image.scale == "1x" ? "" : "@" + image.scale

            let destination = fileName + destinationScale + designationIdiom + ".png"

            let item = (fileName, source, destination)
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(folder.path)
        hasher.combine(images)
        hasher.combine(name)
    }

    static func == (lhs: AppIconSet, rhs: AppIconSet) -> Bool {
        return lhs === rhs
    }

}
