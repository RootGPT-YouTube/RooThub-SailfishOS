/*
    RooThub - issue detail with comments.
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
    property var issue: null
    property bool loading: false
    property bool posting: false

    ListModel { id: comments }

    Component.onCompleted: load()

    function load() {
        loading = true
        GH.get("/repos/" + fullName + "/issues/" + number, Settings.token, function(err, data) {
            loading = false
            if (!err) page.issue = data
        })
        loadComments()
    }
    function loadComments() {
        comments.clear()
        GH.get("/repos/" + fullName + "/issues/" + number + "/comments?per_page=100", Settings.token,
            function(err, data) {
                if (!err) for (var i = 0; i < data.length; i++) comments.append({ comment: data[i] })
            })
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
    function setState(st) {
        GH.patch("/repos/" + fullName + "/issues/" + number, Settings.token,
            { state: st }, function(err, data) { if (!err) page.issue = data })
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        PullDownMenu {
            MenuItem { text: qsTr("Open on GitHub"); onClicked: Qt.openUrlExternally(page.issue ? page.issue.html_url : "") }
            MenuItem {
                visible: page.issue
                text: page.issue && page.issue.state === "open" ? qsTr("Close issue") : qsTr("Reopen issue")
                onClicked: page.setState(page.issue.state === "open" ? "closed" : "open")
            }
            MenuItem { text: qsTr("Refresh"); onClicked: page.load() }
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            NeonHeader {
                text: page.issue ? page.issue.title : ("#" + page.number)
                description: page.fullName + " #" + page.number
            }

            Row {
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                visible: page.issue
                StateBadge {
                    text: page.issue ? page.issue.state : ""
                    hue: page.issue && page.issue.state === "open" ? Settings.openColor : Settings.closedColor
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: page.issue
                    text: page.issue ? (page.issue.user.login + " · " + Format.relativeTime(page.issue.created_at)) : ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            // Body as the first "comment"
            CommentItem {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                visible: page.issue
                isBody: true
                data: page.issue
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

            // Add comment
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
        running: (page.loading && !page.issue) || page.posting
        size: BusyIndicatorSize.Large
    }
}
