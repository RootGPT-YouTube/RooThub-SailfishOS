/*
    RooThub - a single issue/PR comment (or the issue body).
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../js/Format.js" as Format

Column {
    id: comment
    property var data
    property bool isBody: false
    width: parent ? parent.width : 0
    spacing: Theme.paddingSmall

    Row {
        width: parent.width
        spacing: Theme.paddingMedium
        Avatar {
            size: Theme.itemSizeSmall
            source: comment.data && comment.data.user ? comment.data.user.avatar_url : ""
            login: comment.data && comment.data.user ? comment.data.user.login : ""
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.itemSizeSmall - Theme.paddingMedium
            Label {
                text: comment.data && comment.data.user ? comment.data.user.login : ""
                color: comment.isBody ? Settings.accent : Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                text: comment.data ? Format.relativeTime(comment.data.created_at) : ""
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }
    }
    MarkdownText {
        width: parent.width
        markdown: comment.data ? (comment.data.body || "*(no description)*") : ""
    }
    NeonSeparator {
        width: parent.width
    }
}
