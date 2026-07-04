/*
    RooThub - a titled navigation row for the dashboard.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."

BackgroundItem {
    id: item
    property string title: ""
    property string subtitle: ""
    property bool highlight: false
    width: parent ? parent.width : 0
    height: Theme.itemSizeMedium

    Column {
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 2 * Theme.horizontalPageMargin
        Label {
            text: item.title
            color: item.highlighted ? Theme.highlightColor
                 : (item.highlight ? Settings.accent : Theme.primaryColor)
            width: parent.width
            truncationMode: TruncationMode.Fade
        }
        Label {
            visible: item.subtitle !== ""
            text: item.subtitle
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            width: parent.width
            truncationMode: TruncationMode.Fade
        }
    }
    Image {
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin; verticalCenter: parent.verticalCenter }
        source: "image://theme/icon-m-right"
        opacity: 0.5
    }
}
