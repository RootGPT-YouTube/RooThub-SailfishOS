/*
    RooThub - dashboard.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property var me: null
    property int notifCount: 0

    Component.onCompleted: refresh()

    function refresh() {
        GH.get("/user", Settings.token, function(err, data) {
            if (!err) {
                page.me = data
                Settings.saveSession(Settings.token, data.login, data.name || data.login, data.avatar_url)
            }
        })
        GH.get("/notifications?per_page=1", Settings.token, function(err, data, meta) {
            // Prefer the poll count header when present; else fall back.
            if (!err && data) page.notifCount = data.length
        })
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        PullDownMenu {
            MenuItem {
                text: qsTr("Sign out")
                onClicked: logoutRemorse.execute(qsTr("Signing out"), function() {
                    Settings.logout()
                    pageStack.replace(Qt.resolvedUrl("LoginPage.qml"))
                })
            }
            MenuItem { text: qsTr("Settings"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: qsTr("Search"); onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml")) }
            MenuItem { text: qsTr("Refresh"); onClicked: page.refresh() }
        }

        Column {
            id: col
            width: parent.width
            spacing: 0

            NeonHeader { text: "RooThub"; description: qsTr("Dashboard") }

            // Profile card
            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeLarge
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), { login: Settings.login })
                Row {
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium
                    Avatar {
                        anchors.verticalCenter: parent.verticalCenter
                        size: Theme.itemSizeMedium
                        source: Settings.avatarUrl
                        login: Settings.login
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Theme.itemSizeMedium - Theme.paddingMedium
                        Label {
                            text: page.me && page.me.name ? page.me.name : Settings.userName
                            color: Theme.primaryColor
                            truncationMode: TruncationMode.Fade
                            width: parent.width
                        }
                        Label {
                            text: "@" + Settings.login
                            color: Settings.accent
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Label {
                            visible: page.me
                            text: page.me ? (qsTr("%1 repos · %2 followers").arg(page.me.public_repos).arg(page.me.followers)) : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }

            NavItem {
                title: qsTr("My repositories")
                subtitle: qsTr("Repositories you own or contribute to")
                onClicked: pageStack.push(Qt.resolvedUrl("RepoListPage.qml"),
                    { mode: "mine", title: qsTr("My repositories") })
            }
            NavItem {
                title: qsTr("Starred")
                subtitle: qsTr("Repositories you starred")
                onClicked: pageStack.push(Qt.resolvedUrl("RepoListPage.qml"),
                    { mode: "starred", title: qsTr("Starred") })
            }
            NavItem {
                title: qsTr("Notifications")
                subtitle: page.notifCount > 0 ? qsTr("%1 unread").arg(page.notifCount) : qsTr("Inbox")
                highlight: page.notifCount > 0
                onClicked: pageStack.push(Qt.resolvedUrl("NotificationsPage.qml"))
            }
            NavItem {
                title: qsTr("My issues")
                subtitle: qsTr("Issues assigned to or created by you")
                onClicked: pageStack.push(Qt.resolvedUrl("IssueListPage.qml"),
                    { mode: "mine", title: qsTr("My issues") })
            }
            NavItem {
                title: qsTr("My pull requests")
                subtitle: qsTr("Pull requests you are involved in")
                onClicked: pageStack.push(Qt.resolvedUrl("IssueListPage.qml"),
                    { mode: "mine-pr", title: qsTr("My pull requests") })
            }
            NavItem {
                title: qsTr("Search GitHub")
                subtitle: qsTr("Repos, code, issues, users")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
            }
        }
        VerticalScrollDecorator {}
    }

    RemorsePopup { id: logoutRemorse }
}
