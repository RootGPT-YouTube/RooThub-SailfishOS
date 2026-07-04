/*
    RooThub - application cover.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."

CoverBackground {
    id: cover

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../images/roothub.svg")
        fillMode: Image.PreserveAspectCrop
        opacity: 0.16
        sourceSize.width: cover.width
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 2 * Theme.paddingLarge
        spacing: Theme.paddingMedium

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: Qt.resolvedUrl("../../images/roothub.svg")
            width: cover.width / 2.4
            height: width
            sourceSize.width: width
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "RooThub"
            font.pixelSize: Theme.fontSizeLarge
            font.family: Theme.fontFamilyHeading
            color: Settings.accent
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            truncationMode: TruncationMode.Fade
            text: Settings.authenticated ? ("@" + Settings.login) : qsTr("Not signed in")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
        }
    }
}
