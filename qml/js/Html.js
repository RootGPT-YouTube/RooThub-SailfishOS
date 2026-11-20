// RooThub - HTML documents for the web view (README, releases, commits)
// Copyright (C) 2026 RootGPT - GPL-3.0
//
// GitHub already renders Markdown to HTML (README, release notes); here we
// wrap that HTML in a full page with a GitHub-like stylesheet, so it looks
// the way it does in the browser. Written from scratch, no external CSS.
.pragma library

function esc(s) {
    if (s === undefined || s === null)
        return "";
    return ("" + s).replace(/&/g, "&amp;").replace(/</g, "&lt;")
                   .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function size(bytes) {
    var n = Number(bytes) || 0;
    if (n < 1024) return n + " B";
    if (n < 1048576) return (n / 1024).toFixed(1) + " KB";
    if (n < 1073741824) return (n / 1048576).toFixed(1) + " MB";
    return (n / 1073741824).toFixed(2) + " GB";
}

function date(iso) {
    if (!iso) return "";
    var d = new Date(iso);
    return isNaN(d.getTime()) ? iso : d.toLocaleDateString();
}

var DARK = {
    scheme: "dark", bg: "#0d1117", fg: "#e6edf3", muted: "#9198a1", border: "#3d444d",
    subtle: "#151b23", link: "#4493f8", codeBg: "rgba(101,108,118,0.2)",
    green: "#3fb950", red: "#f85149", purple: "#ab7df8", yellow: "#d29922",
    addBg: "rgba(46,160,67,0.15)", delBg: "rgba(248,81,73,0.15)", hunkBg: "rgba(56,139,253,0.1)",
    k: "#ff7b72", s: "#a5d6ff", c: "#9198a1", en: "#d2a8ff", c1: "#79c0ff", v: "#ffa657", ent: "#7ee787"
};
var LIGHT = {
    scheme: "light", bg: "#ffffff", fg: "#1f2328", muted: "#59636e", border: "#d1d9e0",
    subtle: "#f6f8fa", link: "#0969da", codeBg: "rgba(129,139,152,0.12)",
    green: "#1a7f37", red: "#d1242f", purple: "#8250df", yellow: "#9a6700",
    addBg: "#dafbe1", delBg: "#ffebe9", hunkBg: "#ddf4ff",
    k: "#cf222e", s: "#0a3069", c: "#59636e", en: "#6639ba", c1: "#0550ae", v: "#953800", ent: "#116329"
};

function css(p) {
    return "" +
"*{box-sizing:border-box}" +
"html{-webkit-text-size-adjust:100%;text-size-adjust:100%;color-scheme:" + p.scheme + "}" +
"body{margin:0;padding:16px;background:" + p.bg + ";color:" + p.fg + ";" +
"font-family:-apple-system,'Segoe UI','Noto Sans',Helvetica,Arial,sans-serif;font-size:16px;line-height:1.5;word-wrap:break-word}" +
"a{color:" + p.link + ";text-decoration:none}" +
"p,blockquote,ul,ol,dl,table,pre,details{margin-top:0;margin-bottom:16px}" +
"h1,h2,h3,h4,h5,h6{margin-top:24px;margin-bottom:16px;font-weight:600;line-height:1.25}" +
"h1{font-size:2em;padding-bottom:.3em;border-bottom:1px solid " + p.border + "}" +
"h2{font-size:1.5em;padding-bottom:.3em;border-bottom:1px solid " + p.border + "}" +
"h3{font-size:1.25em}h4{font-size:1em}h5{font-size:.875em}h6{font-size:.85em;color:" + p.muted + "}" +
".markdown-heading{position:relative}.anchor,.octicon-link{display:none}" +
".markdown-body>*:first-child,.markdown-body>.markdown-heading:first-child>*{margin-top:0}" +
"img{max-width:100%;height:auto;border-style:none;vertical-align:middle;background:transparent}" +
"p img,a img{display:inline-block}" +
"hr{height:.25em;padding:0;margin:24px 0;background:" + p.border + ";border:0}" +
"blockquote{margin-left:0;margin-right:0;padding:0 1em;color:" + p.muted + ";border-left:.25em solid " + p.border + "}" +
"ul,ol{padding-left:2em}li+li{margin-top:.25em}li>p{margin-top:16px}" +
"ul.contains-task-list{padding-left:0;list-style:none}.task-list-item input{margin:0 .3em .25em 0;vertical-align:middle}" +
"code,tt,pre,kbd{font-family:ui-monospace,'DejaVu Sans Mono','Liberation Mono',monospace;font-size:85%}" +
"code{padding:.2em .4em;margin:0;white-space:break-spaces;background:" + p.codeBg + ";border-radius:6px}" +
"pre{padding:16px;overflow:auto;line-height:1.45;background:" + p.subtle + ";border-radius:6px;word-wrap:normal}" +
"pre code{padding:0;background:transparent;white-space:pre;font-size:100%}" +
".highlight pre{margin-bottom:0}.highlight{margin-bottom:16px}" +
"kbd{padding:3px 5px;line-height:10px;border:1px solid " + p.border + ";border-radius:6px;box-shadow:inset 0 -1px 0 " + p.border + "}" +
"table{display:block;width:max-content;max-width:100%;overflow:auto;border-spacing:0;border-collapse:collapse}" +
"table th{font-weight:600}table th,table td{padding:6px 13px;border:1px solid " + p.border + "}" +
"table tr{background:" + p.bg + ";border-top:1px solid " + p.border + "}table tr:nth-child(2n){background:" + p.subtle + "}" +
"details summary{cursor:pointer;font-weight:600}" +
".markdown-alert{padding:.5rem 1rem;margin-bottom:16px;border-left:.25em solid " + p.border + "}" +
".markdown-alert-title{font-weight:600;display:flex;align-items:center}.markdown-alert-title svg{margin-right:8px;fill:currentColor}" +
".markdown-alert-note{border-left-color:" + p.link + "}.markdown-alert-note .markdown-alert-title{color:" + p.link + "}" +
".markdown-alert-tip{border-left-color:" + p.green + "}.markdown-alert-tip .markdown-alert-title{color:" + p.green + "}" +
".markdown-alert-important{border-left-color:" + p.purple + "}.markdown-alert-important .markdown-alert-title{color:" + p.purple + "}" +
".markdown-alert-warning{border-left-color:" + p.yellow + "}.markdown-alert-warning .markdown-alert-title{color:" + p.yellow + "}" +
".markdown-alert-caution{border-left-color:" + p.red + "}.markdown-alert-caution .markdown-alert-title{color:" + p.red + "}" +
"g-emoji{font-style:normal}" +
".pl-k{color:" + p.k + "}.pl-s,.pl-pds,.pl-sr{color:" + p.s + "}.pl-c{color:" + p.c + "}" +
".pl-en,.pl-e{color:" + p.en + "}.pl-c1,.pl-s .pl-v,.pl-mi1{color:" + p.c1 + "}.pl-v,.pl-smi{color:" + p.v + "}" +
".pl-ent{color:" + p.ent + "}.pl-s1{color:" + p.fg + "}.pl-smi{color:" + p.fg + "}" +
// RooThub-specific blocks (release header, assets, commit files)
".rh-muted{color:" + p.muted + ";font-size:14px}" +
".rh-title{font-size:1.6em;font-weight:600;margin:0 0 8px 0;line-height:1.25}" +
".rh-badge{display:inline-block;padding:0 7px;margin-right:6px;font-size:12px;font-weight:500;line-height:18px;border:1px solid;border-radius:2em}" +
".rh-latest{color:" + p.green + ";border-color:" + p.green + "}.rh-pre{color:" + p.yellow + ";border-color:" + p.yellow + "}" +
".rh-draft{color:" + p.muted + ";border-color:" + p.border + "}" +
".rh-box{border:1px solid " + p.border + ";border-radius:6px;margin:16px 0;overflow:hidden}" +
".rh-box-h{padding:8px 16px;background:" + p.subtle + ";font-weight:600;border-bottom:1px solid " + p.border + "}" +
".rh-row{padding:10px 16px;border-top:1px solid " + p.border + ";display:flex;flex-wrap:wrap;justify-content:space-between;gap:4px 12px}" +
".rh-box-h+.rh-row{border-top:0}.rh-row a{font-weight:600;word-break:break-all}" +
".rh-msg{white-space:pre-wrap;font-family:inherit;background:transparent;padding:0;margin:0 0 16px 0;font-size:15px}" +
".rh-add{color:" + p.green + "}.rh-del{color:" + p.red + "}" +
".rh-diff{margin:0;padding:0;font-size:12px;line-height:1.5;background:" + p.bg + ";overflow:auto}" +
".rh-diff span{display:block;padding:0 8px;white-space:pre;min-width:max-content}" +
".rh-diff .a{background:" + p.addBg + "}.rh-diff .d{background:" + p.delBg + "}.rh-diff .h{background:" + p.hunkBg + ";color:" + p.muted + "}";
}

// Links are not followed by the page: a click hands the absolute URL to QML
// through the URL fragment (#rh-link:<n>:<url>), and QML decides (open in-app
// or in the browser). The document title is no good for this: Sailfish's
// WebView reports title changes made after the page has loaded only late or
// never (verified on the POCO, 20/11/2026), while every URL change is reported.
var CLICK_JS = "" +
"document.addEventListener('click',function(e){" +
"var a=e.target;while(a&&a.tagName!=='A')a=a.parentNode;if(!a)return;" +
"var h=a.getAttribute('href');if(!h)return;e.preventDefault();" +
"if(h.charAt(0)==='#'){var id=decodeURIComponent(h.substring(1));" +
"var t=document.getElementById(id)||document.getElementById('user-content-'+id);" +
"if(t)t.scrollIntoView();return;}" +
"location.hash='rh-link:'+Date.now()+':'+encodeURIComponent(a.href);},true);";

// Full page around `body`. opts: { dark: bool, base: "https://…/" }
function page(body, opts) {
    var p = (opts && opts.dark === false) ? LIGHT : DARK;
    var base = (opts && opts.base) ? '<base href="' + esc(opts.base) + '">' : "";
    return '<!DOCTYPE html><html><head><meta charset="utf-8">' +
        '<meta name="viewport" content="width=device-width, initial-scale=1">' +
        base + '<title>RooThub</title><style>' + css(p) + '</style></head>' +
        '<body><div class="markdown-body">' + body + '</div>' +
        '<script>' + CLICK_JS + '</script></body></html>';
}

function background(dark) { return dark === false ? LIGHT.bg : DARK.bg; }

// The README endpoint returns <div id="readme" data-path="docs/README.md">;
// relative image paths are relative to that file, on raw.githubusercontent.
function readmeBase(html, fullName, ref, docPath) {
    var m = ("" + html).match(/data-path="([^"]*)"/);
    var path = m ? m[1] : (docPath || "");
    var dir = "";
    if (path.lastIndexOf("/") !== -1)
        dir = path.substring(0, path.lastIndexOf("/") + 1);
    return "https://raw.githubusercontent.com/" + fullName + "/" + (ref || "HEAD") + "/" + dir;
}

