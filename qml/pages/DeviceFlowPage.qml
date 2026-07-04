/*
    RooThub - GitHub OAuth Device Flow.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Requests a user code, shows it to the user (who enters it at
    github.com/login/device), then polls until the token is granted.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property string clientId: ""
    property string scope: "repo read:org notifications user gist"

    property string userCode: ""
    property string verificationUri: "https://github.com/login/device"
    property string deviceCode: ""
    property int interval: 5
    property string status: qsTr("Requesting a device code…")
    property bool waiting: true
    property var pollTimer: null

    Component.onCompleted: start()

    function start() {
        waiting = true
        status = qsTr("Requesting a device code…")
        GH.requestDeviceCode(clientId, scope, function(err, data) {
            if (err || !data || !data.device_code) {
                waiting = false
                status = qsTr("Could not start Device Flow. Check the client ID and that Device Flow is enabled for the OAuth App.")
                return
            }
            userCode = data.user_code
            verificationUri = data.verification_uri || verificationUri
            deviceCode = data.device_code
            interval = data.interval || 5
            status = qsTr("Enter this code on GitHub:")
            poll.interval = interval * 1000
            poll.start()
        })
    }

    function finish(tok) {
        poll.stop()
        GH.get("/user", tok, function(err, data) {
            if (err) {
                waiting = false
                status = qsTr("Authorized, but fetching the profile failed: ") + err.message
                return
            }
            Settings.saveSession(tok, data.login, data.name || data.login, data.avatar_url)
            pageStack.replace(Qt.resolvedUrl("HomePage.qml"))
        })
    }

    Timer {
        id: poll
        repeat: true
        onTriggered: {
            GH.pollAccessToken(page.clientId, page.deviceCode, function(err, data) {
                if (!data) return
                if (data.access_token) {
                    page.finish(data.access_token)
                } else if (data.error === "slow_down") {
                    poll.interval = ((data.interval || (page.interval + 5)) * 1000)
                } else if (data.error === "authorization_pending") {
                    // keep waiting
                } else if (data.error) {
                    poll.stop()
                    page.waiting = false
                    page.status = qsTr("Device Flow failed: ") + data.error
                }
            })
        }
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: qsTr("Device Flow") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: page.status
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                visible: page.userCode !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.userCode
                font.pixelSize: Theme.fontSizeHuge
                font.family: Theme.fontFamilyHeading
                font.letterSpacing: 4
                color: Settings.accent
            }

            NeonButton {
                visible: page.userCode !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Copy code")
                onClicked: Clipboard.text = page.userCode
            }
            NeonButton {
                visible: page.userCode !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Open github.com/login/device")
                onClicked: Qt.openUrlExternally(page.verificationUri)
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: page.waiting && page.userCode !== ""
                visible: running
                size: BusyIndicatorSize.Medium
            }
            Label {
                visible: page.userCode !== ""
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Waiting for you to authorize on GitHub…")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
            NeonButton {
                visible: !page.waiting
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Retry")
                onClicked: page.start()
            }
        }
    }
}
