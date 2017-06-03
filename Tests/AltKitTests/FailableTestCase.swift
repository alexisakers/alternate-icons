import XCTest
import Foundation

///
/// A subclass of `XCTestCase` that fails in `setUp` and `tearDown`.
///

class FailableTestCase: XCTestCase {

    override var continueAfterFailure: Bool {
        get {
            return false
        }
        set {}
    }

}
