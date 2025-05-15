//
//  AudioCue.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import Foundation

struct Dialogue {
    var data: Data?
    var assetName: String?
    var transcription: [TranscriptionSegment]
    
    init(data: Data? = nil, asset assetName: String? = nil, transcription: [TranscriptionSegment]) {
        assert(data != nil || assetName != nil, "Either raw audio data or an asset name must be provided")
        
        self.data = data
        self.assetName = assetName
        self.transcription = transcription
    }
}

struct TranscriptionSegment {
    var text: String
    var time: TimeInterval
    
    init(text: String, time: TimeInterval) {
        self.text = text
        self.time = time
    }
}

struct AudioCue {
    var defaultCue: Dialogue
    var localizedCues: [String: Dialogue]?
    
    init(default defaultCue: Dialogue, localizedCues: [String : Dialogue]? = nil) {
        self.defaultCue = defaultCue
        self.localizedCues = localizedCues
    }
}
