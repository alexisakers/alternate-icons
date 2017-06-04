import Foundation
import AltKit

do {
    Script.step("Parsing build context")
    let arguments = try Script.readArguments()
    try Script.run(with: arguments)
    Script.done()

} catch let error as LocalizedError {
    Script.fail(reason: error.errorDescription ?? "Unknown error")

} catch {
    Script.fail(reason: error.localizedDescription)
}

