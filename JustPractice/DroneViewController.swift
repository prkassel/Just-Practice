//
//  ViewController.swift
//  JustPractice
//
//  Created by Philip Kassel on 12/27/19.
//  Copyright © 2019 Philip Kassel. All rights reserved.
//

import UIKit
import AudioKit


class DroneViewController: UIViewController {
    let settingsController = SettingsController()
    let settings = SettingsController().getUserSettings()
    let musicController = MusicController()
    
    lazy var pickerNotes = musicController.getNotesForPicker()
    lazy var initialFrequencies = musicController.getTriadNotes(settings.concertPitch, settings.interval, false)
    
    struct Note {
        var isToggled: Bool
        var oscillator: Int
        var amplitude: Double
        var role: String
    }
    
    var notes: [Note] = []
    var isPlaying = false
    var isMinor = false

    func createOscillator(frequency: Double) -> AKOscillator {
        let oscillator = AKOscillator(waveform: AKTable(.triangle))
        oscillator.frequency = frequency
        oscillator.rampDuration = 0.0
        oscillator.start()
        return oscillator
    }
    
    func updateOscillators(_ interval: Int) {
        
        let frequencies = musicController.getTriadNotes(settings.concertPitch, interval, isMinor)
        
        for i in 0 ... frequencies.count - 1 {
            if notes[i].role == "Third" {
                notes[i].amplitude = (isMinor ? 0.75 : 1.0)
                oscillators[i].amplitude = notes[i].amplitude
            }
            oscillators[i].frequency = frequencies[i]
        }
    }
    
    lazy var oscillators = initialFrequencies.map {
        createOscillator(frequency: $0)
    }
    
    var mixer = AKMixer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        notes.append(Note(isToggled: true, oscillator: 0, amplitude: 2.0, role: "Root"))
        notes.append(Note(isToggled: true, oscillator: 1, amplitude: 1.0, role: "Third"))
        notes.append(Note(isToggled: true, oscillator: 2, amplitude: 1.5, role: "Fifth"))
        
        
        for i in 0 ... notes.count - 1{
            oscillators[i].amplitude = notes[i].amplitude
        }
        
        mixer = AKMixer(oscillators)
        AudioKit.output = mixer
        
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start")
        }
    }
    
    
    @IBAction func TriadChanged(_ sender: UISegmentedControl) {
        
        isMinor = Bool(truncating: sender.selectedSegmentIndex as NSNumber)
        let interval = NotePicker.selectedRow(inComponent: 0) - 24
        updateOscillators(interval)
        print(sender.selectedSegmentIndex, isMinor)
    }
    
    
    @IBOutlet weak var NotePicker: UIPickerView!

    @IBOutlet weak var RootSwitch: UISwitch!
    
    @IBOutlet weak var ThirdSwitch: UISwitch!
    
    @IBOutlet weak var FifthSwitch: UISwitch!
    
    @objc func toggleChanged(_ sender:UISwitch) {
        let index = notes.firstIndex(where: {$0.role == sender.accessibilityLabel})
        
        if sender.isOn {
            notes[index!].isToggled = true
            if isPlaying {
                oscillators[notes[index!].oscillator].play()
            }
        } else {
            notes[index!].isToggled = false
            oscillators[notes[index!].oscillator].stop()
        }
        
        if numberOfNotesPlaying() < 1 {
            playButton.setTitle("Play", for: .normal)
            isPlaying = false
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func ToggleDrone(_ sender: UIButton) {
        if isPlaying {
            oscillators.forEach { $0.stop() }
            sender.setTitle("Play", for: .normal)
            isPlaying = false
        } else {
            for i in 0 ... notes.count - 1 {
                if notes[i].isToggled {
                    oscillators[i].play()
                }
            }
            
            if numberOfNotesPlaying() > 0 {
                isPlaying = true
                sender.setTitle("Stop", for: .normal)
            }
        }
    }
    
    func numberOfNotesPlaying() -> Int {
        
        var notesPlaying = 0
        
        for i in 0 ... notes.count - 1 {
            if notes[i].isToggled {
                notesPlaying += 1
            }
        }
        return notesPlaying
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotePicker.delegate = self
        NotePicker.dataSource = self
        NotePicker.selectRow(settings.interval + 24, inComponent: 0, animated: true)
        
        RootSwitch.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        ThirdSwitch.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        FifthSwitch.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
    }

}

extension DroneViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerNotes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerNotes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let interval = row - 24
        settingsController.saveUserSettings(settings.concertPitch, settings.tempo, interval)
        updateOscillators(interval)
    }
}
