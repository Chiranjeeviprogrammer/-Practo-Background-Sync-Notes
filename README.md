# Practo Background Sync & Note Taker

This project is an iOS app built using SwiftUI. It allows users to create and manage notes locally and sync them with a mock API.

## Features

- Create, edit, and delete notes.
- Save notes locally in a JSON file.
- Sync notes with the JSONPlaceholder API.
- Add a 3-second delay before each API request.
- Simulate network failures with a 30% chance.
- Retry failed requests using exponential backoff.
- Show the sync status of each note: Pending, Syncing, Failed, or Synced.
- Request additional background execution time using `beginBackgroundTask`.

## Handling Note Updates During Sync

Each note has a unique ID and a version number. When a note is edited, its version number increases.

Before updating the sync status, the app checks whether the note has changed since the upload started. If a newer version exists, the result of the older upload is ignored. This prevents an outdated request from marking the latest version as synced.

The app also attempts to cancel an older sync when possible. Since a request may already have reached the server, version checking is still used to protect the local note status.

## Background Execution

The app uses `UIApplication.shared.beginBackgroundTask` to request additional time to finish a sync when it moves to the background.

iOS controls how much background execution time an app receives, so completion is not guaranteed. The app handles task expiration and ends the background task when it is no longer needed.

For a production app that needs more reliable background transfers, a background `URLSession` could be considered.

## API

The app sends note titles and bodies to:

`POST https://jsonplaceholder.typicode.com/posts`

JSONPlaceholder is a mock API, so uploaded notes are not permanently saved for later retrieval. The local JSON file remains the main source of the user's notes.

## Project Structure

- `Sources/Models` – Note model
- `Sources/Services` – Local storage, API requests, and sync handling
- `Sources/ViewModels` – Note-related app logic
- `Sources/Views` – SwiftUI screens
- `Sources/Utilities` – Retry logic
- `Tests` – Retry policy tests

## Setup

The project uses SwiftUI and targets iOS 17 or later. Open the generated Xcode project on a Mac, check the app and test targets, then build and run the project.

The GitHub Actions workflow can be used to build the project in a macOS environment. Actual device installation and testing require a properly signed iOS app.
