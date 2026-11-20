/*
    RooThub - HTML document in the system web engine (Sailfish.WebView).
    Copyright (C) 2026 RootGPT - GPL-3.0

    Loaded through a Loader by HtmlPage: if Sailfish.WebView is missing the
    Loader fails and HtmlPage falls back to Qt rich text.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import ".."

WebViewFlickable {
    id: view

    property string html: ""
    property string baseUrl: ""
    property string headerTitle: ""
    property string headerDescription: ""
    property string webUrl: ""
    property bool showSource: false

    signal linkRequested(string url)
    signal sourceRequested()

    function _strip(u) { return ("" + u).replace(/#.*$/, "") }

    function reload() {
        if (view.html !== "")
            webView.loadHtml(view.html, view.baseUrl)
    }

    onHtmlChanged: reload()
    Component.onCompleted: reload()

    Connections {
        target: view.webView
        onViewInitialized: view.reload()
        // The page reports a tapped link as #rh-link:<n>:<encoded url> (see
        // Html.js); a real navigation (should the page script fail) is
        // caught too, handed over, and the document is reloaded.
        onUrlChanged: {
            var u = "" + view.webView.url
            var i = u.indexOf("#rh-link:")
            if (i !== -1) {
                var rest = u.substring(i + 9)
                var target = rest.substring(rest.indexOf(":") + 1)
                try { target = decodeURIComponent(target) } catch (e) {}
                view.linkRequested(target)
            } else if (/^https?:/.test(u) && view._strip(u) !== view._strip(view.baseUrl)) {
                view.linkRequested(u)
                view.reload()
            }
        }
    }

    header: PageHeader {
        title: view.headerTitle
        description: view.headerDescription
        leftMargin: Theme.horizontalPageMargin + (view.webUrl !== "" ? Theme.iconSizeMedium : 0)
                    + (view.showSource ? Theme.iconSizeMedium : 0)
        Row {
            anchors { left: parent.left; leftMargin: Theme.paddingSmall; verticalCenter: parent.verticalCenter }
            IconButton {
                visible: view.webUrl !== ""
                icon.source: "image://theme/icon-m-website"
                onClicked: Qt.openUrlExternally(view.webUrl)
            }
            IconButton {
                visible: view.showSource
                icon.source: "image://theme/icon-m-document"
                onClicked: view.sourceRequested()
            }
        }
    }
}
