/*
    RooThub - issue / pull-request list item.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Bound against a GitHub issue JSON object provided as `issue`.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../js/Format.js" as Format

ListItem {
    id: delegate
    property var issue
    readonly property bool isPull: issue && issue.pull_request !== undefined
    readonly property bool isOpen: issue && issue.state === "open"
    readonly property bool isMerged: isPull && issue && issue.pull_request && issue.pull_request.merged_at
    contentHeight: col.height + 2 * Theme.paddingMedium

    Column {
        id: col
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 2 * Theme.horizontalPageMargin
        spacing: Theme.paddingSmall / 2

        Row {
            width: parent.width
            spacing: Theme.paddingSmall
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: (delegate.isPull ? "⑂" : "◉")
                color: delegate.isMerged ? Settings.mergedColor
                     : (delegate.isOpen ? Settings.openColor : Settings.closedColor)
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                width: parent.width - Theme.paddingLarge
                text: issue ? issue.title : ""
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                maximumLineCount: 2
                truncationMode: TruncationMode.Elide
            }
        }
        Label {
            width: parent.width
            text: {
                if (!issue) return ""
                var who = issue.user ? issue.user.login : "?"
                return "#" + issue.number + " · " + who + " · " + Format.relativeTime(issue.updated_at)
                     + (issue.comments ? "  💬 " + issue.comments : "")
            }
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            truncationMode: TruncationMode.Fade
        }
        Flow {
            width: parent.width
            spacing: Theme.paddingSmall / 2
            visible: issue && issue.labels && issue.labels.length > 0
            Repeater {
                model: issue && issue.labels ? issue.labels : []
                StateBadge {
                    text: modelData.name
                    hue: "#" + (modelData.color ? modelData.color : "888888")
                }
            }
        }
    }
}
