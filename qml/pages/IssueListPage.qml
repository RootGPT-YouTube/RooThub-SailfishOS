/*
    RooThub - a paginated list of issues or pull requests.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Modes: "repo" (issues) | "repo-pr" (pulls) | "mine" | "mine-pr".
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property string mode: "repo"
    property string fullName: ""
    property string title: qsTr("Issues")
    property string state: "open"
    readonly property bool pullMode: mode === "repo-pr" || mode === "mine-pr"

    property bool loading: false
    property string nextUrl: ""
    property string error: ""

    ListModel { id: items }

    Component.onCompleted: reload()

    function firstPath() {
        var st = state
        if (mode === "repo")    return "/repos/" + fullName + "/issues?state=" + st + "&per_page=30&sort=updated"
        if (mode === "repo-pr") return "/repos/" + fullName + "/pulls?state=" + st + "&per_page=30&sort=updated"
        if (mode === "mine-pr") return "/search/issues?per_page=30&q=" + encodeURIComponent("is:pr state:" + st + " involves:" + Settings.login)
        return "/search/issues?per_page=30&q=" + encodeURIComponent("is:issue state:" + st + " involves:" + Settings.login)
    }

    function repoOf(issue) {
        if (fullName) return fullName
        if (issue.repository_url)
            return issue.repository_url.replace("https://api.github.com/repos/", "")
        return ""
    }

    function reload() {
        items.clear(); nextUrl = ""; error = ""
        load(firstPath())
    }

    function load(path) {
        if (loading) return
        loading = true
        GH.get(path, Settings.token, function(err, data, meta) {
            loading = false
            if (err) { error = err.message; return }
            var arr = data.items ? data.items : data
            for (var i = 0; i < arr.length; i++) {
                // In "repo" (issues) mode the API also returns PRs; hide them.
                if (mode === "repo" && arr[i].pull_request) continue
                items.append({ issue: arr[i] })
            }
            nextUrl = meta.next || ""
        })
    }

    CircuitBackground {}
    SilicaListView {
        id: list
        anchors.fill: parent
        model: items


        header: Column {
            width: list.width
            NeonHeader { text: page.title; description: page.fullName }
            ComboBox {
                width: parent.width
                label: qsTr("State")
                currentIndex: page.state === "open" ? 0 : (page.state === "closed" ? 1 : 2)
                menu: ContextMenu {
                    MenuItem { text: qsTr("Open") }
                    MenuItem { text: qsTr("Closed") }
                    MenuItem { text: qsTr("All") }
                }
                onCurrentIndexChanged: {
                    var s = ["open", "closed", "all"][currentIndex]
                    if (s !== page.state) { page.state = s; page.reload() }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                visible: page.mode === "repo"
                text: qsTr("New issue")
                onClicked: pageStack.push(Qt.resolvedUrl("NewIssuePage.qml"), { fullName: page.fullName })
            }
            MenuItem { text: qsTr("Refresh"); onClicked: page.reload() }
        }

        delegate: IssueDelegate {
            issue: model.issue
            onClicked: {
                var rn = page.repoOf(model.issue)
                var isPr = page.pullMode || model.issue.pull_request
                pageStack.push(Qt.resolvedUrl(isPr ? "PullPage.qml" : "IssuePage.qml"),
                    { fullName: rn, number: model.issue.number })
            }
        }

        footer: Item {
            width: list.width
            height: page.nextUrl !== "" ? Theme.itemSizeLarge : Theme.paddingLarge
            NeonButton {
                anchors.centerIn: parent
                visible: page.nextUrl !== "" && !page.loading
                text: qsTr("Load more")
                onClicked: page.load(page.nextUrl)
            }
            BusyIndicator { anchors.centerIn: parent; running: page.loading && page.nextUrl !== ""; visible: running }
        }
        onAtYEndChanged: if (atYEnd && nextUrl !== "" && !loading) load(nextUrl)

        ViewPlaceholder {
            enabled: items.count === 0 && !page.loading
            text: page.error !== "" ? qsTr("Error") : qsTr("Nothing here")
            hintText: page.error
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.loading && items.count === 0
        size: BusyIndicatorSize.Large
    }
}
