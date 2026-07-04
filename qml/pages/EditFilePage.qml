/*
    RooThub - integrated file editor.
    Copyright (C) 2026 RootGPT - GPL-3.0

    Loads a file's text + blob sha, lets the user edit it and commits the
    change through the GitHub Contents API (PUT /repos/.../contents/{path}).
    Requires write access to the repository.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH

Page {
    id: page
    allowedOrientations: Orientation.All

    property string fullName: ""
    property string path: ""
    property string branch: ""
    property string fileName: ""

    property string sha: ""
    property bool loading: false
    property bool saving: false
    property string error: ""
    property bool dirty: editor.text !== loadedText
    property string loadedText: ""

    Component.onCompleted: load()

    // UTF-8 aware base64 (browser trick) so non-ASCII survives the round-trip.
    function b64encode(str) { return Qt.btoa(unescape(encodeURIComponent(str))) }
    function b64decode(b64) {
        try { return decodeURIComponent(escape(Qt.atob(b64.replace(/\n/g, "")))) }
        catch (e) { return Qt.atob(b64.replace(/\n/g, "")) }
    }

    function load() {
        loading = true
        error = ""
        var p = "/repos/" + fullName + "/contents/" + path + (branch ? ("?ref=" + branch) : "")
        GH.get(p, Settings.token, function(err, data) {
            loading = false
            if (err) { error = err.message; return }
            page.sha = data.sha
            var text = data.content ? b64decode(data.content) : ""
            page.loadedText = text
            editor.text = text
        })
    }

    function save() {
        if (saving) return
        saving = true
        error = ""
        var body = {
            message: (msgField.text.trim() !== "" ? msgField.text.trim()
                      : (qsTr("Update ") + fileName + qsTr(" via RooThub"))),
            content: b64encode(editor.text),
            sha: page.sha
        }
        if (branch) body.branch = branch
        GH.put("/repos/" + fullName + "/contents/" + path, Settings.token, body, function(err, data) {
            saving = false
            if (err) {
                error = (err.status === 403 || err.status === 404)
                    ? qsTr("Commit failed: you need write access (the 'repo' scope) to this repository.")
                    : err.message
                return
            }
            // Update sha so a second save works without reloading.
            if (data && data.content) page.sha = data.content.sha
            page.loadedText = editor.text
            pageStack.pop()
        })
    }

    CircuitBackground {}
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height


        PullDownMenu {
            MenuItem {
                text: qsTr("Commit")
                enabled: page.dirty && !page.saving && !page.loading
                onClicked: page.save()
            }
            MenuItem {
                text: qsTr("Revert changes")
                enabled: page.dirty
                onClicked: editor.text = page.loadedText
            }
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            NeonHeader {
                text: qsTr("Edit: ") + page.fileName
                description: page.fullName + (page.branch ? (" · " + page.branch) : "")
            }

            Label {
                visible: page.error !== ""
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: page.error
                color: Settings.closedColor
                font.pixelSize: Theme.fontSizeSmall
            }

            TextArea {
                id: editor
                width: parent.width
                label: qsTr("File contents")
                font.family: "monospace"
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: TextEdit.Wrap
                // Give the editor a generous minimum height.
                height: Math.max(implicitHeight, page.height * 0.5)
            }

            TextField {
                id: msgField
                width: parent.width
                label: qsTr("Commit message")
                placeholderText: qsTr("Update %1 via RooThub").arg(page.fileName)
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: if (page.dirty) page.save()
            }

            NeonButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.saving ? qsTr("Committing…") : qsTr("Commit")
                enabled: page.dirty && !page.saving && !page.loading
                onClicked: page.save()
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.loading || page.saving
        size: BusyIndicatorSize.Large
    }
}
