/*
    RooThub - centered busy / message overlay for a page or list.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Set `running` for a spinner, or `message` for an empty/error hint.
    Anchor it over the content area of a page.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    id: root
    property bool running: false
    property string message: ""
    property string hint: ""
    visible: running || message !== ""

    BusyIndicator {
        anchors.centerIn: parent
        running: root.running
        visible: root.running
        size: BusyIndicatorSize.Large
    }
    Column {
        anchors.centerIn: parent
        width: parent.width - 4 * Theme.horizontalPageMargin
        spacing: Theme.paddingMedium
        visible: !root.running && root.message !== ""
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.message
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }
        Label {
            width: parent.width
            visible: root.hint !== ""
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.hint
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