// Release page body. `rel` comes from the API with the html+json media type
// (it carries body_html). `t` holds the translated labels.
function release(rel, fullName, isLatest, t) {
    var h = '<div class="rh-title">' + esc(rel.name || rel.tag_name) + '</div><p>';
    if (rel.draft) h += '<span class="rh-badge rh-draft">' + esc(t.draft) + '</span>';
    if (rel.prerelease) h += '<span class="rh-badge rh-pre">' + esc(t.prerelease) + '</span>';
    if (isLatest) h += '<span class="rh-badge rh-latest">' + esc(t.latest) + '</span>';
    h += '<span class="rh-muted">' + esc(rel.tag_name);
    if (rel.author) h += ' · <a href="https://github.com/' + esc(rel.author.login) + '">' + esc(rel.author.login) + '</a>';
    h += ' · ' + esc(date(rel.published_at || rel.created_at)) + '</span></p>';
    h += rel.body_html ? rel.body_html : '<p class="rh-muted">' + esc(t.noNotes) + '</p>';

    var assets = rel.assets || [];
    var tag = encodeURIComponent(rel.tag_name);
    h += '<div class="rh-box"><div class="rh-box-h">' + esc(t.assets) + ' (' + (assets.length + 2) + ')</div>';
    for (var i = 0; i < assets.length; i++) {
        var a = assets[i];
        h += '<div class="rh-row"><a href="' + esc(a.browser_download_url) + '">' + esc(a.name) + '</a>' +
             '<span class="rh-muted">' + size(a.size) + ' · ' + esc(t.downloads.replace("%1", a.download_count)) + '</span></div>';
    }
    h += '<div class="rh-row"><a href="https://github.com/' + fullName + '/archive/refs/tags/' + tag + '.zip">' +
         esc(t.sourceZip) + '</a></div>';
    h += '<div class="rh-row"><a href="https://github.com/' + fullName + '/archive/refs/tags/' + tag + '.tar.gz">' +
         esc(t.sourceTar) + '</a></div></div>';
    return h;
}

