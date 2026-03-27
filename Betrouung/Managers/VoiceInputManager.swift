import AVFoundation
import Combine
import Foundation
import Speech
import SwiftUI

@MainActor
final class VoiceInputManager: NSObject, ObservableObject {
    enum State: Equatable {
        case idle
        case listening
        case unavailable(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var transcript: String = ""

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func toggle(target: Binding<String>) {
        switch state {
        case .listening:
            stopListening()
        case .idle, .unavailable:
            Task {
                await startListening(target: target)
            }
        }
    }

    func stopListening() {
        guard case .listening = state else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        state = .idle
    }

    private func startListening(target: Binding<String>) async {
        do {
            guard speechRecognizer?.isAvailable == true else {
                state = .unavailable("Speech recognition is currently unavailable.")
                return
            }

            let speechAuth = await requestSpeechAuthorization()
            guard speechAuth == .authorized else {
                state = .unavailable("Speech permission denied.")
                return
            }

            let micAuth = await requestMicrophonePermission()
            guard micAuth else {
                state = .unavailable("Microphone permission denied.")
                return
            }

            try configureAudioSession()
            try startRecognition(target: target)
            state = .listening
        } catch {
            state = .unavailable(error.localizedDescription)
        }
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startRecognition(target: Binding<String>) throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw NSError(domain: "VoiceInputManager", code: -1)
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            recognitionRequest.append(buffer)
            guard let self else { return }
            Task { @MainActor in
                if case .listening = self.state {
                    // Keep audio flow alive during capture.
                }
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                if let result {
                    let spokenText = result.bestTranscription.formattedString
                    self.transcript = spokenText
                    target.wrappedValue = spokenText
                    if result.isFinal {
                        self.stopListening()
                    }
                }

                if let error {
                    self.state = .unavailable(error.localizedDescription)
                    self.stopListening()
                }
            }
        }
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
