// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// The order in which the closed island prefers its activities.
struct NotchActivityPriorityCard: View {
    @ObservedObject private var l10n = L10n.shared
    @AppStorage(DefaultsKey.notchActivityOrder) private var stored = ""

    private var text: NotchHideRulesStrings { FeatureStrings.notchHideRules(l10n.language) }
    private var order: [NotchCompactActivity] {
        _ = stored // read so SwiftUI redraws on change
        return NotchSupport.activityOrder()
    }

    var body: some View {
        SettingsCard(title: text.priority) {
            let activities = order
            ForEach(Array(activities.enumerated()), id: \.element) { index, activity in
                HStack(spacing: 10) {
                    Text("\(index + 1).")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(width: 22, alignment: .trailing)
                    Image(systemName: activity.symbol)
                        .frame(width: 20)
                    Text(activity.title(l10n.language))
                    Spacer()
                    Button { move(index, by: -1) } label: { Image(systemName: "chevron.up") }
                        .buttonStyle(.borderless)
                        .disabled(index == 0)
                        .accessibilityLabel(text.moveUp)
                    Button { move(index, by: 1) } label: { Image(systemName: "chevron.down") }
                        .buttonStyle(.borderless)
                        .disabled(index == activities.count - 1)
                        .accessibilityLabel(text.moveDown)
                }
            }
            HStack {
                Text(text.priorityCaption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if !stored.isEmpty {
                    Button(text.resetOrder) { stored = "" }
                        .controlSize(.small)
                }
            }
        }
    }

    private func move(_ index: Int, by offset: Int) {
        var activities = order
        let target = index + offset
        guard activities.indices.contains(target) else { return }
        activities.swapAt(index, target)
        stored = activities.map(\.rawValue).joined(separator: ",")
    }
}
