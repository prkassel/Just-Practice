//
//  SettingsController.swift
//  JustPractice
//
//  Created by Philip Kassel on 12/27/19.
//  Copyright © 2019 Philip Kassel. All rights reserved.
//
import Foundation
let MusicDefaults = MusicController.Defaults()

class SettingsController {
    struct Defaults {
        
        static let (CONCERTPITCH, TEMPO, INTERVAL) = ("concertPitch", "tempo", "interval")
        static let USERSETTINGS = "userSettingsKey"
        static let userDefault = UserDefaults.standard
        
        
        struct UserSettings {
            
            let concertPitch: Double
            let tempo: Double
            let interval: Int
            
            init(_ json: [String: AnyObject]) {
                self.concertPitch = json[CONCERTPITCH] as? Double ?? MusicDefaults.CONCERTPITCH
                self.tempo = json[TEMPO] as? Double ??  MusicDefaults.TEMPO
                self.interval = json[INTERVAL] as? Int ?? MusicDefaults.INTERVAL
            }
        }
        
    }
    
    func saveUserSettings(_ concertPitch: Double, _ Tempo: Double, _ Interval: Int){
        
        Defaults.userDefault.set([
            Defaults.CONCERTPITCH: concertPitch,
            Defaults.TEMPO: Tempo,
            Defaults.INTERVAL: Interval],
                                 forKey: Defaults.USERSETTINGS)
    }
    
    func getUserSettings()-> Defaults.UserSettings {
        return Defaults.UserSettings((Defaults.userDefault.value(forKey: Defaults.USERSETTINGS) as? [String: AnyObject]) ?? [:])
    }
    
    func clearUserSettings() {
        Defaults.userDefault.removeObject(forKey: Defaults.USERSETTINGS)
    }
}
