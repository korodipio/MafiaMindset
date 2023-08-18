//
//  TimerView.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 11.08.23.
//

import UIKit
import LTMorphingLabel
import CoreHaptics

class TimerView: UIView {
    
    enum State {
        case playing
        case paused
    }
    
    var onComplete: (() -> Void)?
    var seconds: TimeInterval = 0 {
        didSet {
            didChangeSeconds()
        }
    }
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var vibroFeedback = true
    private var engine: CHHapticEngine?
    private var timer: Timer?
    private let titleLabel = LTMorphingLabel()
    private let timerLabel = LTMorphingLabel()
    private let minusButton = UIButton()
    private let plusButton = UIButton()
    private let playPauseButton = UIButton()
    private var state: State = .paused {
        didSet {
            didChangeState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        titleLabel.textAlignment = .center
        titleLabel.font = .rounded(ofSize: 20, weight: .regular)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timerLabel.text = "0"
        timerLabel.font = .rounded(ofSize: 60, weight: .bold)
        timerLabel.morphingEffect = .evaporate
        addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(playPauseButton)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plusButton)
        addSubview(minusButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: minusButton.topAnchor),
            
            minusButton.trailingAnchor.constraint(equalTo: centerXAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 120),
            minusButton.heightAnchor.constraint(equalToConstant: 120),
            minusButton.bottomAnchor.constraint(equalTo: timerLabel.topAnchor),
            
            plusButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 120),
            plusButton.heightAnchor.constraint(equalToConstant: 120),
            plusButton.bottomAnchor.constraint(equalTo: timerLabel.topAnchor),
            
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 120),
            playPauseButton.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        plusButton.tintColor = .primary
        minusButton.tintColor = .primary
        
        plusButton.setImage(.init(systemName: "plus.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 70)), for: .normal)
        minusButton.setImage(.init(systemName: "minus.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 70)), for: .normal)
        
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(didTapMinusButton), for: .touchUpInside)
        
        state = .paused
        playPauseButton.tintColor = .primary
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting haptic engine: \(error)")
        }
    }

    func playHapticPattern() {
        guard let engine else { return }

        // Define a haptic pattern with a longer and more complex sequence
        var events: [CHHapticEvent] = []
        
        // Start with a gentle tap
        let tapIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let tapSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let tapEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [tapIntensity, tapSharpness], relativeTime: 0, duration: 0.2)
        events.append(tapEvent)
        
        // Followed by a smooth buzz
        let buzzIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let buzzSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let buzzEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [buzzIntensity, buzzSharpness], relativeTime: 0.3, duration: 0.5)
        events.append(buzzEvent)
        
        // End with a quick tap
        let endTapIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let endTapSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let endTapEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [endTapIntensity, endTapSharpness], relativeTime: 0.9)
        events.append(endTapEvent)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Error playing haptic pattern: \(error)")
        }
    }

    
    @objc private func didTapPlusButton() {
        self.seconds += 15
    }
    
    @objc private func didTapMinusButton() {
        self.seconds -= min(15, self.seconds)
    }
    
    func start(seconds: TimeInterval) {
        guard Int(seconds) != 0 else { return }
        self.seconds = seconds
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        var initInterval = Date.now.timeIntervalSince1970
        let timer = Timer(fire: .now, interval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            
            let current = Date.now.timeIntervalSince1970
            let delta = current - initInterval
            initInterval = current
            self.seconds -= min(delta, self.seconds)
            if self.seconds == 0 {
                if self.vibroFeedback {
                    self.playHapticPattern()
                }
                self.stop()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        
        state = .playing
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        
        state = .paused
    }
    
    func resume() {
        start(seconds: seconds)
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
        UIApplication.shared.isIdleTimerDisabled = false
        
        state = .paused
        DispatchQueue.main.async {
            self.onComplete?()
        }
    }
    
    func reset(seconds: TimeInterval) {
        timer?.invalidate()
        timer = nil
        self.seconds = seconds
        self.state = .paused
    }
    
    @objc private func didTapPlayPauseButton() {
        switch state {
        case .paused:
            resume()
        case .playing:
            pause()
        }
    }
    
    private func didChangeState() {
        switch state {
        case .paused:
            playPauseButton.setImage(.init(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 70)), for: .normal)
        case .playing:
            playPauseButton.setImage(.init(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 70)), for: .normal)
        }
    }
    
    private func didChangeSeconds() {
        timerLabel.text = String(format: "%.f", self.seconds)
    }
}
