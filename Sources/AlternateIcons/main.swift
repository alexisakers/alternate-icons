import Foundation
import AltKit

do {
    let arguments = try Script.readArguments()
    try Script.run(with: arguments)

} catch let error as LocalizedError {
    Script.fail(reason: error.errorDescription ?? "Unknown error")

} catch {
    Script.fail(reason: error.localizedDescription)
}

