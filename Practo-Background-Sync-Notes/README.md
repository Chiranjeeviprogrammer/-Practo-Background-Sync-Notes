# Practo-Background-Sync-Notes

# Practo Background Sync & Note Taker

A SwiftUI iOS assignment implementation for local note management and simulated background synchronization.

## Requirements covered

- Create, read, update, and delete notes locally.
- Persist notes as JSON in the app's Documents directory.
- Upload note title/body to `POST https://jsonplaceholder.typicode.com/posts`.
- Wait 3 seconds before each attempted request.
- Simulate a network error with a 30% probability before calling the API.
- Retry failed uploads using exponential backoff (1, 2, 4, 8 seconds; up to 4 retries).
- Show Pending, Syncing, Failed, and Synced states.
- Request extra background execution time using `UIApplication.shared.beginBackgroundTask`.
- Ignore stale upload completions by checking the note's version before updating local status.

## Race-condition handling

Every note has a local UUID and an incrementing `version`. An upload captures the version it started with. If the user edits the note while an upload is in progress, the version increases and a new sync starts. When an earlier request completes, the ViewModel compares the captured version with the current version. If they differ, the old result is ignored, so an older request cannot mark newer content as synced.

The prior task is also cancelled when possible. Cancellation alone is not treated as the only protection because a network request may already have reached the server.

## Background task expiration

`SyncService` requests a finite background execution window with `beginBackgroundTask`. It ends the task identifier in a `defer` path and also handles the expiration callback. Background execution time is limited by iOS and is not guaranteed to finish every network operation. A production app that must reliably complete transfers after suspension should consider a background `URLSession` upload design; this assignment specifically asks for `beginBackgroundTask`.

## Mock API note

JSONPlaceholder is a mock API. It returns a simulated response and does not permanently store these notes for later retrieval. The local JSON file remains the source of truth for the user's notes.

## Project setup

The source files are arranged under `Sources/`. To build and run this as an iOS app, create an iOS App project in Xcode (SwiftUI lifecycle, iOS 17 or later recommended) and add all files under `Sources/` to the app target. Add `Tests/RetryPolicyTests.swift` to an XCTest target. Set the test target's `@testable import` module name to match the app target's product module name if you choose a different target name.

This repository contains source code and documentation; it has not been built or run in Xcode in this environment. Before submission, build and test it on macOS and fix any compiler or runtime issues found.

## Suggested repository name

`Practo-Background-Sync-Notes`
