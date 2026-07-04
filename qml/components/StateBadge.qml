/*
    RooThub - small coloured pill badge (open / closed / merged / labels).
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle {
    id: badge
    property string text: ""
    property color hue: "#3fb950"
    property string icon: ""     // optional source

    implicitWidth: row.width + Theme.paddingMedium
    implicitHeight: label.height + Theme.paddingSmall
    radius: height / 2
    color: Theme.rgba(badge.hue, 0.18)
    border.color: Theme.rgba(badge.hue, 0.55)
    border.width: 1

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.paddingSmall / 2
        Image {
            anchors.verticalCenter: parent.verticalCenter
            visible: badge.icon !== ""
            source: badge.icon
            width: visible ? Theme.iconSizeExtraSmall : 0
            height: width
        }
        Label {
            id: label
            text: badge.text
            color: badge.hue
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }
}
