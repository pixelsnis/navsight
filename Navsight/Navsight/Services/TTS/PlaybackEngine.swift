//
//  PlaybackEngine.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import AVFoundation
import Foundation

class PlaybackEngine: ObservableObject {
    // MARK: Private, internal
    private var player: AVAudioPlayer
    private let session = AVAudioSession.sharedInstance()
    
    init(data: Data) throws {
        player = try AVAudioPlayer(data: data)
        
        player.isMeteringEnabled = true
    }
    
    // MARK: Power monitoring
    private var averagePower: Double = 0.0
    private var linearLevel: Double = 0.0
    
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
}
