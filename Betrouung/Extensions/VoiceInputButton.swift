import SwiftUI

struct VoiceInputButton: View {
    @Binding var text: String
    @Environment(\.appFlowAccent) private var accent
    @StateObject private var manager = VoiceInputManager()

    var body: some View {
        Button {
            manager.toggle(target: $text)
        } label: {
            Image(systemName: iconName)
                .font(.headline)
                .frame(width: 44, height: 44)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(.white)
        }
        .buttonStyle(PrimaryCTAButtonStyle())
        .accessibilityLabel("Voice input")
    }

    private var iconName: String {
        switch manager.state {
        case .listening:
            return "mic.fill"
        case .idle, .unavailable:
            return "mic"
        }
    }

    private var backgroundColor: Color {
        switch manager.state {
        case .listening:
            return AppPalette.red
        case .idle:
            return accent.primary
        case .unavailable:
            return .gray
        }
    }
}
