/*
    RooThub - progress of the in-app download, docked at the page bottom.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Tap while downloading to cancel; tap after it finished to open the file.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../js/Html.js" as Html

BackgroundItem {
    id: bar
    property string donePath: ""
    property string doneName: ""
    property string errorText: ""
    readonly property bool shown: downloader.active || donePath !== "" || errorText !== ""

    width: parent ? parent.width : 0
    height: shown ? col.height + 2 * Theme.paddingMedium : 0
    visible: shown
    anchors.bottom: parent ? parent.bottom : undefined

    Connections {
        target: downloader
        onFinished: { bar.errorText = ""; bar.donePath = path; bar.doneName = fileName; hideTimer.restart() }
        onFailed: { bar.donePath = ""; bar.errorText = qsTr("Download failed: %1").arg(error); hideTimer.restart() }
        onStateChanged: if (downloader.active) { bar.donePath = ""; bar.errorText = "" }
    }
    Timer { id: hideTimer; interval: 8000; onTriggered: { bar.donePath = ""; bar.errorText = "" } }

    onClicked: {
        if (downloader.active) cancelRemorse.execute(bar, qsTr("Cancelling download"), function() { downloader.cancel() })
        else if (donePath !== "") Qt.openUrlExternally("file://" + donePath)
        else errorText = ""
    }
    RemorseItem { id: cancelRemorse }

    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.overlayBackgroundColor, 0.92)
    }
    Rectangle {
        visible: downloader.active
        anchors { left: parent.left; top: parent.top }
        height: Theme.paddingSmall / 2
        width: parent.width * Math.max(0, downloader.progress)
        color: Settings.accent
    }
    Column {
        id: col
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 2 * Theme.horizontalPageMargin
        Label {
            width: parent.width
            truncationMode: TruncationMode.Fade
            color: bar.errorText !== "" ? Settings.closedColor : Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: downloader.active ? qsTr("Downloading %1").arg(downloader.fileName)
                : (bar.errorText !== "" ? bar.errorText : qsTr("Saved to Downloads: %1").arg(bar.doneName))
        }
        Label {
            width: parent.width
            truncationMode: TruncationMode.Fade
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            text: downloader.active
                  ? (downloader.total > 0 ? Html.size(downloader.received) + " / " + Html.size(downloader.total)
                                          : Html.size(downloader.received))
                    + (downloader.queued > 0 ? "  ·  " + qsTr("%n more queued", "", downloader.queued) : "")
                    + "  ·  " + qsTr("tap to cancel")
                  : (bar.donePath !== "" ? qsTr("Tap to open") : "")
        }
    }
}
