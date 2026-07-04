/*
    RooThub - create a new issue.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH

Dialog {
    id: dialog
    allowedOrientations: Orientation.All

    property string fullName: ""
    property bool posting: false

    canAccept: titleField.text.trim().length > 0 && !posting
    acceptDestinationAction: PageStackAction.Pop

    onAccepted: {
        // Fire the create request; navigate back optimistically.
        GH.post("/repos/" + fullName + "/issues", Settings.token,
            { title: titleField.text.trim(), body: bodyField.text }, function(err) {})
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Create")
                title: qsTr("New issue")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: fullName
                color: Settings.accent
                font.pixelSize: Theme.fontSizeSmall
            }
            TextField {
                id: titleField
                width: parent.width
                label: qsTr("Title")
                placeholderText: qsTr("Issue title")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: bodyField.focus = true
            }
            TextArea {
                id: bodyField
                width: parent.width
                label: qsTr("Description")
                placeholderText: qsTr("Describe the issue (Markdown supported)")
            }
        }
    }
}
