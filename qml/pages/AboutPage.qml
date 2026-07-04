/*
    RooThub - about.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("About") }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: Qt.resolvedUrl("../../images/roothub.svg")
                width: Theme.itemSizeExtraLarge * 1.6
                height: width
                sourceSize.width: width
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "RooThub"
                font.pixelSize: Theme.fontSizeExtraLarge
                font.family: Theme.fontFamilyHeading
                color: Settings.accent
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Version %1").arg(typeof appVersion !== "undefined" ? appVersion : "0.1.0")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("A native GitHub client for Sailfish OS. Browse repositories, manage issues and pull requests, follow notifications, search GitHub and view profiles.")
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader { text: qsTr("Author") }
            Label { x: Theme.horizontalPageMargin; text: "RootGPT"; color: Theme.primaryColor }

            SectionHeader { text: qsTr("License") }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: "GPL-3.0"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Project on GitHub")
                onClicked: Qt.openUrlExternally("https://github.com/RootGPT-YouTube/RooThub-SailfishOS")
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
}
