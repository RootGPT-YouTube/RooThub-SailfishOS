/*
    RooThub - a repository's releases.
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
    property string latestId: ""
    property bool loading: false
    property string nextUrl: ""
    property string error: ""

    ListModel { id: items }

    Component.onCompleted: reload()

    function reload() {
        items.clear(); nextUrl = ""; error = ""
        GH.get("/repos/" + fullName + "/releases/latest", Settings.token, function(err, data) {
            page.latestId = (!err && data) ? ("" + data.id) : ""
        })
        load("/repos/" + fullName + "/releases?per_page=30")
    }

    function load(path) {
        if (loading) return
        loading = true
        GH.get(path, Settings.token, function(err, data, meta) {
            loading = false
            if (err) { error = err.message; return }
            for (var i = 0; i < data.length; i++)
                items.append({ rel: data[i] })
            nextUrl = meta.next || ""
        })
    }

    CircuitBackground {}
    SilicaListView {
        id: list
        anchors.fill: parent
        model: items

        header: NeonHeader { text: qsTr("Releases"); description: page.fullName }

        PullDownMenu {
            MenuItem { text: qsTr("Open on GitHub"); onClicked: Qt.openUrlExternally("https://github.com/" + page.fullName + "/releases") }
            MenuItem { text: qsTr("Refresh"); onClicked: page.reload() }
        }

        delegate: ListItem {
            id: li
            readonly property var rel: model.rel
            readonly property bool latest: ("" + rel.id) === page.latestId
            contentHeight: col.height + 2 * Theme.paddingMedium

            Column {
                id: col
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingSmall / 2

                Label {
                    width: parent.width
                    text: li.rel.name || li.rel.tag_name
                    color: li.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Elide
                }
                Flow {
                    width: parent.width
                    spacing: Theme.paddingSmall
                    StateBadge { visible: li.latest; text: qsTr("Latest"); hue: Settings.openColor }
                    StateBadge { visible: li.rel.prerelease; text: qsTr("Pre-release"); hue: "#d29922" }
                    StateBadge { visible: li.rel.draft; text: qsTr("Draft"); hue: Theme.secondaryColor }
                    Label {
                        text: "🏷 " + li.rel.tag_name + " · " + Format.relativeTime(li.rel.published_at || li.rel.created_at)
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                Label {
                    visible: li.rel.assets && li.rel.assets.length > 0
                    text: qsTr("%n asset(s)", "", li.rel.assets ? li.rel.assets.length : 0)
                          + (li.rel.author ? " · @" + li.rel.author.login : "")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
            onClicked: pageStack.push(Qt.resolvedUrl("HtmlPage.qml"), {
                kind: "release", fullName: page.fullName, latestId: page.latestId,
                title: li.rel.name || li.rel.tag_name,
                apiPath: "/repos/" + page.fullName + "/releases/" + li.rel.id })
        }

        footer: Item {
            width: list.width
            height: page.nextUrl !== "" ? Theme.itemSizeLarge : Theme.paddingLarge
            BusyIndicator { anchors.centerIn: parent; running: page.loading && page.nextUrl !== ""; visible: running }
        }
        onAtYEndChanged: if (atYEnd && nextUrl !== "" && !loading) load(nextUrl)

        ViewPlaceholder {
            enabled: items.count === 0 && !page.loading
            text: page.error !== "" ? qsTr("Error") : qsTr("No releases")
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
