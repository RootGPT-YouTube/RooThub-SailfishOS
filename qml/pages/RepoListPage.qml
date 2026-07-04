/*
    RooThub - a paginated list of repositories.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Modes: "mine" | "starred" | "user" (needs `login`) | "search" (needs `query`).
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property string mode: "mine"
    property string title: qsTr("Repositories")
    property string login: ""
    property string query: ""

    property bool loading: false
    property string nextUrl: ""
    property string error: ""

    ListModel { id: repos }

    Component.onCompleted: reload()

    function firstPath() {
        if (mode === "starred") return "/user/starred?per_page=30"
        if (mode === "user")    return "/users/" + login + "/repos?per_page=30&sort=updated"
        if (mode === "search")  return "/search/repositories?per_page=30&q=" + encodeURIComponent(query)
        return "/user/repos?per_page=30&sort=updated&affiliation=owner,collaborator,organization_member"
    }

    function reload() {
        repos.clear()
        nextUrl = ""
        error = ""
        load(firstPath())
    }

    function load(path) {
        if (loading) return
        loading = true
        GH.get(path, Settings.token, function(err, data, meta) {
            loading = false
            if (err) { error = err.message; return }
            var items = (mode === "search") ? data.items : data
            for (var i = 0; i < items.length; i++)
                repos.append({ repo: items[i] })
            nextUrl = meta.next || ""
        })
    }

    CircuitBackground {}
    SilicaListView {
        id: list
        anchors.fill: parent
        model: repos
        cacheBuffer: 2000


        header: NeonHeader { text: page.title; description: qsTr("%1 loaded").arg(repos.count) }

        PullDownMenu {
            MenuItem { text: qsTr("Refresh"); onClicked: page.reload() }
        }

        delegate: RepoDelegate {
            repo: model.repo
            onClicked: pageStack.push(Qt.resolvedUrl("RepoPage.qml"),
                { fullName: model.repo.full_name })
        }

        footer: Item {
            width: list.width
            height: page.nextUrl !== "" ? Theme.itemSizeLarge : Theme.paddingLarge
            BusyIndicator {
                anchors.centerIn: parent
                running: page.loading && page.nextUrl !== ""
                visible: running
            }
            NeonButton {
                anchors.centerIn: parent
                visible: page.nextUrl !== "" && !page.loading
                text: qsTr("Load more")
                onClicked: page.load(page.nextUrl)
            }
        }

        onAtYEndChanged: if (atYEnd && nextUrl !== "" && !loading) load(nextUrl)

        ViewPlaceholder {
            enabled: repos.count === 0 && !page.loading
            text: page.error !== "" ? qsTr("Error") : qsTr("Nothing here")
            hintText: page.error
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.loading && repos.count === 0
        size: BusyIndicatorSize.Large
    }
}
