//
//  AudioCues.swift
//  Navsight
//
//  Created by Aneesh on 12/5/25.
//

import Foundation

enum IntroDialogues {
    static let english: Dialogue = .init(asset: "opener-english", transcription: [
        .init(text: "Welcome to Navsight.", time: 0),
        .init(text: "The next steps require a sighted person to help set things up.", time: 1.6),
        .init(text: "Once they have your phone, please ask them to tap the button below.", time: 5.5)
    ])
    
    static let hindi: Dialogue = .init(asset: "opener-hindi", transcription: [
        .init(text: "स्वागत है Navsight में।", time: 0),
        .init(text: "अगले कदम सेट अप करने के लिए, किसी देखने वाले व्यक्ति की मदद चाहिए।", time: 2.0),
        .init(text: "जब उनके पास आपका फोन हो, कृपया उनसे कहिए कि नीचे दिए गए बटन को टैप करें।", time: 7.0)
    ])
    
    static let kannada: Dialogue = .init(asset: "opener-kannada", transcription: [
        .init(text: "Navsight ಗೆ ಸ್ವಾಗತ.", time: 0),
        .init(text: "ಮುಂದಿನ ಸ್ಟೆಪ್ಸ್ ಸೆಟ್ ಅಪ್ ಮಾಡಲು, ನೋಡಲು ಬರುವವರ ಸಹಾಯ ಬೇಕು.", time: 1.9),
        .init(text: "ಅವರು ನಿಮ್ಮ ಫೋನ್ ಸಿಕ್ಕಿದ ಮೇಲೆ, ದಯವಿಟ್ಟು ಅವರಿಗೆ ಹೇಳಿ ಕೆಳಗೆ ಕೊಟ್ಟಿರುವ ಬಟನ್ ಅನ್ನು ಟ್ಯಾಪ್ ಮಾಡಲು.", time: 5.8)
    ])
    
    static let cue: AudioCue = .init(default: english, localizedCues: [
        "en": english,
        "hi": hindi,
        "kn": kannada
    ])
}

enum OnboardingDialogues {
    static let english: Dialogue = .init(asset: "onboarding-english", transcription: [
        .init(text: "Welcome.", time: 0),
        .init(text: "Navsight helps you stay aware of where you are during your ride.", time: 0.8),
        .init(text: "Your location is shared in real time with your guardian, so they can make sure you're safe.", time: 5.0),
        .init(text: "Whenever you want to check where you are, just press and hold anywhere on the screen.", time: 11.0),
        .init(text: "You’ll feel a small vibration—then I’ll tell you your current location.", time: 16.5),
        .init(text: "When you're ready, try pressing on the screen to know where you are.", time: 21.5)
    ])
    
    static let hindi: Dialogue = .init(asset: "onboarding-hindi", transcription: [
        .init(text: "स्वागत है!", time: 0),
        .init(text: "Navsight आपको आपकी राइड के दौरान यह जानने में मदद करता है कि आप कहाँ हैं।", time: 1.0),
        .init(text: "आपकी लोकेशन आपके गार्जियन के साथ रियल टाइम में शेयर होती है, ताकि वे यह सुनिश्चित कर सकें कि आप सुरक्षित हैं।", time: 6.0),
        .init(text: "जब भी आप जानना चाहें कि आप कहाँ हैं, बस स्क्रीन पर कहीं भी दबाकर रखिए।", time: 13.0),
        .init(text: "आपको एक छोटा वाइब्रेशन महसूस होगा—फिर मैं आपको आपकी करंट लोकेशन बताऊँगी।", time: 17.5),
        .init(text: "जब आप तैयार हों, तो यह जानने के लिए स्क्रीन पर दबाने की कोशिश कीजिए कि आप कहाँ हैं।", time: 23.0)
    ])
    
    static let kannada: Dialogue = .init(asset: "onboarding-kannada", transcription: [
        .init(text: "ಸ್ವಾಗತ! ನಿಮ್ಮ ರಾಯಡ್ ಸಮೆಯದಲ್ಲಿ ಇವೆಲ್ಲಿ ದಿರಿಯಂದು ತಿಳಿಯಲ್ಲು ನಾವ್ ಸಾಯಿಟ್ ಸಹಾಯಮ ಆಡ್ಪತೆ.", time: 0),
        .init(text: "ನಿವು ಸುರಕ್ಷಿತವಾಗಿ ಇತ್ತಿರಿಯಂದು ನಿಮ್ಮ ಗಾರಿಯನ್ ಕಚಿತಪಣಿಸಿಕೊಳ್ಳಲ್ಲು, ನಿಮ ಲೋಕೇಶನನ್ನು ಅವರೊಂದೆಗೆ ರಿಯಲ್ ತಾಯಿಮ್ ನಲ್ಲಿ ಹಂಚಿಕೊಳ್ಳಲಾಗುತ್ತೆ.", time: 5.0),
        .init(text: "ನಿವು ಎಲ್ಲಿಬ್ಬಿರಿ ಎಂದು ಯಾವಾಗ ಬೇಕಾದರು ಚೆಕ್ ಮಾಡಲು ಸ್ಕ್ರೀನ್ ಮೇಲೆ ಎಲ್ಲಾದರು ಒತ್ತಿಹಿಡಿಯಿರಿ.", time: 13),
        .init(text: "ನಿಮಗೆ ಒಂದು ಸನ್ನ ವಾಯಪ್ರೇಶನ್ ಅನಿಸುತ್ತದೆ.", time: 18),
        .init(text: "ನಂತರ ನಾನು ನಿಮ್ಮ ಇಗಿನ ಲೋಕೇಶನ ಹೇಳುತ್ತೆನೆ.", time: 21),
        .init(text: "ನಿವು ತಯಾರಾದಾಗ ನಿವು ಯಲ್ಲಿದ್ದಿರಿ ಎಂದು ತಿಳಿಯಲು ಸ್ಕ್ರಿನ್ ಮೇಲೆ ಉತ್ತುವ ಪ್ರೈತ್ನ ಮಾಡಿ.", time: 24.0)
    ])
    
    static let cue: AudioCue = .init(default: english, localizedCues: [
        "en": english,
        "hi": hindi,
        "kn": kannada
    ])
}
