/*
    RooThub - repository overview.
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

    property string fullName: ""
    property var repo: null
    property string readme: ""
    property bool loadingReadme: false
    property bool starred: false
    property bool watching: false
    property bool busyAction: false
    property string actionError: ""
    readonly property bool canAdmin: repo && repo.permissions && repo.permissions.admin

    Component.onCompleted: load()

    function load() {
        GH.get("/repos/" + fullName, Settings.token, function(err, data) {
            if (!err) page.repo = data
        })
        page.loadingReadme = true
        GH.getRaw("/repos/" + fullName + "/readme", Settings.token, function(err, text) {
            page.loadingReadme = false
            page.readme = err ? "" : text
        })
        GH.get("/user/starred/" + fullName, Settings.token, function(err) {
            page.starred = !err
        })
        GH.get("/repos/" + fullName + "/subscription", Settings.token, function(err, data) {
            page.watching = !err && data && data.subscribed
        })
    }

    function toggleStar() {
        page.busyAction = true
        var m = page.starred ? GH.del : function(p, t, cb) { GH.put(p, t, {}, cb) }
        m("/user/starred/" + fullName, Settings.token, function(err) {
            page.busyAction = false
            if (!err)
                page.starred = !page.starred
        })
    }

    function toggleWatch() {
        page.busyAction = true
        if (page.watching) {
            GH.del("/repos/" + fullName + "/subscription", Settings.token, function(err) {
                page.busyAction = false
                if (!err) page.watching = false
            })
        } else {
            GH.put("/repos/" + fullName + "/subscription", Settings.token,
                   { subscribed: true, ignored: false }, function(err) {
                page.busyAction = false
                if (!err) page.watching = true
            })
        }
    }

    function setVisibility(makePrivate) {
        page.busyAction = true
        page.actionError = ""
        GH.patch("/repos/" + fullName, Settings.token, { "private": makePrivate }, function(err, data) {
            page.busyAction = false
            if (!err && data) page.repo = data
            else page.actionError = err ? (err.status === 403
                    ? qsTr("Change failed: you need admin rights and the 'repo' scope.")
                    : err.message) : ""
        })
    }
    function deleteRepo() {
        page.busyAction = true
        page.actionError = ""
        GH.del("/repos/" + fullName, Settings.token, function(err) {
            page.busyAction = false
            if (!err) pageStack.pop()
            else page.actionError = err.status === 403
                ? qsTr("Delete failed: the token needs the 'delete_repo' scope.")
                : err.message
        })
    }

    RemorsePopup { id: deleteRemorse }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        PullDownMenu {
            MenuItem { text: qsTr("Open on GitHub"); onClicked: Qt.openUrlExternally(page.repo ? page.repo.html_url : ("https://github.com/" + fullName)) }
            MenuItem { text: page.watching ? qsTr("Unwatch") : qsTr("Watch"); enabled: !page.busyAction; onClicked: page.toggleWatch() }
            MenuItem { text: page.starred ? qsTr("Unstar") : qsTr("Star"); enabled: !page.busyAction; onClicked: page.toggleStar() }
            MenuItem {
                visible: page.canAdmin
                text: page.repo && page.repo["private"] ? qsTr("Make public") : qsTr("Make private")
                enabled: !page.busyAction
                onClicked: page.setVisibility(!(page.repo && page.repo["private"]))
            }
            MenuItem { text: qsTr("Refresh"); onClicked: page.load() }
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            NeonHeader {
                text: page.fullName.split("/")[1]
                description: page.fullName.split("/")[0]
            }

            Label {
                visible: page.repo && page.repo.description
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: page.repo ? (page.repo.description || "") : ""
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            // Stat row
            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingLarge
                visible: page.repo
                StateBadge {
                    anchors.verticalCenter: parent.verticalCenter
                    text: page.repo && page.repo["private"] ? qsTr("Private") : qsTr("Public")
                    hue: page.repo && page.repo["private"] ? Settings.closedColor : Settings.openColor
                }
                Label { text: "★ " + (page.repo ? page.repo.stargazers_count : 0); color: page.starred ? Settings.accent : Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall; anchors.verticalCenter: parent.verticalCenter }
                Label { text: "⑂ " + (page.repo ? page.repo.forks_count : 0); color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall }
                Label { visible: page.repo && page.repo.language; text: page.repo ? page.repo.language : ""; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall }
            }

            // Primary actions (centered, equal-width pair)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium
                NeonButton {
                    width: (page.width - 2 * Theme.horizontalPageMargin - Theme.paddingMedium) / 2
                    text: page.starred ? qsTr("Unstar") : qsTr("Star")
                    accentColor: page.starred ? Settings.accentSoft : Settings.accent
                    enabled: !page.busyAction
                    onClicked: page.toggleStar()
                }
                NeonButton {
                    width: (page.width - 2 * Theme.horizontalPageMargin - Theme.paddingMedium) / 2
                    text: page.watching ? qsTr("Watching") : qsTr("Watch")
                    accentColor: page.watching ? Settings.accentSoft : Settings.accent
                    enabled: !page.busyAction
                    onClicked: page.toggleWatch()
                }
            }

            Label {
                visible: page.actionError !== ""
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: page.actionError
                color: Settings.closedColor
                font.pixelSize: Theme.fontSizeSmall
            }

            // Admin-only management, clearly grouped and set apart
            SectionHeader { visible: page.canAdmin; text: qsTr("Manage") }
            NeonButton {
                visible: page.canAdmin
                anchors.horizontalCenter: parent.horizontalCenter
                width: page.width - 2 * Theme.horizontalPageMargin
                text: page.repo && page.repo["private"] ? qsTr("Make public") : qsTr("Make private")
                enabled: !page.busyAction
                onClicked: page.setVisibility(!(page.repo && page.repo["private"]))
            }
            NeonButton {
                visible: page.canAdmin
                anchors.horizontalCenter: parent.horizontalCenter
                width: page.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Delete repository")
                accentColor: Settings.closedColor
                enabled: !page.busyAction
                onClicked: deleteRemorse.execute(qsTr("Deleting repository"),
                                                 function() { page.deleteRepo() }, 5000)
            }

            NavItem {
                title: qsTr("Code")
                subtitle: page.repo ? qsTr("Browse the %1 branch").arg(page.repo.default_branch) : qsTr("Browse files")
                onClicked: pageStack.push(Qt.resolvedUrl("CodePage.qml"),
                    { fullName: page.fullName, path: "", branch: page.repo ? page.repo.default_branch : "" })
            }
            NavItem {
                title: qsTr("Issues")
                subtitle: page.repo ? qsTr("%1 open").arg(page.repo.open_issues_count) : ""
                onClicked: pageStack.push(Qt.resolvedUrl("IssueListPage.qml"),
                    { mode: "repo", fullName: page.fullName, title: qsTr("Issues") })
            }
            NavItem {
                title: qsTr("Pull requests")
                onClicked: pageStack.push(Qt.resolvedUrl("IssueListPage.qml"),
                    { mode: "repo-pr", fullName: page.fullName, title: qsTr("Pull requests") })
            }
            NavItem {
                title: qsTr("Owner")
                subtitle: "@" + page.fullName.split("/")[0]
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), { login: page.fullName.split("/")[0] })
            }

            SectionHeader { text: qsTr("README") }
            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: page.loadingReadme
                visible: running
            }
            MarkdownText {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                visible: page.readme !== ""
                markdown: page.readme
            }
            Label {
                visible: !page.loadingReadme && page.readme === ""
                x: Theme.horizontalPageMargin
                text: qsTr("No README")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }
}
