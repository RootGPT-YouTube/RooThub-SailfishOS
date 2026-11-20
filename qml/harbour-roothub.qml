/*
    RooThub - a native GitHub client for Sailfish OS
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import "."
import "pages"

ApplicationWindow {
    id: app
    allowedOrientations: defaultAllowedOrientations
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property Component homeComponent:  Component { HomePage {} }
    property Component loginComponent: Component { LoginPage {} }

    // Land on the dashboard if a session exists, otherwise on login.
    initialPage: Settings.authenticated ? homeComponent : loginComponent

    // System notification when an in-app download ends (see Downloader).
    Notification {
        id: downloadNote
        appName: "RooThub"
        appIcon: "harbour-roothub"
        isTransient: false
    }
    Connections {
        target: downloader
        onFinished: {
            downloadNote.summary = qsTr("Download complete")
            downloadNote.body = qsTr("%1 saved to Downloads").arg(fileName)
            downloadNote.previewSummary = downloadNote.summary
            downloadNote.previewBody = fileName
            downloadNote.replacesId = 0
            downloadNote.publish()
        }
        onFailed: {
            downloadNote.summary = qsTr("Download failed")
            downloadNote.body = fileName + ": " + error
            downloadNote.previewSummary = downloadNote.summary
            downloadNote.previewBody = fileName
            downloadNote.replacesId = 0
            downloadNote.publish()
        }
    }
}
