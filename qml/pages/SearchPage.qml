/*
    RooThub - search repositories, issues/PRs, users and code.
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

    // 0 repos, 1 issues, 2 users, 3 code
    property int kind: 0
    property string query: ""
    property bool loading: false
    property string error: ""

    ListModel { id: results }

    readonly property var endpoints: ["/search/repositories", "/search/issues", "/search/users", "/search/code"]

    function run() {
        if (query.trim() === "") return
        results.clear(); error = ""
        loading = true
        GH.get(endpoints[kind] + "?per_page=30&q=" + encodeURIComponent(query.trim()), Settings.token,
            function(err, data) {
                loading = false
                if (err) { error = err.message; return }
                var arr = data.items || []
                for (var i = 0; i < arr.length; i++) results.append({ item: arr[i] })
                if (arr.length === 0) error = qsTr("No results")
            })
    }

    CircuitBackground {}
    SilicaListView {
        id: list
        anchors.fill: parent
        model: results


        header: Column {
            width: list.width
            PageHeader { title: qsTr("Search") }
            SearchField {
                id: search
                width: parent.width
                placeholderText: qsTr("Search GitHub…")
                text: page.query
                EnterKey.iconSource: "image://theme/icon-m-search"
                EnterKey.onClicked: { page.query = text; page.run() }
                onTextChanged: page.query = text
            }
            ComboBox {
                width: parent.width
                label: qsTr("In")
                currentIndex: page.kind
                menu: ContextMenu {
                    MenuItem { text: qsTr("Repositories") }
                    MenuItem { text: qsTr("Issues & PRs") }
                    MenuItem { text: qsTr("Users") }
                    MenuItem { text: qsTr("Code") }
                }
                onCurrentIndexChanged: { page.kind = currentIndex; if (page.query.trim() !== "") page.run() }
            }
        }

        delegate: Loader {
            id: rowLoader
            width: list.width
            height: item ? item.height : Theme.itemSizeSmall
            property var rowData: model.item
            sourceComponent: page.kind === 0 ? repoComp
                           : page.kind === 2 ? userComp
                           : page.kind === 3 ? codeComp
                           : issueComp
            onLoaded: item.payload = rowData
        }

        ViewPlaceholder {
            enabled: results.count === 0 && !page.loading
            text: page.error !== "" ? page.error : qsTr("Type to search")
        }
        VerticalScrollDecorator {}
    }

    Component {
        id: repoComp
        RepoDelegate {
            property var payload
            repo: payload
            onClicked: pageStack.push(Qt.resolvedUrl("RepoPage.qml"), { fullName: payload.full_name })
        }
    }
    Component {
        id: issueComp
        IssueDelegate {
            property var payload
            issue: payload
            onClicked: {
                var rn = payload.repository_url ? payload.repository_url.replace("https://api.github.com/repos/", "") : ""
                pageStack.push(Qt.resolvedUrl(payload.pull_request ? "PullPage.qml" : "IssuePage.qml"),
                    { fullName: rn, number: payload.number })
            }
        }
    }
    Component {
        id: userComp
        UserDelegate {
            property var payload
            user: payload
            onClicked: pageStack.push(Qt.resolvedUrl("UserPage.qml"), { login: payload.login })
        }
    }
    Component {
        id: codeComp
        ListItem {
            property var payload
            contentHeight: Theme.itemSizeSmall
            Column {
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                Label { text: payload ? payload.name : ""; truncationMode: TruncationMode.Fade; width: parent.width; color: highlighted ? Theme.highlightColor : Theme.primaryColor }
                Label { text: payload ? ((payload.repository ? payload.repository.full_name : "") + " · " + payload.path) : ""; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall; truncationMode: TruncationMode.Fade; width: parent.width }
            }
            onClicked: pageStack.push(Qt.resolvedUrl("FilePage.qml"),
                { fullName: payload.repository ? payload.repository.full_name : "", path: payload.path, branch: "", fileName: payload.name })
        }
    }

    BusyIndicator { anchors.centerIn: parent; running: page.loading; size: BusyIndicatorSize.Large }
}
