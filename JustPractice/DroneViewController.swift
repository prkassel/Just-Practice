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
    }
    
    var notes: [Note] = []

    func createOscillator(frequency: Double) -> AKOscillator {
        let oscillator = AKOscillator(waveform: AKTable(.triangle))
        oscillator.frequency = frequency
        oscillator.rampDuration = 0.0
        oscillator.start()
        return oscillator
    }
    
    lazy var oscillators = initialFrequencies.map {
        createOscillator(frequency: $0)
    }
    
    var mixer = AKMixer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        notes.append(Note(isToggled: true, oscillator: 0, amplitude: 2.0))
        notes.append(Note(isToggled: true, oscillator: 1, amplitude: 1.0))
        notes.append(Note(isToggled: true, oscillator: 2, amplitude: 1.5))
        
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
    
    @IBOutlet weak var NotePicker: UIPickerView!
    
    

    @IBAction func ToggleDrone(_ sender: UIButton) {
        if oscillators[0].isPlaying {
            oscillators.forEach { $0.stop() }
            sender.setTitle("Play", for: .normal)
        } else {
            for i in 0 ... notes.count - 1 {
                if notes[i].isToggled {
                    oscillators[i].play()
                }
            }
            sender.setTitle("Stop", for: .normal)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(settings)
        print(initialFrequencies)
        NotePicker.delegate = self
        NotePicker.dataSource = self
        NotePicker.selectRow(settings.interval + 24, inComponent: 0, animated: true)
        
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
        print (interval)
        settingsController.saveUserSettings(settings.concertPitch, Tempo: 80.0, Interval: interval)
    }
}
