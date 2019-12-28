//
//  MusicController.swift
//  JustPractice
//
//  Created by Philip Kassel on 12/27/19.
//  Copyright © 2019 Philip Kassel. All rights reserved.
//
import Foundation

class MusicController {
    
    struct Defaults {
        let (CONCERTPITCH,TEMPO,INTERVAL) =  (440.0, 80.0, -12)
    }
    
    let TWELTHROOT = pow(2.0, 1.0/12.0)
    
    let NOTES = [
        "A",
        "Bb",
        "B",
        "C",
        "Db",
        "D",
        "Eb",
        "E",
        "F",
        "Gb",
        "G",
        "Ab",
        "A"
    ]
    
    let SCALES = [
        "Major",
        "Natural",
        "Harmonic",
        "Melodic",
        "Ionian",
        "Dorian",
        "Phrygian",
        "Lydian",
        "Mixolydian",
        "Aeolian",
        "Locrian"
    ]
    
    func getFrequencyFromInterval(_ concertPitch: Double, _ interval: Double) -> Double {
        var frequency = concertPitch * pow(TWELTHROOT, interval)
        frequency = (frequency * 100).rounded()/100
        return frequency
    }
    
    func getNoteFromInterval(_ interval: Int) -> String {
        var i = interval
        if i < 0 {
            i += 12
            return getNoteFromInterval(i)
        }
        
        else if i > 12 {
            i -= 12
        }
        
        return NOTES[i]
    }
    
    func getNotesForPicker() -> Array<String> {
        var notes: [String] = []
        
        for i in -12 ... 24 {
            notes.append(getNoteFromInterval(i))
        }
        return notes
    }
    
    func getTriadNotes(_ concertPitch: Double, _ rootInterval: Int, _ isMinor: Bool)  -> Array<Double> {
        let root = getFrequencyFromInterval(concertPitch, Double(rootInterval))
        let third = root * (isMinor ? 1.20 : 1.25)
        let fifth = root * 1.5
        return [root, third, fifth]
    }

}
