//
//  PlaybackEngine.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import AVFoundation
import Foundation

class PlaybackEngine: ObservableObject {
    var cue: AudioCue
    var dialogue: Dialogue
    
    init(cue: AudioCue) throws {
        self.cue = cue
        
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        self.dialogue = cue.localizedCues?[language] ?? cue.defaultCue
       
        var data: Data? = nil
        
        if let assetName = dialogue.assetName, let fileURL = Bundle.main.url(forResource: assetName, withExtension: nil) {
            data = try Data(contentsOf: fileURL)
        } else if let file = dialogue.file {
            data = try Data(contentsOf: file)
        }
        
        guard let data else { throw "No bytes could be loaded into player" }
        
        player = try AVAudioPlayer(data: data)
        player.isMeteringEnabled = true
    }
    
    // MARK: Power monitoring
    private var averagePower: Double = 0.0
    private var linearLevel: Double = 0.0
    
    // MARK: Playback control
    func play() throws {
        try session.setActive(true)
        try session.setCategory(.playback)
        
        player.prepareToPlay()
        player.play()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            guard self.player.isPlaying else {
                timer.invalidate()
                return
            }
            
            self.player.updateMeters()
            
            self.averagePower = Double(self.player.averagePower(forChannel: 0))
            self.linearLevel = pow(10, self.averagePower / 20)
        })
    }
    
    func stop() throws {
        try session.setActive(false)
        try session.setCategory(.ambient)
        
        player.stop()
    }
    
    // MARK: Private, internal
    private(set) var player: AVAudioPlayer
    private let session = AVAudioSession.sharedInstance()
}
