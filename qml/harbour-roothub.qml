/*
    RooThub - a native GitHub client for Sailfish OS
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
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
}
