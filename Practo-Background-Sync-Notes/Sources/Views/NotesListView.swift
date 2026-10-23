import SwiftUI

struct NotesListView: View {
    @EnvironmentObject private var viewModel: NotesViewModel
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes Yet",
                        systemImage: "note.text",
                        description: Text("Tap + to create your first note.")
                    )
                } else {
                    List {
                        ForEach(viewModel.notes) { note in
                            NavigationLink {
                                NoteEditorView(existingNote: note)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(note.title.isEmpty ? "Untitled Note" : note.title)
                                        .font(.headline)
                                    Text(note.body)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                    HStack {
                                        Label(statusText(note.syncStatus),
                                              systemImage: statusIcon(note.syncStatus))
                                            .font(.caption)
                                        Spacer()
                                        if note.syncStatus == .failed {
                                            Button("Retry") {
                                                viewModel.retryNote(id: note.id)
                                            }
                                            .font(.caption)
                                            .buttonStyle(.borderless)
                                        }
                                    }
                                    .foregroundStyle(statusColor(note.syncStatus))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { offsets in
                            for offset in offsets {
                                viewModel.deleteNote(id: viewModel.notes[offset].id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add note")
                }
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack {
                    NoteEditorView()
                }
            }
            .alert("Notice", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private func statusText(_ status: SyncStatus) -> String {
        switch status {
        case .pending: return "Pending"
        case .syncing: return "Syncing..."
        case .failed: return "Failed"
        case .synced: return "Synced"
        }
    }

    private func statusIcon(_ status: SyncStatus) -> String {
        switch status {
        case .pending: return "clock"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .failed: return "exclamationmark.circle"
        case .synced: return "checkmark.circle"
        }
    }

    private func statusColor(_ status: SyncStatus) -> Color {
        switch status {
        case .pending: return .secondary
        case .syncing: return .blue
        case .failed: return .red
        case .synced: return .green
        }
    }
}
