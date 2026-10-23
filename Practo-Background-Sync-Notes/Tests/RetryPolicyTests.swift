import XCTest
@testable import PractoBackgroundSyncNotes

final class RetryPolicyTests: XCTestCase {
    func testExponentialBackoffDoublesUntilMaximum() {
        let policy = RetryPolicy(
            maximumRetries: 5,
            initialDelaySeconds: 1,
            maximumDelaySeconds: 8
        )

        XCTAssertEqual(policy.delayBeforeRetry(retryNumber: 1), 1)
        XCTAssertEqual(policy.delayBeforeRetry(retryNumber: 2), 2)
        XCTAssertEqual(policy.delayBeforeRetry(retryNumber: 3), 4)
        XCTAssertEqual(policy.delayBeforeRetry(retryNumber: 4), 8)
        XCTAssertEqual(policy.delayBeforeRetry(retryNumber: 5), 8)
    }
}
