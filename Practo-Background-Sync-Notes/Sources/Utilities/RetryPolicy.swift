import Foundation

struct RetryPolicy {
    let maximumRetries: Int
    let initialDelaySeconds: Double
    let maximumDelaySeconds: Double

    static let standard = RetryPolicy(
        maximumRetries: 4,
        initialDelaySeconds: 1,
        maximumDelaySeconds: 16
    )

    func delayBeforeRetry(retryNumber: Int) -> Double {
        min(initialDelaySeconds * pow(2, Double(max(0, retryNumber - 1))),
            maximumDelaySeconds)
    }
}
