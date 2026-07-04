/*
    RooThub - NEON BLUE button (family look).
    Copyright (C) 2026 RootGPT - GPL-3.0

    Glass card (translucent Rectangle + glowing cyan border) with a neon
    label. Falls back to a native Silica Button with the plain theme.
    Drop-in for a Silica Button: exposes `text`, `enabled`, `clicked()`.
*/
import QtQuick 2.6
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import ".."

Item {
    id: neonButton

    property string text: ""
    property color accentColor: Settings.accent
    signal clicked()

    enabled: true
    readonly property bool neon: Settings.neonTheme

    implicitHeight: neon ? (neonLoader.item ? neonLoader.item.implicitHeight : 0)
                         : (silicaLoader.item ? silicaLoader.item.implicitHeight : 0)
    implicitWidth: neon ? (neonLoader.item ? neonLoader.item.implicitWidth : 0)
                        : (silicaLoader.item ? silicaLoader.item.implicitWidth : 0)
    width: implicitWidth
    height: implicitHeight

    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { FadeAnimation {} }

    // --- Plain Silica theme: native Button ---
    Loader {
        id: silicaLoader
        anchors.fill: parent
        active: !neonButton.neon
        sourceComponent: Button {
            text: neonButton.text
            enabled: neonButton.enabled
            onClicked: neonButton.clicked()
        }
    }

    // --- Neon theme: glass card + neon label ---
    Loader {
        id: neonLoader
        anchors.fill: parent
        active: neonButton.neon
        sourceComponent: MouseArea {
            id: neonArea
            enabled: neonButton.enabled
            property bool down: pressed && containsMouse
            implicitHeight: Math.max(Theme.itemSizeSmall, labelCore.implicitHeight + 2 * Theme.paddingMedium)
            implicitWidth: Math.min(
                               Screen.width - 2 * Theme.horizontalPageMargin,
                               labelCore.implicitWidth + 4 * Theme.paddingLarge)
            onClicked: neonButton.clicked()

            Rectangle {
                id: glassCard
                anchors.fill: parent
                radius: Theme.paddingLarge
                color: Theme.rgba("#0a1628", neonArea.down ? 0.55 : 0.35)
                border.width: 2
                border.color: Theme.rgba(neonButton.accentColor, neonArea.down ? 0.90 : 0.55)
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            Label {
                id: labelHalo
                anchors {
                    left: glassCard.left; right: glassCard.right
                    verticalCenter: glassCard.verticalCenter
                    leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium
                }
                horizontalAlignment: Text.AlignHCenter
                truncationMode: TruncationMode.Fade
                text: neonButton.text
                font.family: Theme.fontFamilyHeading
                font.italic: true
                color: neonButton.accentColor
                textFormat: Text.PlainText
                layer.enabled: true
                layer.effect: Glow {
                    color: neonButton.accentColor
                    radius: 12
                    samples: 25
                    spread: 0.20
                    transparentBorder: true
                }
            }
            Label {
                id: labelCore
                anchors {
                    left: glassCard.left; right: glassCard.right
                    verticalCenter: glassCard.verticalCenter
                    leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium
                }
                horizontalAlignment: Text.AlignHCenter
                truncationMode: TruncationMode.Fade
                text: neonButton.text
                font.family: Theme.fontFamilyHeading
                font.italic: true
                color: "#eafcff"
                textFormat: Text.PlainText
            }
        }
    }
}
