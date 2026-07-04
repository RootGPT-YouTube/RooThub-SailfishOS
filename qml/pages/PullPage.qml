/*
    RooThub - pull request detail with comments and merge.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/Format.js" as Format
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property string fullName: ""
    property int number: 0
    property var pr: null
    property bool loading: false
    property bool posting: false

    readonly property string prState: pr ? (pr.merged ? "merged" : pr.state) : ""

    ListModel { id: comments }

    Component.onCompleted: load()

    function load() {
        loading = true
        GH.get("/repos/" + fullName + "/pulls/" + number, Settings.token, function(err, data) {
            loading = false
            if (!err) page.pr = data
        })
        comments.clear()
        GH.get("/repos/" + fullName + "/issues/" + number + "/comments?per_page=100", Settings.token,
            function(err, data) { if (!err) for (var i = 0; i < data.length; i++) comments.append({ comment: data[i] }) })
    }
    function addComment(text) {
        if (!text) return
        page.posting = true
        GH.post("/repos/" + fullName + "/issues/" + number + "/comments", Settings.token,
            { body: text }, function(err, data) {
                page.posting = false
                if (!err) { commentField.text = ""; comments.append({ comment: data }); commentField.focus = false }
            })
    }
    function merge() {
        page.posting = true
        GH.put("/repos/" + fullName + "/pulls/" + number + "/merge", Settings.token, {}, function(err, data) {
            page.posting = false
            if (!err) page.load()
        })
    }
    function setState(st) {
        GH.patch("/repos/" + fullName + "/pulls/" + number, Settings.token,
            { state: st }, function(err, data) { if (!err) page.pr = data })
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        PullDownMenu {
            MenuItem { text: qsTr("Open on GitHub"); onClicked: Qt.openUrlExternally(page.pr ? page.pr.html_url : "") }
            MenuItem {
                visible: page.pr && page.pr.state === "open" && !page.pr.merged
                text: qsTr("Merge")
                onClicked: page.merge()
            }
            MenuItem {
                visible: page.pr && !page.pr.merged
                text: page.pr && page.pr.state === "open" ? qsTr("Close") : qsTr("Reopen")
                onClicked: page.setState(page.pr.state === "open" ? "closed" : "open")
            }
            MenuItem { text: qsTr("Refresh"); onClicked: page.load() }
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            NeonHeader {
                text: page.pr ? page.pr.title : ("#" + page.number)
                description: page.fullName + " #" + page.number
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                visible: page.pr
                StateBadge {
                    text: page.prState
                    hue: page.prState === "merged" ? Settings.mergedColor
                         : (page.prState === "open" ? Settings.openColor : Settings.closedColor)
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: page.pr
                    text: page.pr ? ("+" + page.pr.additions + " −" + page.pr.deletions + " · " + page.pr.changed_files + qsTr(" files")) : ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
            Label {
                x: Theme.horizontalPageMargin
                visible: page.pr
                text: page.pr ? (page.pr.head.label + " → " + page.pr.base.label) : ""
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width - 2*Theme.horizontalPageMargin
                truncationMode: TruncationMode.Fade
            }

            CommentItem {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                visible: page.pr
                isBody: true
                data: page.pr
            }

            SectionHeader { text: qsTr("Comments (%1)").arg(comments.count) }
            Repeater {
                model: comments
                CommentItem {
                    x: Theme.horizontalPageMargin
                    width: page.width - 2 * Theme.horizontalPageMargin
                    data: model.comment
                }
            }

            TextArea {
                id: commentField
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                label: qsTr("Add a comment")
                placeholderText: qsTr("Leave a comment (Markdown supported)")
            }
            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Comment")
                enabled: commentField.text.trim().length > 0 && !page.posting
                onClicked: page.addComment(commentField.text.trim())
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: (page.loading && !page.pr) || page.posting
        size: BusyIndicatorSize.Large
    }
}
