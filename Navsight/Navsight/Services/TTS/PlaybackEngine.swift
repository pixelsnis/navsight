//
//  PlaybackEngine.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import AVFoundation
import Combine
import Foundation

class PlaybackEngine: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var cue: AudioCue? = nil
    @Published var dialogue: Dialogue? = nil

    override init() {
        super.init()

        // Initialize a timer to monitor the playback every 0.1 seconds
        monitoringTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { _ in
                // Check if the player is currently playing
                if self.player?.isPlaying != true {
                    return
                }

                // Compare the current transcription segment with the last sent transcription
                // If they differ, send the new transcription segment
                if let transcription = self.currentTranscriptionSegment(),
                    transcription != self.transcriptionSubject.value
                {
                    self.transcriptionSubject.send(transcription)
                }

                // Update the player's meters to get the current audio levels
                self.player?.updateMeters()

                // Calculate the average power and linear level of the audio
                self.averagePower = Double(self.player?.averagePower(forChannel: 0) ?? 0)
                self.linearLevel = pow(10, self.averagePower / 20)
            }
    }

    // MARK: Power monitoring
    @Published private(set) var averagePower: Double = 0.0
    @Published private(set) var linearLevel: Double = 0.0
    private var monitoringTimer: AnyCancellable?

    // MARK: Additional functionality
    private var onFinishPlayback: (() -> Void)? = nil

    // MARK: Playback control
    func play(onFinishPlayback: (() -> Void)? = nil) throws {
        if player == nil { throw "Player was not initialized" }

        // Prepare the audio session for playback
        try session.setActive(true)
        try session.setCategory(.playback)

        // Prepare the player for playback
        player?.prepareToPlay()
        player?.play()

        // Store the completion handler for playback finish
        self.onFinishPlayback = onFinishPlayback
    }

    func stop() throws {
        // Deactivate the audio session and set it to ambient category to allow other audio to play
        try session.setActive(false)
        try session.setCategory(.ambient)

        // Stop the player
        player?.stop()

        // Call the completion handler if set
        self.onFinishPlayback?()
        self.onFinishPlayback = nil

        // Reset the audio levels
        self.linearLevel = 0
        self.averagePower = 0
    }

    @MainActor
    func load(_ cue: AudioCue) throws {
        self.cue = cue

        // Determine the language for the dialogue based on user preferences
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        self.dialogue = cue.localizedCues?[language] ?? cue.defaultCue

        // Log the transcription length for debugging purposes
        print("Transcription length for dialogue: \(dialogue?.transcription.count ?? -1)")

        // Attempt to load audio data for the dialogue
        var data: Data? = dialogue?.data

        // If data is not directly available, try to load it from a bundle asset
        if data == nil, let assetName = dialogue?.assetName {
            guard let fileURL = Bundle.main.url(forResource: assetName, withExtension: "mp3") else {
                throw "Could not locate asset: \(assetName)"
            }
            print("Loading bundle asset from: \(fileURL.absoluteString)")
            data = try Data(contentsOf: fileURL)
        }

        // Ensure data is available before proceeding
        guard let data else { throw "No bytes could be loaded into player" }

        // Initialize the player with the loaded data
        player = try AVAudioPlayer(data: data)
        player?.isMeteringEnabled = true
        player?.delegate = self

        // Log the successful loading of data into the player
        print("Data loaded into player")

        // Add the first transcription segment to the stream
        if let transcription = dialogue?.transcription.first?.text {
            transcriptionSubject.send(transcription)
        }
    }

    // MARK: Player delegate handlers
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Call the completion handler when playback finishes
        self.onFinishPlayback?()
        self.onFinishPlayback = nil
    }

    // Transcription handling
    let transcriptionSubject = CurrentValueSubject<String, Never>("")

    // MARK: Private, internal
    private(set) var player: AVAudioPlayer? = nil
    private let session = AVAudioSession.sharedInstance()
}
