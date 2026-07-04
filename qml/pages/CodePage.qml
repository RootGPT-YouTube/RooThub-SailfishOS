/*
    RooThub - repository file browser (contents API).
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
    property string path: ""
    property string branch: ""
    property bool loading: false
    property string error: ""

    ListModel { id: entries }

    Component.onCompleted: load()

    function load() {
        loading = true
        error = ""
        entries.clear()
        var p = "/repos/" + fullName + "/contents/" + path + (branch ? ("?ref=" + branch) : "")
        GH.get(p, Settings.token, function(err, data) {
            loading = false
            if (err) { error = err.message; return }
            var arr = (data instanceof Array) ? data : [data]
            // dirs first, then files, each alphabetical
            arr.sort(function(a, b) {
                if (a.type !== b.type) return a.type === "dir" ? -1 : 1
                return a.name < b.name ? -1 : 1
            })
            for (var i = 0; i < arr.length; i++)
                entries.append({ entry: arr[i] })
        })
    }

    CircuitBackground {}
    SilicaListView {
        anchors.fill: parent
        model: entries


        header: NeonHeader {
            text: page.path === "" ? page.fullName.split("/")[1] : page.path.split("/").pop()
            description: page.path === "" ? qsTr("Files") : page.path
        }

        PullDownMenu {
            MenuItem { text: qsTr("Refresh"); onClicked: page.load() }
        }

        delegate: ListItem {
            contentHeight: Theme.itemSizeSmall
            Row {
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: model.entry.type === "dir"
                        ? "image://theme/icon-m-folder" : "image://theme/icon-m-document"
                    width: Theme.iconSizeSmall; height: width
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.iconSizeSmall - sizeLbl.width - 2 * Theme.paddingMedium
                    text: model.entry.name
                    truncationMode: TruncationMode.Fade
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: sizeLbl
                    anchors.verticalCenter: parent.verticalCenter
                    visible: model.entry.type === "file"
                    text: Format.compact(model.entry.size) + "B"
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
            onClicked: {
                if (model.entry.type === "dir")
                    pageStack.push(Qt.resolvedUrl("CodePage.qml"),
                        { fullName: page.fullName, path: model.entry.path, branch: page.branch })
                else
                    pageStack.push(Qt.resolvedUrl("FilePage.qml"),
                        { fullName: page.fullName, path: model.entry.path, branch: page.branch,
                          fileName: model.entry.name, downloadUrl: model.entry.download_url })
            }
        }

        ViewPlaceholder {
            enabled: entries.count === 0 && !page.loading
            text: page.error !== "" ? qsTr("Error") : qsTr("Empty")
            hintText: page.error
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.loading && entries.count === 0
        size: BusyIndicatorSize.Large
    }
}
