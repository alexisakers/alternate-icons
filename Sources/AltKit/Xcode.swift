import Foundation

///
/// A set of environment variables exported by Xcode during build phases.
///

enum Xcode {

    /// The path to the build products directory.
    static var buildProductsDir: String? {
        return get(variable: "BUILT_PRODUCTS_DIR")
    }

    /// The path to the contents folder.
    static var contentsFolderPath: String? {
        return get(variable: "CONTENTS_FOLDER_PATH")
    }

    /// The input files of the script.
    static var scriptInputFiles: [String]? {

        guard let count = get(variable: "SCRIPT_INPUT_FILE_COUNT").flatMap({ Int($0) }) else {
            return nil
        }

        var inputFiles = [String]()

        for index in 0 ..< count {

            guard let path = get(variable: "SCRIPT_INPUT_FILE_\(index)") else {
                return nil
            }

            inputFiles.append(path)

        }

        return inputFiles


    }


    // MARK: - Utilities

    ///
    /// Returns the value of the environment variable.
    ///

    static func get(variable: String) -> String? {

        guard let cVariable = getenv(variable) else {
            return nil
        }

        return String(cString: cVariable)

    }

}
