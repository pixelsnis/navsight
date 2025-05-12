//
//  TranscriptionHandler.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import Foundation

extension PlaybackEngine {
    func transcriptionSegment(at time: TimeInterval? = nil) -> String? {
        let interval: TimeInterval = time ?? player.currentTime
        
        for segment in dialogue.transcription.reversed() {
            if interval >= segment.time { return segment.text }
        }
        
        return nil
    }
}
