/*
    RooThub - notification list item.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../js/Format.js" as Format

ListItem {
    id: delegate
    property var note
    readonly property bool unread: note && note.unread
    contentHeight: col.height + 2 * Theme.paddingMedium

    Rectangle {
        visible: delegate.unread
        width: Theme.paddingSmall / 2
        height: parent.height
        color: Settings.accent
    }
    Column {
        id: col
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 2 * Theme.horizontalPageMargin
        spacing: Theme.paddingSmall / 2

        Label {
            width: parent.width
            text: note && note.subject ? note.subject.title : ""
            color: delegate.unread ? Theme.primaryColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.Wrap
            maximumLineCount: 2
            truncationMode: TruncationMode.Elide
        }
        Label {
            width: parent.width
            text: {
                if (!note) return ""
                var repo = note.repository ? note.repository.full_name : ""
                var type = note.subject ? note.subject.type : ""
                return repo + " · " + type + " · " + Format.relativeTime(note.updated_at)
            }
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            truncationMode: TruncationMode.Fade
        }
    }
}
