/*
    RooThub - page showing GitHub-rendered HTML like the browser does:
    README, rendered Markdown files, a release, a commit with its diff.
    Copyright (C) 2026 RootGPT - GPL-3.0

    kind:
      "markdown" - apiPath returns HTML (README / .md file via contents API)
      "release"  - apiPath is a release (fetched as html+json)
      "commit"   - apiPath is a commit (with files and patches)
      "html"     - bodyHtml is given directly
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import ".."
import "../components"
import "../js/GitHubApi.js" as GH
import "../js/Html.js" as Html
import "../js/Router.js" as Router

Page {
    id: page
    allowedOrientations: Orientation.All

    property string kind: "markdown"
    property string fullName: ""
    property string apiPath: ""
    property string ref: ""            // branch/tag used to resolve relative images
    property string docPath: ""        // path of a rendered .md file in the repo
    property string title: ""
    property string description: ""
    property string webUrl: ""
    property string bodyHtml: ""
    property string baseUrl: "https://github.com/"
    property string latestId: ""        // release id marked as "Latest"
    // Optional "view source" target (e.g. FilePage for a .md file)
    property var sourceProps: null

    property bool loading: false
    property string error: ""
    readonly property bool dark: Theme.colorScheme === Theme.LightOnDark
    readonly property string documentHtml: bodyHtml === "" ? ""
        : Html.page(bodyHtml, { dark: page.dark, base: page.baseUrl })

    // The web engine is heavy: start it only once the page is shown
    // (this page is also used as an attached page, see RepoPage).
    property bool started: false
    onStatusChanged: if (status === PageStatus.Active && !started) { started = true; load() }

    function load() {
        if (kind === "html" || apiPath === "") return
        loading = true
        error = ""
        if (kind === "markdown") {
            GH.getHtml(apiPath, Settings.token, function(err, html) {
                loading = false
                if (err) { error = err.status === 404 ? qsTr("Nothing to show") : err.message; return }
                page.baseUrl = Html.readmeBase(html, page.fullName, page.ref, page.docPath)
                page.bodyHtml = html
            })
        } else if (kind === "release") {
            GH.getAs(apiPath, Settings.token, "application/vnd.github.html+json", function(err, text) {
                loading = false
                if (err) { error = err.message; return }
                var rel = null
                try { rel = JSON.parse(text) } catch (e) { error = "" + e; return }
                if (page.title === "") page.title = rel.tag_name
                page.description = page.fullName
                page.webUrl = rel.html_url
                page.baseUrl = rel.html_url
                page.bodyHtml = Html.release(rel, page.fullName, ("" + rel.id) === page.latestId, {
                    latest: qsTr("Latest"), prerelease: qsTr("Pre-release"), draft: qsTr("Draft"),
                    assets: qsTr("Assets"), downloads: qsTr("%1 downloads"),
                    sourceZip: qsTr("Source code (zip)"), sourceTar: qsTr("Source code (tar.gz)"),
                    noNotes: qsTr("No release notes.")
                })
            })
        } else if (kind === "commit") {
            GH.get(apiPath, Settings.token, function(err, c) {
                loading = false
                if (err) { error = err.message; return }
                page.title = ("" + c.sha).substring(0, 7)
                page.description = page.fullName
                page.webUrl = c.html_url
                page.baseUrl = c.html_url
                page.bodyHtml = Html.commit(c, page.fullName, {
                    files: qsTr("%1 files changed"), noDiff: qsTr("Binary or very large file: no diff shown.")
                })
            })
        }
    }

    function openLink(url) {
        // Release assets and source archives are downloaded in-app.
        var dl = ("" + url).match(/^https:\/\/github\.com\/([^\/]+)\/([^\/]+)\/(releases\/download\/|archive\/refs\/tags\/)(.*)$/)
        if (dl) {
            var name = ""
            if (dl[3] !== "releases/download/") {   // v1.0.zip -> repo-v1.0.zip
                try { name = dl[2] + "-" + decodeURIComponent(dl[4]) } catch (e) { name = dl[2] + "-" + dl[4] }
            }
            downloader.start(url, name)
            return
        }
        var r = Router.route(url)
        if (r) pageStack.push(Qt.resolvedUrl(r.page), r.props)
        else Qt.openUrlExternally(url)
    }

    CircuitBackground { visible: web.status !== Loader.Ready }

    Loader {
        id: web
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: downloadBar.top }
        active: page.started
        source: "../components/WebHtmlView.qml"
        onLoaded: {
            item.headerTitle = Qt.binding(function() { return page.title })
            item.headerDescription = Qt.binding(function() { return page.description })
            item.webUrl = Qt.binding(function() { return page.webUrl })
            item.showSource = Qt.binding(function() { return page.sourceProps !== null })
            item.baseUrl = Qt.binding(function() { return page.baseUrl })
            item.html = Qt.binding(function() { return page.documentHtml })
        }
    }
    Connections {
        target: web.item
        ignoreUnknownSignals: true
        onLinkRequested: page.openLink(url)
        onSourceRequested: pageStack.push(Qt.resolvedUrl("FilePage.qml"), page.sourceProps)
    }

    DownloadBar { id: downloadBar; z: 10 }

    // Fallback without Sailfish.WebView: Qt rich text of the same HTML.
    SilicaFlickable {
        visible: web.status === Loader.Error
        anchors.fill: parent
        contentHeight: fbCol.height
        PullDownMenu {
            visible: page.webUrl !== ""
            MenuItem { text: qsTr("Open on GitHub"); onClicked: Qt.openUrlExternally(page.webUrl) }
        }
        Column {
            id: fbCol
            width: parent.width
            NeonHeader { text: page.title; description: page.description }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                baseUrl: page.baseUrl
                text: web.status === Loader.Error ? page.bodyHtml : ""
                color: Theme.primaryColor
                linkColor: Settings.accent
                font.pixelSize: Theme.fontSizeSmall
                onLinkActivated: page.openLink(link)
            }
            Item { width: 1; height: Theme.paddingLarge }
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: page.loading
        size: BusyIndicatorSize.Large
    }
    Label {
        visible: !page.loading && page.error !== ""
        anchors.centerIn: parent
        width: parent.width - 2 * Theme.horizontalPageMargin
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: page.error
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeLarge
    }
}
