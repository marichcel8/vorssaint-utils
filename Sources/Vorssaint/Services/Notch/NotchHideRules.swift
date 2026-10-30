// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import CoreGraphics

/// When the island steps aside: in full screen only or at any time, on the
/// displays the person leaves on, and only for the apps they name or for all
/// but those. The master switch stays `notchHideInFullscreen`.
struct NotchHideRules: Equatable {
    enum Trigger: String, CaseIterable {
        case fullscreen, always
    }

    enum AppMode: String, CaseIterable {
        /// Every focused app counts.
        case any
        /// Only while one of the listed apps is focused.
        case only
        /// While any app but the listed ones is focused.
        case except
    }

    var trigger: Trigger = .fullscreen
    var appMode: AppMode = .any
    var apps: [String] = []
    /// Display UUIDs where the island never hides. A display seen for the
    /// first time hides, as it did before displays could be told apart.
    var keptDisplays: Set<String> = []

    var always: Bool { trigger == .always }

    static func current(_ defaults: UserDefaults = .standard) -> NotchHideRules {
        NotchHideRules(
            trigger: Trigger(rawValue: defaults.string(forKey: DefaultsKey.notchHideTrigger) ?? "") ?? .fullscreen,
            appMode: AppMode(rawValue: defaults.string(forKey: DefaultsKey.notchHideAppMode) ?? "") ?? .any,
            apps: Defaults.sanitizedBundleIdentifierList(defaults.stringArray(forKey: DefaultsKey.notchHideApps) ?? []),
            keptDisplays: Set(defaults.stringArray(forKey: DefaultsKey.notchHideKeptDisplays) ?? []))
    }

    /// Whether hiding may happen on `displayID` with the focused app as it is now.
    func applies(to displayID: CGDirectDisplayID) -> Bool {
        guard hidesOn(display: Self.uuid(of: displayID)) else { return false }
        guard appMode != .any else { return true }
        let app = Self.focusedApp()
        return Self.appAllows(mode: appMode, listed: WindowLayoutIgnoredApps.matches(
            bundleID: app?.bundleIdentifier, executablePath: app?.executableURL?.path, apps: apps))
    }

    func hidesOn(display uuid: String?) -> Bool {
        guard let uuid else { return true }
        return !keptDisplays.contains(uuid)
    }

    static func appAllows(mode: AppMode, listed: Bool) -> Bool {
        switch mode {
        case .any: return true
        case .only: return listed
        case .except: return !listed
        }
    }

    /// Survives reconnecting and restarting, unlike the display ID.
    static func uuid(of displayID: CGDirectDisplayID) -> String? {
        guard let uuid = CGDisplayCreateUUIDFromDisplayID(displayID)?.takeRetainedValue() else { return nil }
        return CFUUIDCreateString(nil, uuid) as String?
    }

    /// Opening the island or its Settings makes Vorssaint frontmost, which
    /// must not count as leaving the game; the last other app stands in.
    private static var lastForeignApp: NSRunningApplication?

    static func focusedApp() -> NSRunningApplication? {
        let front = NSWorkspace.shared.frontmostApplication
        if let front, front.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            lastForeignApp = front
            return front
        }
        return lastForeignApp?.isTerminated == false ? lastForeignApp : nil
    }
}
