import Foundation
import Files
import Unbox

///
/// The source images for the different sizes and resolutions of your iOS app icons.
///

class AppIconSet {

    ///
    /// An image from the set.
    ///

    struct Image {

        /// The name of the `.png` file.
        let filename: String

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
    let images: Set<Image>

    /// The name of the icon set.
    var name: String {
        return folder.nameExcludingExtension
    }
    

    // MARK: - Lifecycle

    ///
    /// Creates an app icon set reference.
    ///
    /// - parameter folder: The folder containing the icon set.
    ///

    init(folder: Folder) throws {

        let contentsJSON = try folder.file(named: "Contents.json")
        let contentsData = try contentsJSON.read()
        let imagesArray: [Image] = try unbox(data: contentsData, atKeyPath: "images")

        self.images = Set<Image>(imagesArray)
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

            guard let source = try? folder.file(named: image.filename) else {
                continue
            }

            let designationIdiom = image.idiom == "ipad" ? "~ipad" : ""
            let destinationScale = image.scale != "1x" ? "@" + image.scale : ""

            let destination = name + image.size + destinationScale + designationIdiom

            let item = (source, destination)
            files.append(item)

        }

        return files

    }

}


// MARK: - AppIconSet.Image + Unboxable

extension AppIconSet.Image: Unboxable {

    init(unboxer: Unboxer) throws {

        filename = try unboxer.unbox(key: "filename")
        idiom = try unboxer.unbox(key: "idiom")
        size = try unboxer.unbox(key: "size")
        scale = try unboxer.unbox(key: "scale")

    }

}


// MARK: - AppIconSet.Image + Hashable

extension AppIconSet.Image: Hashable {

    var hashValue: Int {
        return filename.hashValue ^ idiom.hashValue ^ size.hashValue ^ scale.hashValue
    }

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
