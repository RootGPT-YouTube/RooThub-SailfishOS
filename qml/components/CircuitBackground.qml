/*
    RooThub - ambient "circuit board" background (family neon look).
    Copyright (C) 2026 RootGPT - GPL-3.0

    Same treatment as RooTelegram: the shared bg_circuits.svg rendered very
    transparent with a strong FastBlur so the cyan traces become a soft neon
    haze behind page content. Only active with the Neon theme.
*/
import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import ".."

Loader {
    id: circuitBackground
    z: -1
    anchors.fill: parent
    active: Settings.neonTheme
    asynchronous: true
    sourceComponent: Image {
        source: Qt.resolvedUrl("../../images/bg_circuits.svg")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: 0.12
        sourceSize.width: circuitBackground.width > 0 ? circuitBackground.width : 540
        sourceSize.height: circuitBackground.height > 0 ? circuitBackground.height : 960
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 48
            transparentBorder: true
        }
    }
}
