/*
    RooThub - commit history of a branch.
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
    property string branch: ""
    property bool loading: false
    property string nextUrl: ""
    property string error: ""

    ListModel { id: items }

    Component.onCompleted: reload()

    function reload() {
        items.clear(); nextUrl = ""; error = ""
        load("/repos/" + fullName + "/commits?per_page=30" + (branch ? "&sha=" + encodeURIComponent(branch) : ""))
    }

    function load(path) {
        if (loading) return
        loading = true
        GH.get(path, Settings.token, function(err, data, meta) {
            loading = false
            if (err) { error = err.message; return }
            for (var i = 0; i < data.length; i++)
                items.append({ c: data[i] })
            nextUrl = meta.next || ""
        })
    }

    CircuitBackground {}
    SilicaListView {
        id: list
        anchors.fill: parent
        model: items

        header: NeonHeader { text: qsTr("Commits"); description: page.branch !== "" ? page.branch : page.fullName }

        PullDownMenu {
            MenuItem { text: qsTr("Refresh"); onClicked: page.reload() }
        }

        delegate: ListItem {
            id: li
            readonly property var c: model.c
            readonly property string message: (c.commit && c.commit.message) ? c.commit.message.split("\n")[0] : ""
            readonly property string who: c.author ? c.author.login
                                       : (c.commit && c.commit.author ? c.commit.author.name : "")
            contentHeight: row.height + 2 * Theme.paddingMedium

            Row {
                id: row
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                Avatar {
                    size: Theme.iconSizeMedium
                    source: li.c.author ? li.c.author.avatar_url : ""
                    login: li.who
                }
                Column {
                    width: parent.width - Theme.iconSizeMedium - Theme.paddingMedium
                    spacing: Theme.paddingSmall / 2
                    Label {
                        width: parent.width
                        text: li.message
                        color: li.highlighted ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        truncationMode: TruncationMode.Elide
                    }
                    Label {
                        width: parent.width
                        text: li.who + " · " + Format.relativeTime(li.c.commit && li.c.commit.author ? li.c.commit.author.date : "")
                              + " · " + ("" + li.c.sha).substring(0, 7)
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Fade
                    }
                }
            }
            onClicked: pageStack.push(Qt.resolvedUrl("HtmlPage.qml"), {
                kind: "commit", fullName: page.fullName,
                apiPath: "/repos/" + page.fullName + "/commits/" + li.c.sha })
        }

        footer: Item {
            width: list.width
            height: page.nextUrl !== "" ? Theme.itemSizeLarge : Theme.paddingLarge
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
