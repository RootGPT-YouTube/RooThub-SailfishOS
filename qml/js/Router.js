// RooThub - map github.com links to in-app pages
// Copyright (C) 2026 RootGPT - GPL-3.0
//
// route(url) -> { page: "XxxPage.qml", props: {...} } or null when the link
// should go to the browser. Page names are relative to qml/pages/.
.pragma library

// First path segments that are GitHub sections, not users.
var RESERVED = ["about", "apps", "collections", "contact", "customer-stories", "enterprise",
    "events", "explore", "features", "issues", "login", "marketplace", "new", "notifications",
    "orgs", "organizations", "pricing", "pulls", "readme", "search", "settings", "site",
    "sponsors", "team", "topics", "trending", "security", "codespaces", "logout", "join"];

function _fileProps(fullName, ref, path) {
    var name = path.split("/").pop();
    return { fullName: fullName, branch: ref, path: path, fileName: name,
             downloadUrl: "https://raw.githubusercontent.com/" + fullName + "/" + ref + "/" + path };
}

function route(url) {
    var m = ("" + url).match(/^https?:\/\/(github\.com|raw\.githubusercontent\.com)\/([^?#]*)/i);
    if (!m)
        return null;
    var host = m[1].toLowerCase();
    var parts = m[2].split("/").filter(function(s) { return s !== ""; });
    for (var i = 0; i < parts.length; i++) {
        try { parts[i] = decodeURIComponent(parts[i]); } catch (e) {}
    }
    if (host === "raw.githubusercontent.com") {
        if (parts.length < 4) return null;
        // Relative links in a README resolve here (see Html.readmeBase).
        return route("https://github.com/" + parts[0] + "/" + parts[1] + "/blob/" + parts[2] + "/" + parts.slice(3).join("/"));
    }
    if (parts.length === 0)
        return null;
    if (parts.length === 1) {
        if (RESERVED.indexOf(parts[0].toLowerCase()) !== -1) return null;
        return { page: "UserPage.qml", props: { login: parts[0] } };
    }
    if (RESERVED.indexOf(parts[0].toLowerCase()) !== -1)
        return null;
    var fullName = parts[0] + "/" + parts[1].replace(/\.git$/, "");
    if (parts.length === 2)
        return { page: "RepoPage.qml", props: { fullName: fullName } };
    var sec = parts[2];
    if (sec === "issues" && parts.length === 3)
        return { page: "IssueListPage.qml", props: { mode: "repo", fullName: fullName, title: "Issues" } };
    if (sec === "issues" && /^\d+$/.test(parts[3]))
        return { page: "IssuePage.qml", props: { fullName: fullName, number: parseInt(parts[3], 10) } };
    if (sec === "pulls" && parts.length === 3)
        return { page: "IssueListPage.qml", props: { mode: "repo-pr", fullName: fullName, title: "Pull requests" } };
    if (sec === "pull" && /^\d+$/.test(parts[3]))
        return { page: "PullPage.qml", props: { fullName: fullName, number: parseInt(parts[3], 10) } };
    if (sec === "releases" && parts.length === 3)
        return { page: "ReleasesPage.qml", props: { fullName: fullName } };
    if (sec === "releases" && parts[3] === "tag" && parts.length >= 5)
        return { page: "HtmlPage.qml", props: { kind: "release", fullName: fullName,
                 apiPath: "/repos/" + fullName + "/releases/tags/" + encodeURIComponent(parts.slice(4).join("/")) } };
    if (sec === "commits")
        return { page: "CommitsPage.qml", props: { fullName: fullName, branch: parts.length > 3 ? parts[3] : "" } };
    if (sec === "commit" && parts.length >= 4)
        return { page: "HtmlPage.qml", props: { kind: "commit", fullName: fullName,
                 apiPath: "/repos/" + fullName + "/commits/" + parts[3] } };
    if (sec === "tree" && parts.length >= 4)
        return { page: "CodePage.qml", props: { fullName: fullName, branch: parts[3], path: parts.slice(4).join("/") } };
    if ((sec === "blob" || sec === "raw") && parts.length >= 5) {
        var path = parts.slice(4).join("/");
        var fp = _fileProps(fullName, parts[3], path);
        if (sec === "blob" && /\.(md|markdown|mdown)$/i.test(path))
            return { page: "HtmlPage.qml", props: { kind: "markdown", fullName: fullName, ref: parts[3],
                     docPath: path, title: fp.fileName, description: fullName, sourceProps: fp,
                     webUrl: "https://github.com/" + fullName + "/blob/" + parts[3] + "/" + path,
                     apiPath: "/repos/" + fullName + "/contents/" + path + "?ref=" + encodeURIComponent(parts[3]) } };
        return { page: "FilePage.qml", props: fp };
    }
    if (sec === "branches")
        return { page: "RefsPage.qml", props: { fullName: fullName, mode: "branches" } };
    if (sec === "tags")
        return { page: "RefsPage.qml", props: { fullName: fullName, mode: "tags" } };
    return null;   // downloads, wiki, actions, ... -> browser
}
