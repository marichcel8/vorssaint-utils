// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct NotchHideRulesStrings {
    let when: String
    let inFullscreen: String
    let always: String
    let apps: String
    let anyApp: String
    let onlyApps: String
    let exceptApps: String
    let onlyListTitle: String
    let exceptListTitle: String
    let onlyCaption: String
    let exceptCaption: String
    let addApp: String
    let removeApp: String
    let displays: String
    let displaysCaption: String
    let unnamedDisplay: String
    let activityPicker: String
    let activityPickerHint: String
}

extension FeatureStrings {
    /// German has its own wording; every other language reads English.
    static func notchHideRules(_ language: AppLanguage) -> NotchHideRulesStrings {
        language == .de ? .de : .enUS
    }
}

extension NotchHideRulesStrings {
    static let enUS = NotchHideRulesStrings(
        when: "When",
        inFullscreen: "In full screen",
        always: "Always",
        apps: "Apps",
        anyApp: "Any app",
        onlyApps: "Only when these apps are focused",
        exceptApps: "Except when these apps are focused",
        onlyListTitle: "Hide for these apps",
        exceptListTitle: "Never hide for these apps",
        onlyCaption: "The island steps aside only while one of these apps is in front, such as a game.",
        exceptCaption: "The island steps aside for every app except these.",
        addApp: "Add App…",
        removeApp: "Remove",
        displays: "Hide on",
        displaysCaption: "Displays switched off here always keep the island.",
        unnamedDisplay: "Display",
        activityPicker: "Choose between activities",
        activityPickerHint: "Hovering over the closed island while several activities run shows a chooser.")

    static let de = NotchHideRulesStrings(
        when: "Wann",
        inFullscreen: "Im Vollbild",
        always: "Immer",
        apps: "Apps",
        anyApp: "Jede App",
        onlyApps: "Nur wenn diese Apps im Fokus sind",
        exceptApps: "Außer wenn diese Apps im Fokus sind",
        onlyListTitle: "Für diese Apps ausblenden",
        exceptListTitle: "Für diese Apps nie ausblenden",
        onlyCaption: "Die Island verschwindet nur, solange eine dieser Apps vorne ist, zum Beispiel ein Spiel.",
        exceptCaption: "Die Island verschwindet bei jeder App außer diesen.",
        addApp: "App hinzufügen …",
        removeApp: "Entfernen",
        displays: "Ausblenden auf",
        displaysCaption: "Ausgeschaltete Bildschirme behalten die Island immer.",
        unnamedDisplay: "Bildschirm",
        activityPicker: "Zwischen Aktivitäten wählen",
        activityPickerHint: "Laufen mehrere Aktivitäten, zeigt die geschlossene Island beim Darüberfahren eine Auswahl.")
}
