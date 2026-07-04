/*
    RooThub - NEON BLUE separator that fades at the edges.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Stacked Silica Separators for a light cyan bloom; falls back to a plain
    Silica Separator with the plain theme. No Glow → cheap in list delegates.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."

Item {
    id: neonSeparator
    width: parent ? parent.width : 0
    height: Math.round(Theme.paddingSmall / 2)

    readonly property bool neon: Settings.neonTheme

    Separator {
        visible: neonSeparator.neon
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -1 }
        width: parent.width
        color: Theme.rgba(Settings.accent, 0.22)
        horizontalAlignment: Qt.AlignHCenter
    }
    Separator {
        visible: neonSeparator.neon
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: 1 }
        width: parent.width
        color: Theme.rgba(Settings.accent, 0.22)
        horizontalAlignment: Qt.AlignHCenter
    }
    Separator {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        width: parent.width
        color: neonSeparator.neon ? Settings.accentSoft : Theme.primaryColor
        horizontalAlignment: Qt.AlignHCenter
    }
}
