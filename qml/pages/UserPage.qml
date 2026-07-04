/*
    RooThub - user / organization profile.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/Format.js" as Format
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property string login: ""
    property var user: null
    property bool following: false
    property bool isSelf: login === Settings.login
    property bool busyAction: false

    Component.onCompleted: load()

    function load() {
        GH.get("/users/" + login, Settings.token, function(err, data) { if (!err) page.user = data })
        if (!isSelf)
            GH.get("/user/following/" + login, Settings.token, function(err) { page.following = !err })
    }
    function toggleFollow() {
        page.busyAction = true
        var fn = following ? GH.del : function(p, t, cb) { GH.put(p, t, {}, cb) }
        fn("/user/following/" + login, Settings.token, function(err) {
            page.busyAction = false
            if (!err) page.following = !page.following
        })
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        PullDownMenu {
            MenuItem { text: qsTr("Open on GitHub"); onClicked: Qt.openUrlExternally(page.user ? page.user.html_url : ("https://github.com/" + login)) }
            MenuItem { visible: page.isSelf; text: qsTr("Sign out"); onClicked: { Settings.logout(); pageStack.replace(Qt.resolvedUrl("LoginPage.qml")) } }
            MenuItem { text: qsTr("Refresh"); onClicked: page.load() }
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            NeonHeader { text: page.login; description: page.user && page.user.type === "Organization" ? qsTr("Organization") : qsTr("Profile") }

            Avatar {
                anchors.horizontalCenter: parent.horizontalCenter
                size: Theme.itemSizeExtraLarge * 1.4
                source: page.user ? page.user.avatar_url : Settings.avatarUrl
                login: page.login
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: page.user && page.user.name
                text: page.user ? (page.user.name || "") : ""
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: page.user && page.user.bio
                text: page.user ? (page.user.bio || "") : ""
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge
                visible: page.user
                Label { text: (page.user ? page.user.public_repos : 0) + qsTr(" repos"); color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall }
                Label { text: (page.user ? page.user.followers : 0) + qsTr(" followers"); color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall }
                Label { text: (page.user ? page.user.following : 0) + qsTr(" following"); color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall }
            }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingSmall / 2
                Label {
                    visible: page.user && page.user.company
                    width: parent.width; truncationMode: TruncationMode.Fade
                    text: page.user ? ("🏢  " + (page.user.company || "")) : ""
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                }
                Label {
                    visible: page.user && page.user.location
                    width: parent.width; truncationMode: TruncationMode.Fade
                    text: page.user ? ("📍  " + (page.user.location || "")) : ""
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                }
                Label {
                    visible: page.user && page.user.blog
                    width: parent.width; truncationMode: TruncationMode.Fade
                    textFormat: Text.StyledText
                    linkColor: Settings.accent
                    text: page.user && page.user.blog ? ('🔗  <a href="' + page.user.blog + '">' + page.user.blog + '</a>') : ""
                    onLinkActivated: Qt.openUrlExternally(link)
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                }
            }

            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !page.isSelf && page.user
                text: page.following ? qsTr("Following") : qsTr("Follow")
                enabled: !page.busyAction
                onClicked: page.toggleFollow()
            }

            NavItem {
                title: qsTr("Repositories")
                subtitle: page.user ? qsTr("%1 public").arg(page.user.public_repos) : ""
                onClicked: pageStack.push(Qt.resolvedUrl("RepoListPage.qml"),
                    { mode: "user", login: page.login, title: page.login + "/repos" })
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
}
