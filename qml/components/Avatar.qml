/*
    RooThub - circular avatar with a neon ring and graceful fallback.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import ".."

Item {
    id: avatar
    property alias source: img.source
    property string login: ""
    property int size: Theme.itemSizeMedium
    width: size
    height: size

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Theme.rgba(Settings.accent, 0.12)
        border.color: Theme.rgba(Settings.accent, 0.45)
        border.width: 1
    }
    Label {
        anchors.centerIn: parent
        visible: img.status !== Image.Ready
        text: avatar.login.length > 0 ? avatar.login.charAt(0).toUpperCase() : "?"
        color: Settings.accent
        font.pixelSize: avatar.size / 2
    }
    Image {
        id: img
        anchors.fill: parent
        anchors.margins: 1
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: false
        sourceSize.width: size
        sourceSize.height: size
    }
    Rectangle {
        id: mask
        anchors.fill: img
        radius: width / 2
        visible: false
    }
    OpacityMask {
        anchors.fill: img
        source: img
        maskSource: mask
        visible: img.status === Image.Ready
    }
}
