/*
    RooThub - settings.
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

            NeonHeader { text: qsTr("Settings") }

            SectionHeader { text: qsTr("Account") }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: Settings.authenticated ? qsTr("Signed in as @%1").arg(Settings.login) : qsTr("Not signed in")
                color: Theme.primaryColor
            }
            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Sign out")
                visible: Settings.authenticated
                onClicked: {
                    Settings.logout()
                    pageStack.replace(Qt.resolvedUrl("LoginPage.qml"))
                }
            }

            SectionHeader { text: qsTr("Appearance") }
            TextSwitch {
                text: qsTr("Neon theme")
                description: qsTr("Family blue glow and circuit background")
                checked: Settings.neonTheme
                onClicked: Settings.setNeon(checked)
            }

            SectionHeader { text: qsTr("OAuth") }
            TextField {
                id: clientField
                width: parent.width
                label: qsTr("OAuth App client ID")
                text: Settings.clientId
                placeholderText: qsTr("For Device Flow sign-in")
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: { Settings.setClientId(text.trim()); focus = false }
            }
            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Save client ID")
                onClicked: Settings.setClientId(clientField.text.trim())
            }

            SectionHeader { text: qsTr("About") }
            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("About RooThub")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
}
