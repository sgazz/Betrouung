import SwiftUI

struct CalendarView: View {
    @Environment(\.appFlowAccent) private var accent
    @StateObject private var viewModel: CalendarViewModel
    @State private var isPresentingAddSheet = false
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var selectDayText: String {
        L10n.t("calendar.select_day", languageCode: selectedLanguageRaw)
    }

    private var profileText: String {
        L10n.t("calendar.profile", languageCode: selectedLanguageRaw)
    }

    private var allProfilesText: String {
        L10n.t("calendar.all_profiles", languageCode: selectedLanguageRaw)
    }

    private var dayEntriesTitle: String {
        L10n.t("calendar.entries_for_day", languageCode: selectedLanguageRaw)
    }

    private var noEntriesText: String {
        L10n.t("calendar.no_entries", languageCode: selectedLanguageRaw)
    }

    private var doneText: String {
        L10n.t("calendar.done", languageCode: selectedLanguageRaw)
    }

    private var deleteText: String {
        L10n.t("calendar.delete", languageCode: selectedLanguageRaw)
    }

    private var titleText: String {
        L10n.t("calendar.title", languageCode: selectedLanguageRaw)
    }

    private var addEntryA11yText: String {
        L10n.t("calendar.add_entry_a11y", languageCode: selectedLanguageRaw)
    }

    init(dataService: any DataService) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(dataService: dataService))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            List {
                Section {
                    DatePicker(
                        selectDayText,
                        selection: $viewModel.selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }
                .listRowBackground(Color.clear)

                Section {
                    Picker(profileText, selection: $viewModel.selectedProfileId) {
                        Text(allProfilesText).tag(UUID?.none)
                        ForEach(viewModel.profiles) { profile in
                            Text(profile.name).tag(Optional(profile.id))
                        }
                    }
                    .pickerStyle(.menu)
                }
                .listRowBackground(Color.clear)

                Section(dayEntriesTitle) {
                    if viewModel.entriesForSelectedDate.isEmpty {
                        ContentUnavailableView(noEntriesText, systemImage: "calendar.badge.exclamationmark")
                            .frame(maxWidth: .infinity, minHeight: 160)
                    } else {
                        ForEach(viewModel.entriesForSelectedDate) { entry in
                            entryRow(entry)
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        viewModel.toggleCompleted(id: entry.id)
                                    } label: {
                                        Label(doneText, systemImage: "checkmark")
                                    }
                                    .tint(AppPalette.green)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.delete(id: entry.id)
                                    } label: {
                                        Label(deleteText, systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AppBrandTitleView(title: "DailyCareCart")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(accent.primary)
                }
                .accessibilityLabel(addEntryA11yText)
            }
        }
        .sheet(isPresented: $isPresentingAddSheet) {
            DayDetailSheet(
                selectedDate: viewModel.selectedDate,
                profiles: viewModel.profiles,
                defaultKind: accent == .care ? .careReminder : .shopping
            ) { kind, title, notes, date, profileId in
                if kind == .shopping {
                    viewModel.addShoppingEvent(
                        title: title,
                        notes: notes,
                        scheduledAt: date,
                        profileId: profileId
                    )
                } else {
                    viewModel.addCareReminder(
                        title: title,
                        notes: notes,
                        scheduledAt: date,
                        profileId: profileId
                    )
                }
            }
            .presentationDetents([.large])
        }
        .onAppear { viewModel.refresh() }
    }

    private func entryRow(_ entry: CalendarEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: entry.kind == .shopping ? "cart.fill" : "heart.text.square.fill")
                .foregroundStyle(entry.kind == .shopping ? AppPalette.orange : AppPalette.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .strikethrough(entry.isCompleted)
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Text(entry.scheduledAt.formatted(date: .omitted, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if entry.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppPalette.green)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct DayDetailSheet: View {
    let selectedDate: Date
    let profiles: [CareProfile]
    let defaultKind: CalendarEntryKind
    let onSave: (CalendarEntryKind, String, String, Date, UUID?) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue
    @State private var kind: CalendarEntryKind
    @State private var profileId: UUID?
    @State private var title = ""
    @State private var notes = ""
    @State private var scheduledAt: Date

    init(
        selectedDate: Date,
        profiles: [CareProfile],
        defaultKind: CalendarEntryKind = .shopping,
        onSave: @escaping (CalendarEntryKind, String, String, Date, UUID?) -> Void
    ) {
        self.selectedDate = selectedDate
        self.profiles = profiles
        self.defaultKind = defaultKind
        self.onSave = onSave
        _kind = State(initialValue: defaultKind)
        _scheduledAt = State(initialValue: selectedDate)
    }

    private var typeText: String {
        L10n.t("calendar.sheet.type", languageCode: selectedLanguageRaw)
    }

    private var entryTypeText: String {
        L10n.t("calendar.sheet.entry_type", languageCode: selectedLanguageRaw)
    }

    private var shoppingEventText: String {
        L10n.t("calendar.sheet.shopping_event", languageCode: selectedLanguageRaw)
    }

    private var careReminderText: String {
        L10n.t("calendar.sheet.care_reminder", languageCode: selectedLanguageRaw)
    }

    private var profileText: String {
        L10n.t("calendar.profile", languageCode: selectedLanguageRaw)
    }

    private var noProfileText: String {
        L10n.t("calendar.sheet.no_profile", languageCode: selectedLanguageRaw)
    }

    private var detailsText: String {
        L10n.t("calendar.sheet.details", languageCode: selectedLanguageRaw)
    }

    private var titleFieldText: String {
        L10n.t("calendar.sheet.title", languageCode: selectedLanguageRaw)
    }

    private var notesFieldText: String {
        L10n.t("calendar.sheet.notes", languageCode: selectedLanguageRaw)
    }

    private var dateTimeText: String {
        L10n.t("calendar.sheet.date_time", languageCode: selectedLanguageRaw)
    }

    private var newEntryText: String {
        L10n.t("calendar.sheet.new_entry", languageCode: selectedLanguageRaw)
    }

    private var cancelText: String {
        L10n.t("common.cancel", languageCode: selectedLanguageRaw)
    }

    private var saveText: String {
        L10n.t("calendar.sheet.save", languageCode: selectedLanguageRaw)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(typeText) {
                    Picker(entryTypeText, selection: $kind) {
                        Text(shoppingEventText).tag(CalendarEntryKind.shopping)
                        Text(careReminderText).tag(CalendarEntryKind.careReminder)
                    }
                    .pickerStyle(.segmented)
                }

                Section(profileText) {
                    Picker(profileText, selection: $profileId) {
                        Text(noProfileText).tag(UUID?.none)
                        ForEach(profiles) { profile in
                            Text(profile.name).tag(Optional(profile.id))
                        }
                    }
                }

                Section(detailsText) {
                    HStack(spacing: 8) {
                        TextField(titleFieldText, text: $title)
                        VoiceInputButton(text: $title)
                    }
                    HStack(alignment: .top, spacing: 8) {
                        TextField(notesFieldText, text: $notes, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                        VoiceInputButton(text: $notes)
                    }
                    DatePicker(dateTimeText, selection: $scheduledAt)
                }
            }
            .navigationTitle(newEntryText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cancelText) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveText) {
                        onSave(kind, title, notes, scheduledAt, profileId)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView(dataService: LocalDataService())
    }
}
