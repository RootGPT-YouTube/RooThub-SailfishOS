/*
    RooThub - notifications inbox.
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

    property bool loading: false
    property bool showAll: false
    property string nextUrl: ""
    property string error: ""

    ListModel { id: notes }

    Component.onCompleted: reload()

    function reload() {
        notes.clear(); nextUrl = ""; error = ""
        load("/notifications?per_page=30&all=" + (showAll ? "true" : "false"))
    }
    function load(path) {
        if (loading) return
        loading = true
        GH.get(path, Settings.token, function(err, data, meta) {
            loading = false
            if (err) { error = err.message; return }
            for (var i = 0; i < data.length; i++) notes.append({ note: data[i] })
            nextUrl = meta.next || ""
        })
    }
    function markThreadRead(id) {
        GH.patch("/notifications/threads/" + id, Settings.token, {}, function(err) {})
    }
    function markAllRead() {
        GH.put("/notifications", Settings.token, { read: true }, function(err) { if (!err) page.reload() })
    }
    function openNote(note) {
        markThreadRead(note.id)
        var subj = note.subject
        var repo = note.repository ? note.repository.full_name : ""
        if (!subj || !subj.url) { pageStack.push(Qt.resolvedUrl("RepoPage.qml"), { fullName: repo }); return }
        var m = subj.url.match(/\/(issues|pulls)\/(\d+)$/)
        if (m) {
            pageStack.push(Qt.resolvedUrl(m[1] === "pulls" ? "PullPage.qml" : "IssuePage.qml"),
                { fullName: repo, number: parseInt(m[2]) })
        } else {
            pageStack.push(Qt.resolvedUrl("RepoPage.qml"), { fullName: repo })
        }
    }

    CircuitBackground {}
    SilicaListView {
        id: list
        anchors.fill: parent
        model: notes


        header: NeonHeader { text: qsTr("Notifications"); description: page.showAll ? qsTr("All") : qsTr("Unread") }

        PullDownMenu {
            MenuItem { text: qsTr("Mark all as read"); onClicked: page.markAllRead() }
            MenuItem { text: page.showAll ? qsTr("Show unread only") : qsTr("Show all"); onClicked: { page.showAll = !page.showAll; page.reload() } }
            MenuItem { text: qsTr("Refresh"); onClicked: page.reload() }
        }

        delegate: NotificationDelegate {
            note: model.note
            onClicked: page.openNote(model.note)
            menu: ContextMenu {
                MenuItem { text: qsTr("Mark as read"); onClicked: { page.markThreadRead(model.note.id); notes.remove(index) } }
            }
        }

        footer: Item {
            width: list.width; height: page.nextUrl !== "" ? Theme.itemSizeLarge : Theme.paddingLarge
            NeonButton { anchors.centerIn: parent; visible: page.nextUrl !== "" && !page.loading; text: qsTr("Load more"); onClicked: page.load(page.nextUrl) }
        }
        onAtYEndChanged: if (atYEnd && nextUrl !== "" && !loading) load(nextUrl)

        ViewPlaceholder {
            enabled: notes.count === 0 && !page.loading
            text: page.error !== "" ? qsTr("Error") : qsTr("All caught up")
            hintText: page.error
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator { anchors.centerIn: parent; running: page.loading && notes.count === 0; size: BusyIndicatorSize.Large }
}
