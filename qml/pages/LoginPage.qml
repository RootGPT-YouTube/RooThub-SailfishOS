/*
    RooThub - sign in.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Two ways to authenticate:
      1. GitHub OAuth Device Flow (recommended) - needs the client_id of a
         GitHub OAuth App with Device Flow enabled. No client secret is
         stored on the device.
      2. A Personal Access Token pasted directly.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool busy: false
    property string error: ""

    function signInWithToken(tok) {
        if (!tok) return
        page.busy = true
        page.error = ""
        GH.get("/user", tok, function(err, data) {
            page.busy = false
            if (err) {
                page.error = err.status === 401 ? qsTr("Invalid token.") : err.message
                return
            }
            Settings.saveSession(tok, data.login, data.name || data.login, data.avatar_url)
            pageStack.replace(Qt.resolvedUrl("HomePage.qml"))
        })
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height


        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: qsTr("Sign in to GitHub") }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: Qt.resolvedUrl("../../images/roothub.svg")
                width: Theme.itemSizeExtraLarge * 1.6
                height: width
                sourceSize.width: width
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("RooThub — a native GitHub client for Sailfish OS")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            // ── Device Flow ──────────────────────────────────────────
            SectionHeader { text: qsTr("Sign in with GitHub (Device Flow)") }

            TextField {
                id: clientIdField
                width: parent.width
                text: Settings.clientId
                label: qsTr("OAuth App client ID")
                placeholderText: qsTr("client_id of your GitHub OAuth App")
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: focus = false
            }
            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Continue with Device Flow")
                enabled: clientIdField.text.trim().length > 0 && !page.busy
                onClicked: {
                    Settings.setClientId(clientIdField.text.trim())
                    pageStack.push(Qt.resolvedUrl("DeviceFlowPage.qml"),
                                   { clientId: clientIdField.text.trim() })
                }
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: qsTr("Create a GitHub OAuth App (Settings → Developer settings → OAuth Apps), enable \"Device Flow\", and paste its client ID above.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            // ── Personal Access Token ────────────────────────────────
            SectionHeader { text: qsTr("Or use a Personal Access Token") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                linkColor: Settings.accent
                onLinkActivated: Qt.openUrlExternally(link)
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("How to get a token:") +
                      "<br/>1. " + qsTr("Open") + ' <a href="https://github.com/settings/tokens/new">github.com/settings/tokens/new</a> ' + qsTr("(sign in if asked).") +
                      "<br/>2. " + qsTr("Give it a name and an expiration.") +
                      "<br/>3. " + qsTr("Tick the scopes:") + " <b>repo</b>, <b>read:org</b>, <b>notifications</b>, <b>user</b>, <b>gist</b> " +
                      qsTr("(add <b>delete_repo</b> if you want to delete repositories).") +
                      "<br/>4. " + qsTr("Tap <b>Generate token</b> and copy it (starts with ghp_…).") +
                      "<br/>5. " + qsTr("Paste it below and sign in.")
            }
            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Open token page on GitHub")
                onClicked: Qt.openUrlExternally("https://github.com/settings/tokens/new")
            }

            TextField {
                id: tokenField
                width: parent.width
                label: qsTr("Personal Access Token")
                placeholderText: qsTr("ghp_… or github_pat_…")
                echoMode: TextInput.PasswordEchoOnEdit
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: page.signInWithToken(text.trim())
            }
            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Sign in with token")
                enabled: tokenField.text.trim().length > 0 && !page.busy
                onClicked: page.signInWithToken(tokenField.text.trim())
            }

            Label {
                visible: page.error !== ""
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: page.error
                color: Settings.closedColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.busy
        size: BusyIndicatorSize.Large
    }
}
