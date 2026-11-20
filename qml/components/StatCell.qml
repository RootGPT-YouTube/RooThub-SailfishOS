/*
    RooThub - one cell of the repository statistics strip (number + label).
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."

BackgroundItem {
    id: cell
    property string value: ""
    property string label: ""
    property color valueColor: Theme.primaryColor
    height: col.height + 2 * Theme.paddingSmall

    Column {
        id: col
        anchors.centerIn: parent
        width: parent.width
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: cell.value
            color: cell.highlighted ? Theme.highlightColor : cell.valueColor
            font.pixelSize: Theme.fontSizeLarge
            font.family: Theme.fontFamilyHeading
        }
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: cell.label
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            truncationMode: TruncationMode.Fade
        }
    }
}
