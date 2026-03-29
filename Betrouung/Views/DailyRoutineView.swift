import SwiftUI

struct DailyRoutineView: View {
    let profile: CareProfile
    @StateObject private var viewModel: DailyRoutineViewModel
    @Environment(\.appFlowAccent) private var accent
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    init(profile: CareProfile, dataService: any DataService) {
        self.profile = profile
        _viewModel = StateObject(wrappedValue: DailyRoutineViewModel(profileId: profile.id, dataService: dataService))
    }

    private var titleText: String {
        L10n.t("routine.title", languageCode: selectedLanguageRaw)
    }

    private var emptyText: String {
        L10n.t("routine.empty", languageCode: selectedLanguageRaw)
    }

    private var editText: String {
        L10n.t("routine.edit", languageCode: selectedLanguageRaw)
    }

    private var doneEditingText: String {
        L10n.t("routine.done_editing", languageCode: selectedLanguageRaw)
    }

    private var cancelText: String {
        L10n.t("common.cancel", languageCode: selectedLanguageRaw)
    }

    private var addStepText: String {
        L10n.t("routine.add_step", languageCode: selectedLanguageRaw)
    }

    private var stepPlaceholder: String {
        L10n.t("routine.step_placeholder", languageCode: selectedLanguageRaw)
    }

    private var todayText: String {
        L10n.t("routine.today", languageCode: selectedLanguageRaw)
    }

    private var timeLabel: String {
        L10n.t("routine.time", languageCode: selectedLanguageRaw)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            if viewModel.isEditingTemplate {
                editTemplateContent
            } else {
                dayViewContent
            }
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AppBrandTitleView(title: "DailyCareCart")
            }
            if viewModel.isEditingTemplate {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isEditingTemplate {
                    Button(doneEditingText) {
                        viewModel.saveTemplateEdits()
                    }
                    .disabled(viewModel.editingSteps.contains { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
                } else {
                    Button(editText) {
                        viewModel.beginEditing()
                    }
                }
            }
        }
        .onAppear { viewModel.refresh() }
    }

    private var dayPickerBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.shiftSelectedDay(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(accent.primary)

            Spacer()
            VStack(spacing: 2) {
                Text(viewModel.selectedDay.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline.weight(.semibold))
                if !viewModel.isToday {
                    Button(todayText) {
                        viewModel.goToToday()
                    }
                    .font(.caption)
                    .foregroundStyle(accent.primary)
                }
            }
            Spacer()

            Button {
                viewModel.shiftSelectedDay(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(accent.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var dayViewContent: some View {
        VStack(spacing: 0) {
            dayPickerBar
                .background(Color(.secondarySystemBackground).opacity(0.5))

            if viewModel.sortedSteps.isEmpty {
                ContentUnavailableView(emptyText, systemImage: "checklist")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.sortedSteps) { step in
                        routineRow(step: step, completed: viewModel.completedStepIds.contains(step.id))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func routineRow(step: RoutineStep, completed: Bool) -> some View {
        Button {
            viewModel.toggleCompleted(stepId: step.id)
        } label: {
            HStack(alignment: .center, spacing: 14) {
                Text(timeString(for: step))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(accent.primary)
                    .frame(width: 64, alignment: .leading)

                Text(step.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .strikethrough(completed)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(completed ? AppPalette.green : .secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func timeString(for step: RoutineStep) -> String {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: viewModel.selectedDay)
        c.hour = step.hour
        c.minute = step.minute
        guard let d = Calendar.current.date(from: c) else { return "\(step.hour):\(step.minute)" }
        return d.formatted(date: .omitted, time: .shortened)
    }

    private var editTemplateContent: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(cancelText) {
                    viewModel.cancelEditing()
                }
                .foregroundStyle(accent.primary)
                .padding(.trailing, 16)
                .padding(.top, 8)
            }

            List {
                Section {
                    ForEach(viewModel.editingSteps) { step in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField(
                                stepPlaceholder,
                                text: Binding(
                                    get: {
                                        viewModel.editingSteps.first(where: { $0.id == step.id })?.title ?? ""
                                    },
                                    set: { viewModel.updateEditingStepTitle(id: step.id, title: $0) }
                                )
                            )
                            .font(.body)

                            DatePicker(
                                timeLabel,
                                selection: Binding(
                                    get: {
                                        guard let s = viewModel.editingSteps.first(where: { $0.id == step.id }) else {
                                            return viewModel.selectedDay
                                        }
                                        return viewModel.dateForStep(s)
                                    },
                                    set: { viewModel.updateEditingStepTime(id: step.id, date: $0) }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: viewModel.deleteEditingSteps)
                    .onMove(perform: viewModel.moveEditingSteps)
                }

                Section {
                    Button(addStepText) {
                        viewModel.addEditingStep()
                    }
                    .foregroundStyle(accent.primary)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    let profile = MockData.profiles[0]
    let data = LocalDataService()
    return NavigationStack {
        DailyRoutineView(profile: profile, dataService: data)
    }
}
