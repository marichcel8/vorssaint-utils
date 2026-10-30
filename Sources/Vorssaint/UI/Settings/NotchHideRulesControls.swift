// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import SwiftUI

/// The rules under "Hide content in full screen": when it hides, for which
/// focused apps, and on which displays. The island rereads them on every
/// preference change, so nothing here calls into it.
struct NotchHideRulesControls: View {
    @ObservedObject private var l10n = L10n.shared
    @AppStorage(DefaultsKey.notchHideTrigger) private var trigger = NotchHideRules.Trigger.fullscreen.rawValue
    @AppStorage(DefaultsKey.notchHideAppMode) private var appMode = NotchHideRules.AppMode.any.rawValue
    @State private var apps = NotchHideRules.current().apps
    @State private var keptDisplays = NotchHideRules.current().keptDisplays
    @State private var screens = Self.connectedScreens()

    private var text: NotchHideRulesStrings { FeatureStrings.notchHideRules(l10n.language) }
    private var mode: NotchHideRules.AppMode { NotchHideRules.AppMode(rawValue: appMode) ?? .any }

    var body: some View {
        SettingsRow(symbol: "clock", title: text.when) {
            Picker(text.when, selection: $trigger) {
                Text(text.inFullscreen).tag(NotchHideRules.Trigger.fullscreen.rawValue)
                Text(text.always).tag(NotchHideRules.Trigger.always.rawValue)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
        }
        SettingsRow(symbol: "app.badge", title: text.apps) {
            Picker(text.apps, selection: $appMode) {
                Text(text.anyApp).tag(NotchHideRules.AppMode.any.rawValue)
                Text(text.onlyApps).tag(NotchHideRules.AppMode.only.rawValue)
                Text(text.exceptApps).tag(NotchHideRules.AppMode.except.rawValue)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
        }
        if mode != .any {
            AppBundleList(title: mode == .only ? text.onlyListTitle : text.exceptListTitle,
                          caption: mode == .only ? text.onlyCaption : text.exceptCaption,
                          addTitle: text.addApp,
                          removeLabel: text.removeApp,
                          bundleIDs: apps,
                          reachesEveryApp: true,
                          acceptsExecutables: true,
                          onAdd: { saveApps(apps + [$0]) },
                          onRemove: { removed in saveApps(apps.filter { $0 != removed }) })
        }
        VStack(alignment: .leading, spacing: 6) {
            Text(text.displays).font(.callout.weight(.medium))
            ForEach(screens, id: \.uuid) { screen in
                Toggle(isOn: Binding(get: { !keptDisplays.contains(screen.uuid) },
                                     set: { setHides($0, on: screen.uuid) })) {
                    Label(screen.name, systemImage: screen.builtIn ? "laptopcomputer" : "display")
                }
                .toggleStyle(.switch)
            }
            Text(text.displaysCaption).font(.caption).foregroundStyle(.secondary)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)) { _ in
            screens = Self.connectedScreens()
        }
    }

    private func saveApps(_ updated: [String]) {
        let sanitized = Defaults.sanitizedBundleIdentifierList(updated)
        UserDefaults.standard.set(sanitized, forKey: DefaultsKey.notchHideApps)
        apps = sanitized
    }

    private func setHides(_ hides: Bool, on uuid: String) {
        if hides { keptDisplays.remove(uuid) } else { keptDisplays.insert(uuid) }
        UserDefaults.standard.set(keptDisplays.sorted(), forKey: DefaultsKey.notchHideKeptDisplays)
    }

    private struct Screen {
        let uuid: String
        let name: String
        let builtIn: Bool
    }

    private static func connectedScreens() -> [Screen] {
        let fallback = FeatureStrings.notchHideRules(L10n.shared.language).unnamedDisplay
        return NSScreen.screens.compactMap { screen in
            let id = screen.notchDisplayID
            guard let uuid = NotchHideRules.uuid(of: id) else { return nil }
            let name = screen.localizedName.isEmpty ? fallback : screen.localizedName
            return Screen(uuid: uuid, name: screen === NSScreen.withMenuBar ? "\(name) ★" : name,
                          builtIn: CGDisplayIsBuiltin(id) != 0)
        }
    }
}
