/*
    RooThub - repository list item.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Bound against a GitHub repo JSON object provided as `repo`.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../js/Format.js" as Format

ListItem {
    id: delegate
    property var repo
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
                width: parent.width - langRow.width - Theme.paddingSmall
                truncationMode: TruncationMode.Fade
                text: repo ? (repo.full_name ? repo.full_name : repo.name) : ""
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
            Row {
                id: langRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingSmall / 2
                visible: repo && repo.language
                Rectangle { width: Theme.fontSizeExtraSmall/1.6; height: width; radius: width/2; anchors.verticalCenter: parent.verticalCenter; color: Settings.accent }
                Label { text: repo && repo.language ? repo.language : ""; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall }
            }
        }
        Label {
            width: parent.width
            visible: text !== ""
            text: repo && repo.description ? repo.description : ""
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            wrapMode: Text.Wrap
            maximumLineCount: 2
            truncationMode: TruncationMode.Elide
        }
        Row {
            spacing: Theme.paddingLarge
            Label {
                text: "★ " + Format.compact(repo ? repo.stargazers_count : 0)
                color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall
            }
            Label {
                text: "⑂ " + Format.compact(repo ? repo.forks_count : 0)
                color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall
            }
            Label {
                visible: repo && repo.open_issues_count !== undefined
                text: "◉ " + Format.compact(repo ? repo.open_issues_count : 0)
                color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall
            }
            Label {
                visible: repo && repo["private"]
                text: qsTr("private")
                color: Settings.accentDim; font.pixelSize: Theme.fontSizeExtraSmall
            }
        }
    }
}
