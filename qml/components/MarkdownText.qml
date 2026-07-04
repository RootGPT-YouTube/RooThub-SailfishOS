/*
    RooThub - render light Markdown as styled text with tappable links.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../js/Format.js" as Format

Label {
    id: md
    property string markdown: ""
    width: parent ? parent.width : implicitWidth
    wrapMode: Text.Wrap
    textFormat: Text.StyledText
    text: Format.markdownToHtml(markdown)
    color: Theme.primaryColor
    linkColor: Settings.accent
    font.pixelSize: Theme.fontSizeSmall
    onLinkActivated: Qt.openUrlExternally(link)
}
