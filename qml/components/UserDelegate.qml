/*
    RooThub - user / org list item.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    property var user
    contentHeight: Theme.itemSizeMedium

    Row {
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 2 * Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        Avatar {
            anchors.verticalCenter: parent.verticalCenter
            size: Theme.itemSizeSmall
            source: user ? user.avatar_url : ""
            login: user ? user.login : ""
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.itemSizeSmall - Theme.paddingMedium
            Label {
                text: user ? user.login : ""
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
                width: parent.width
            }
            Label {
                visible: user && user.type
                text: user && user.type === "Organization" ? qsTr("Organization") : qsTr("User")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }
    }
}
