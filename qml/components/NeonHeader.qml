/*
    RooThub - page header in the family NEON BLUE style.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Exposes `text` (title) and `description` (subtitle). With the plain
    Silica theme it degrades to a native-looking header (no glow).
*/
import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import ".."

PageHeader {
    id: neonHeader
    property string text: ""
    property string description: ""
    readonly property bool neon: Settings.neonTheme

    title: ""
    height: description !== "" ? Theme.itemSizeLarge : Theme.itemSizeMedium

    Label {
        id: halo
        visible: neonHeader.neon
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin; bottom: parent.verticalCenter }
        width: Math.min(implicitWidth, neonHeader.width - 2 * Theme.horizontalPageMargin)
        horizontalAlignment: Text.AlignRight
        text: core.text
        textFormat: Text.StyledText
        font.pixelSize: Theme.fontSizeLarge
        font.family: Theme.fontFamilyHeading
        font.italic: true
        truncationMode: TruncationMode.Elide
        maximumLineCount: 1
        color: Settings.accent
        layer.enabled: true
        layer.effect: Glow {
            color: Settings.accent
            radius: 16
            samples: 33
            spread: 0.28
            transparentBorder: true
        }
    }
    Label {
        id: core
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin; bottom: parent.verticalCenter }
        width: Math.min(implicitWidth, neonHeader.width - 2 * Theme.horizontalPageMargin)
        horizontalAlignment: Text.AlignRight
        text: neonHeader.text
        textFormat: Text.StyledText
        font.pixelSize: Theme.fontSizeLarge
        font.family: neonHeader.neon ? Theme.fontFamilyHeading : Theme.fontFamily
        font.italic: neonHeader.neon
        truncationMode: TruncationMode.Elide
        maximumLineCount: 1
        color: neonHeader.neon ? "#eafcff" : Theme.highlightColor
    }
    Label {
        visible: neonHeader.description !== ""
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin; top: parent.verticalCenter; topMargin: Theme.paddingSmall / 2 }
        horizontalAlignment: Text.AlignRight
        text: neonHeader.description
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor
    }
}
