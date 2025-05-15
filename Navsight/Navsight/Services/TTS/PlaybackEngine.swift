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
        
        monitoringTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink() { _ in
                if self.player?.isPlaying != true {
                    return
                }
               
                if let transcription = self.currentTranscriptionSegment(), transcription != self.transcriptionSubject.value {
                    self.transcriptionSubject.send(transcription)
                }
                
                self.player?.updateMeters()
                
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
        
        try session.setActive(true)
        try session.setCategory(.playback)
        
        player?.prepareToPlay()
        player?.play()
        
        self.onFinishPlayback = onFinishPlayback
    }
    
    func stop() throws {
        try session.setActive(false)
        try session.setCategory(.ambient)
        
        player?.stop()
        
        self.onFinishPlayback?()
        self.onFinishPlayback = nil
        
        self.linearLevel = 0
        self.averagePower = 0
    }
    
    @MainActor
    func load(_ cue: AudioCue) throws {
        self.cue = cue
        
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        self.dialogue = cue.localizedCues?[language] ?? cue.defaultCue
        
        print("Transcription length for dialogue: \(dialogue?.transcription.count ?? -1)")
        
        var data: Data? = dialogue?.data
        
        if data == nil, let assetName = dialogue?.assetName {
            guard let fileURL = Bundle.main.url(forResource: assetName, withExtension: "mp3") else { throw "Could not locate asset: \(assetName)" }
            print("Loading bundle asset from: \(fileURL.absoluteString)")
            data = try Data(contentsOf: fileURL)
        }
        
        guard let data else { throw "No bytes could be loaded into player" }
        
        player = try AVAudioPlayer(data: data)
        player?.isMeteringEnabled = true
        player?.delegate = self
        
        print("Data loaded into player")
        
        // Add the first transcription segment to the stream
        if let transcription = dialogue?.transcription.first?.text {
            transcriptionSubject.send(transcription)
        }
    }
    
    // MARK: Player delegate handlers
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.onFinishPlayback?()
        self.onFinishPlayback = nil
    }
    
    // Transcription handling
    let transcriptionSubject = CurrentValueSubject<String, Never>("")
    
    // MARK: Private, internal
    private(set) var player: AVAudioPlayer? = nil
    private let session = AVAudioSession.sharedInstance()
}
