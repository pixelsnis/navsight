//
//  TranscriptionHandler.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import Foundation

extension PlaybackEngine {
    func currentTranscriptionSegment(at time: TimeInterval? = nil) -> String? {
        var interval: TimeInterval = time ?? player?.currentTime ?? 0
        interval += 0.5 // Show the transcription 500ms early to compensate for the fade out delay in the UI
        
        for segment in dialogue?.transcription.reversed() ?? [] {
            if interval >= segment.time { return segment.text }
        }
        
        return nil
    }
}