function _diff(patch) {
    var lines = ("" + patch).split("\n");
    var out = [];
    for (var i = 0; i < lines.length; i++) {
        var c = lines[i].charAt(0);
        var cls = c === "+" ? "a" : (c === "-" ? "d" : (c === "@" ? "h" : ""));
        out.push('<span' + (cls ? ' class="' + cls + '"' : '') + '>' + (esc(lines[i]) || " ") + '</span>');
    }
    return '<pre class="rh-diff">' + out.join("") + '</pre>';
}

// Commit page body: message, author, stats and the per-file diffs.
function commit(c, fullName, t) {
    var msg = (c.commit && c.commit.message) ? c.commit.message : "";
    var nl = msg.indexOf("\n");
    var head = nl === -1 ? msg : msg.substring(0, nl);
    var rest = nl === -1 ? "" : msg.substring(nl + 1).replace(/^\s+/, "");
    var who = c.author ? c.author.login : (c.commit && c.commit.author ? c.commit.author.name : "");
    var when = c.commit && c.commit.author ? c.commit.author.date : "";
    var h = '<div class="rh-title">' + esc(head) + '</div>';
    if (rest) h += '<pre class="rh-msg">' + esc(rest) + '</pre>';
    h += '<p class="rh-muted">';
    h += c.author ? '<a href="https://github.com/' + esc(who) + '">' + esc(who) + '</a>' : esc(who);
    h += ' · ' + esc(date(when)) + ' · <code>' + esc(("" + c.sha).substring(0, 7)) + '</code>';
    if (c.stats) h += '<br><span class="rh-add">+' + c.stats.additions + '</span> <span class="rh-del">−' +
                      c.stats.deletions + '</span> · ' + esc(t.files.replace("%1", (c.files || []).length));
    h += '</p>';
    var files = c.files || [];
    for (var i = 0; i < files.length; i++) {
        var f = files[i];
        h += '<div class="rh-box"><div class="rh-box-h" style="display:flex;justify-content:space-between;gap:8px">' +
             '<a style="word-break:break-all" href="https://github.com/' + fullName + '/blob/' + c.sha + '/' + esc(f.filename) + '">' +
             esc(f.filename) + '</a><span style="white-space:nowrap"><span class="rh-add">+' + f.additions +
             '</span> <span class="rh-del">−' + f.deletions + '</span></span></div>';
        h += f.patch ? _diff(f.patch) : '<div class="rh-row rh-muted">' + esc(t.noDiff) + '</div>';
        h += '</div>';
    }
    return h;
}
