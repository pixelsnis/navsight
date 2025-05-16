//
//  SFXPlayer.swift
//  Navsight
//
//  Created by Aneesh on 16/5/25.
//

import AVFoundation
import Foundation

class SFXPlayer {
    private(set) var activationInPlayer: AVAudioPlayer? = nil
    private(set) var activationOutPlayer: AVAudioPlayer? = nil
    private(set) var thinkingPlayer: AVAudioPlayer? = nil
    
    func initialize() throws {
        guard let activationInSoundURL = Bundle.main.url(forResource: "Activation In", withExtension: "mp3"), let activationOutSoundURL = Bundle.main.url(forResource: "Activation Out", withExtension: "mp3"), let thinkingSoundURL = Bundle.main.url(forResource: "Thinking", withExtension: "mp3") else { throw "Asset files not found" }
        
        activationInPlayer = try AVAudioPlayer(contentsOf: activationInSoundURL)
        activationOutPlayer = try AVAudioPlayer(contentsOf: activationOutSoundURL)
        thinkingPlayer = try AVAudioPlayer(contentsOf: thinkingSoundURL)
        
        thinkingPlayer?.numberOfLoops = -1
    }
    
    func playActivationInSound() {
        thinkingPlayer?.stop()
        activationInPlayer?.play()
    }
    
    func playActivationOutSound() {
        activationOutPlayer?.play()
    }
    
    func playThinkingSound() {
        thinkingPlayer?.play()
    }
    
    func stopThinkingSound() {
        thinkingPlayer?.stop()
    }
}
