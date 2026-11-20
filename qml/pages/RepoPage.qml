/*
    RooThub - repository overview.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH
import "../js/Format.js" as Format

Page {
    id: page
    allowedOrientations: Orientation.All

    property string fullName: ""
    property var repo: null
    // Counts shown next to each section (-1 = unknown / still loading)
    property int releasesCount: -1
    property var latestRelease: null
    property int commitsCount: -1
    property int branchesCount: -1
    property int tagsCount: -1
    property int contributorsCount: -1
    property int pullsCount: -1
    property string loadError: ""
    property bool starred: false
    property bool watching: false
    property bool busyAction: false
    property string actionError: ""
    readonly property bool canAdmin: repo && repo.permissions && repo.permissions.admin

    Component.onCompleted: load()

    // The README sits on an attached page, one swipe to the left, rendered
    // by the web engine like on github.com.
    onStatusChanged: attachReadme()
    function attachReadme() {
        // Pushing another page drops the attached one: re-attach on return.
        if (!page.repo || page.status !== PageStatus.Active || pageStack.nextPage(page))
            return
        pageStack.pushAttached(Qt.resolvedUrl("HtmlPage.qml"), readmeProps())
    }
    function readmeProps() {
        return { kind: "markdown", fullName: page.fullName, ref: page.branch,
                 apiPath: "/repos/" + page.fullName + "/readme",
                 title: qsTr("README"), description: page.fullName,
                 webUrl: "https://github.com/" + page.fullName + "#readme" }
    }

    readonly property string owner: fullName.split("/")[0]
    readonly property string branch: repo ? repo.default_branch : ""

    function load() {
        var base = "/repos/" + fullName
        page.loadError = ""
        GH.get(base, Settings.token, function(err, data) {
            if (err) { page.loadError = err.message; return }
            page.repo = data
            page.attachReadme()
            GH.count(base + "/commits?sha=" + encodeURIComponent(data.default_branch), Settings.token,
                     function(n) { page.commitsCount = n })
        })
        GH.count(base + "/releases", Settings.token, function(n) { page.releasesCount = n })
        GH.get(base + "/releases/latest", Settings.token, function(err, data) {
            page.latestRelease = err ? null : data
        })
        GH.count(base + "/branches", Settings.token, function(n) { page.branchesCount = n })
        GH.count(base + "/tags", Settings.token, function(n) { page.tagsCount = n })
        GH.count(base + "/contributors", Settings.token, function(n) { page.contributorsCount = n })
        GH.count(base + "/pulls?state=open", Settings.token, function(n) { page.pullsCount = n })
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
            MenuItem { text: qsTr("Copy clone URL"); visible: page.repo !== null; onClicked: Clipboard.text = page.repo.clone_url }
            MenuItem { text: page.watching ? qsTr("Unwatch") : qsTr("Watch"); enabled: !page.busyAction; onClicked: page.toggleWatch() }
            MenuItem { text: page.starred ? qsTr("Unstar") : qsTr("Star"); enabled: !page.busyAction; onClicked: page.toggleStar() }
            MenuItem { text: qsTr("Refresh"); onClicked: page.load() }
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            NeonHeader {
                text: page.fullName.split("/")[1]
                description: page.owner
            }

            // Owner + "forked from"
            BackgroundItem {
                width: parent.width
                height: ownerRow.height + Theme.paddingSmall
                onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), { login: page.owner })
                Row {
                    id: ownerRow
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium
                    Avatar {
                        anchors.verticalCenter: parent.verticalCenter
                        size: Theme.iconSizeMedium
                        source: page.repo && page.repo.owner ? page.repo.owner.avatar_url : ""
                        login: page.owner
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Theme.iconSizeMedium - Theme.paddingMedium
                        Label {
                            width: parent.width
                            text: page.owner + " / <b>" + page.fullName.split("/")[1] + "</b>"
                            textFormat: Text.StyledText
                            color: Theme.highlightColor
                            truncationMode: TruncationMode.Fade
                        }
                        Label {
                            visible: page.repo && page.repo.fork && page.repo.parent
                            width: parent.width
                            text: visible ? qsTr("forked from %1").arg(page.repo.parent.full_name) : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            truncationMode: TruncationMode.Fade
                        }
                    }
                }
            }

            Flow {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                visible: page.repo !== null
                StateBadge {
                    text: page.repo && page.repo["private"] ? qsTr("Private") : qsTr("Public")
                    hue: page.repo && page.repo["private"] ? Settings.closedColor : Settings.openColor
                }
                StateBadge { visible: page.repo && page.repo.archived; text: qsTr("Archived"); hue: "#d29922" }
                StateBadge { visible: page.repo && page.repo.is_template; text: qsTr("Template"); hue: Settings.mergedColor }
                StateBadge {
                    visible: page.repo && page.repo.fork && page.repo.parent
                    text: qsTr("Fork"); hue: Settings.accent
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("RepoPage.qml"), { fullName: page.repo.parent.full_name })
                    }
                }
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

            Label {
                visible: page.repo && page.repo.homepage
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: page.repo && page.repo.homepage
                      ? "🔗 <a href=\"" + page.repo.homepage + "\">" + page.repo.homepage.replace(/^https?:\/\//, "") + "</a>" : ""
                textFormat: Text.StyledText
                linkColor: Settings.accent
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                onLinkActivated: Qt.openUrlExternally(link)
            }

            // Topics
            Flow {
                visible: page.repo && page.repo.topics && page.repo.topics.length > 0
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                Repeater {
                    model: page.repo && page.repo.topics ? page.repo.topics : []
                    StateBadge { text: modelData; hue: Settings.accentSoft }
                }
            }

            // Statistics strip
            Row {
                visible: page.repo !== null
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                StatCell {
                    width: parent.width / 4
                    value: Format.compact(page.repo ? page.repo.stargazers_count : 0)
                    label: qsTr("stars")
                    valueColor: page.starred ? Settings.accent : Theme.primaryColor
                    onClicked: page.toggleStar()
                }
                StatCell {
                    width: parent.width / 4
                    value: Format.compact(page.repo ? page.repo.forks_count : 0)
                    label: qsTr("forks")
                    enabled: false
                }
                StatCell {
                    width: parent.width / 4
                    value: Format.compact(page.repo ? page.repo.subscribers_count : 0)
                    label: qsTr("watching")
                    valueColor: page.watching ? Settings.accent : Theme.primaryColor
                    onClicked: page.toggleWatch()
                }
                StatCell {
                    width: parent.width / 4
                    value: Format.compact(page.repo ? page.repo.open_issues_count : 0)
                    label: qsTr("open issues")
                    onClicked: pageStack.push(Qt.resolvedUrl("IssueListPage.qml"),
                        { mode: "repo", fullName: page.fullName, title: qsTr("Issues") })
                }
            }

            // Language · license · last push
            Flow {
                visible: page.repo !== null
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingLarge
                Row {
                    visible: page.repo && page.repo.language
                    spacing: Theme.paddingSmall
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Theme.fontSizeExtraSmall * 0.7; height: width; radius: width / 2
                        color: Format.langColor(page.repo ? page.repo.language : "")
                    }
                    Label { text: page.repo && page.repo.language ? page.repo.language : ""; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall }
                }
                Label {
                    visible: page.repo && page.repo.license && page.repo.license.spdx_id && page.repo.license.spdx_id !== "NOASSERTION"
                    text: "⚖ " + (visible ? page.repo.license.spdx_id : "")
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    visible: page.repo && page.repo.pushed_at
                    text: qsTr("Updated %1").arg(page.repo ? Format.relativeTime(page.repo.pushed_at) : "")
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall
                }
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

            Column {
                width: parent.width
                NavItem {
                    title: qsTr("README")
                    subtitle: qsTr("Swipe left to read it")
                    highlight: true
                    onClicked: pageStack.nextPage(page) ? pageStack.navigateForward()
                               : pageStack.push(Qt.resolvedUrl("HtmlPage.qml"), page.readmeProps())
                }
                NavItem {
                    title: qsTr("Code")
                    subtitle: page.repo ? qsTr("Browse the %1 branch").arg(page.branch) : qsTr("Browse files")
                    onClicked: pageStack.push(Qt.resolvedUrl("CodePage.qml"),
                        { fullName: page.fullName, path: "", branch: page.branch })
                }
                NavItem {
                    title: qsTr("Releases") + (page.releasesCount > 0 ? "  ·  " + page.releasesCount : "")
                    subtitle: page.latestRelease
                              ? qsTr("Latest: %1, %2").arg(page.latestRelease.name || page.latestRelease.tag_name)
                                                      .arg(Format.relativeTime(page.latestRelease.published_at))
                              : (page.releasesCount === 0 ? qsTr("No releases published") : "")
                    onClicked: pageStack.push(Qt.resolvedUrl("ReleasesPage.qml"), { fullName: page.fullName })
                }
                NavItem {
                    title: qsTr("Issues")
                    // open_issues_count includes pull requests
                    subtitle: page.repo ? qsTr("%1 open").arg(page.pullsCount >= 0
                              ? Math.max(0, page.repo.open_issues_count - page.pullsCount)
                              : page.repo.open_issues_count) : ""
                    onClicked: pageStack.push(Qt.resolvedUrl("IssueListPage.qml"),
                        { mode: "repo", fullName: page.fullName, title: qsTr("Issues") })
                }
                NavItem {
                    title: qsTr("Pull requests")
                    subtitle: page.pullsCount >= 0 ? qsTr("%1 open").arg(page.pullsCount) : ""
                    onClicked: pageStack.push(Qt.resolvedUrl("IssueListPage.qml"),
                        { mode: "repo-pr", fullName: page.fullName, title: qsTr("Pull requests") })
                }
                NavItem {
                    title: qsTr("Commits") + (page.commitsCount > 0 ? "  ·  " + page.commitsCount : "")
                    subtitle: page.repo ? qsTr("History of %1").arg(page.branch) : ""
                    onClicked: pageStack.push(Qt.resolvedUrl("CommitsPage.qml"),
                        { fullName: page.fullName, branch: page.branch })
                }
                NavItem {
                    title: qsTr("Branches") + (page.branchesCount > 0 ? "  ·  " + page.branchesCount : "")
                    onClicked: pageStack.push(Qt.resolvedUrl("RefsPage.qml"),
                        { fullName: page.fullName, mode: "branches", defaultBranch: page.branch })
                }
                NavItem {
                    title: qsTr("Tags") + (page.tagsCount > 0 ? "  ·  " + page.tagsCount : "")
                    onClicked: pageStack.push(Qt.resolvedUrl("RefsPage.qml"),
                        { fullName: page.fullName, mode: "tags" })
                }
                NavItem {
                    title: qsTr("Contributors") + (page.contributorsCount > 0 ? "  ·  " + page.contributorsCount : "")
                    onClicked: pageStack.push(Qt.resolvedUrl("RefsPage.qml"),
                        { fullName: page.fullName, mode: "contributors" })
                }
            }

            // Admin-only management, at the bottom and set apart
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
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.repo === null && page.loadError === ""
        size: BusyIndicatorSize.Large
    }
    Label {
        visible: page.repo === null && page.loadError !== ""
        anchors.centerIn: parent
        width: parent.width - 2 * Theme.horizontalPageMargin
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: page.loadError
        color: Settings.closedColor
    }
}
