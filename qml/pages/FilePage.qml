/*
    RooThub - view a single file's contents.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Text files are shown inline (monospace). Images are rendered. Anything
    else offers to open on GitHub.
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
    property string path: ""
    property string branch: ""
    property string fileName: ""
    property string downloadUrl: ""

    property string content: ""
    property bool loading: false
    property string error: ""

    readonly property bool isImage: /\.(png|jpe?g|gif|svg|bmp|webp)$/i.test(fileName)

    Component.onCompleted: if (!isImage) load()

    function load() {
        loading = true
        error = ""
        var p = "/repos/" + fullName + "/contents/" + path + (branch ? ("?ref=" + branch) : "")
        GH.getRaw(p, Settings.token, function(err, text) {
            loading = false
            if (err) { error = err.message; return }
            page.content = text
        })
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height
        contentWidth: Math.max(width, code.implicitWidth + 2 * Theme.horizontalPageMargin)


        PullDownMenu {
            MenuItem {
                text: qsTr("Edit")
                visible: !page.isImage
                onClicked: pageStack.push(Qt.resolvedUrl("EditFilePage.qml"),
                    { fullName: page.fullName, path: page.path, branch: page.branch, fileName: page.fileName })
            }
            MenuItem { text: qsTr("Open on GitHub")
                onClicked: Qt.openUrlExternally("https://github.com/" + fullName + "/blob/" + branch + "/" + path) }
            MenuItem { text: qsTr("Copy contents"); visible: page.content !== ""; onClicked: Clipboard.text = page.content }
        }

        Column {
            id: col
            width: page.width
            spacing: Theme.paddingMedium

            NeonHeader { text: page.fileName; description: page.path }

            Image {
                visible: page.isImage
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                fillMode: Image.PreserveAspectFit
                source: page.isImage ? page.downloadUrl : ""
                sourceSize.width: width
            }

            Label {
                id: code
                visible: !page.isImage && page.content !== ""
                x: Theme.horizontalPageMargin
                text: page.content
                color: Theme.primaryColor
                font.family: "monospace"
                font.pixelSize: Theme.fontSizeExtraSmall
                textFormat: Text.PlainText
                wrapMode: Text.NoWrap
            }
            Label {
                visible: page.error !== ""
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: page.error
                color: Settings.closedColor
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
        HorizontalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.loading
        size: BusyIndicatorSize.Large
    }
}
