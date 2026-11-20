/*
    RooThub - branches, tags or contributors of a repository.
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
    property string mode: "branches"        // branches | tags | contributors
    property string defaultBranch: ""
    property bool loading: false
    property string nextUrl: ""
    property string error: ""

    ListModel { id: items }

    Component.onCompleted: reload()

    function reload() {
        items.clear(); nextUrl = ""; error = ""
        load("/repos/" + fullName + "/" + mode + "?per_page=100")
    }

    function load(path) {
        if (loading) return
        loading = true
        GH.get(path, Settings.token, function(err, data, meta) {
            loading = false
            if (err) { error = err.message; return }
            var arr = data instanceof Array ? data : []
            if (mode === "branches" && page.defaultBranch !== "")
                arr.sort(function(a, b) {   // default branch first
                    return (b.name === page.defaultBranch) - (a.name === page.defaultBranch)
                })
            for (var i = 0; i < arr.length; i++)
                items.append({ it: arr[i] })
            nextUrl = meta.next || ""
        })
    }

    CircuitBackground {}
    SilicaListView {
        id: list
        anchors.fill: parent
        model: items

        header: NeonHeader {
            text: page.mode === "tags" ? qsTr("Tags")
                : (page.mode === "contributors" ? qsTr("Contributors") : qsTr("Branches"))
            description: page.fullName
        }

        PullDownMenu {
            MenuItem { text: qsTr("Refresh"); onClicked: page.reload() }
        }

        delegate: ListItem {
            id: li
            readonly property var it: model.it
            contentHeight: Theme.itemSizeMedium

            Row {
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Avatar {
                    visible: page.mode === "contributors"
                    anchors.verticalCenter: parent.verticalCenter
                    size: Theme.iconSizeMedium
                    source: visible ? li.it.avatar_url : ""
                    login: li.it.login || ""
                }
                Image {
                    visible: page.mode !== "contributors"
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.iconSizeSmall; height: width
                    source: page.mode === "tags" ? "image://theme/icon-s-pin" : "image://theme/icon-s-repost"
                    opacity: 0.7
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.iconSizeMedium - 2 * Theme.paddingMedium - badges.width
                    Label {
                        width: parent.width
                        text: page.mode === "contributors" ? li.it.login : li.it.name
                        color: li.highlighted ? Theme.highlightColor : Theme.primaryColor
                        truncationMode: TruncationMode.Fade
                    }
                    Label {
                        width: parent.width
                        text: page.mode === "contributors"
                              ? qsTr("%n contribution(s)", "", li.it.contributions)
                              : (li.it.commit ? ("" + li.it.commit.sha).substring(0, 7) : "")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                Row {
                    id: badges
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall
                    StateBadge {
                        visible: page.mode === "branches" && li.it.name === page.defaultBranch
                        text: qsTr("default"); hue: Settings.accent
                    }
                    StateBadge {
                        visible: page.mode === "branches" && li.it["protected"] === true
                        text: qsTr("protected"); hue: "#d29922"
                    }
                }
            }

            menu: page.mode === "contributors" ? null : refMenu
            Component {
                id: refMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Commits")
                        onClicked: pageStack.push(Qt.resolvedUrl("CommitsPage.qml"),
                                                  { fullName: page.fullName, branch: li.it.name })
                    }
                    MenuItem {
                        visible: page.mode === "tags"
                        text: qsTr("Release")
                        onClicked: pageStack.push(Qt.resolvedUrl("HtmlPage.qml"), {
                            kind: "release", fullName: page.fullName, title: li.it.name,
                            apiPath: "/repos/" + page.fullName + "/releases/tags/" + encodeURIComponent(li.it.name) })
                    }
                }
            }

            onClicked: {
                if (page.mode === "contributors")
                    pageStack.push(Qt.resolvedUrl("UserPage.qml"), { login: li.it.login })
                else
                    pageStack.push(Qt.resolvedUrl("CodePage.qml"),
                                   { fullName: page.fullName, path: "", branch: li.it.name })
            }
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
