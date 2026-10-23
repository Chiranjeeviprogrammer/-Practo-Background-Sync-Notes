import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject private var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss

    private let existingNote: Note?
    @State private var title: String
    @State private var bodyText: String

    init(existingNote: Note? = nil) {
        self.existingNote = existingNote
        _title = State(initialValue: existingNote?.title ?? "")
        _bodyText = State(initialValue: existingNote?.body ?? "")
    }

    var body: some View {
        Form {
            Section("Title") {
                TextField("Enter a title", text: $title)
            }
            Section("Note") {
                TextEditor(text: $bodyText)
                    .frame(minHeight: 220)
            }
        }
        .navigationTitle(existingNote == nil ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                          && bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        if let existingNote {
            viewModel.updateNote(id: existingNote.id, title: title, body: bodyText)
        } else {
            viewModel.createNote(title: title, body: bodyText)
        }
        dismiss()
    }
}
