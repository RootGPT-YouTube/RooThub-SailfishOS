// RooThub - small formatting helpers
// Copyright (C) 2026 RootGPT - GPL-3.0
.pragma library

// "3 minutes ago", "yesterday", "2 months ago" ...
function relativeTime(iso) {
    if (!iso)
        return "";
    var then = new Date(iso).getTime();
    if (isNaN(then))
        return iso;
    var secs = Math.floor((Date.now() - then) / 1000);
    if (secs < 0) secs = 0;
    if (secs < 45)   return "just now";
    if (secs < 90)   return "a minute ago";
    var mins = Math.round(secs / 60);
    if (mins < 45)   return mins + " minutes ago";
    var hours = Math.round(secs / 3600);
    if (hours < 24)  return hours + (hours === 1 ? " hour ago" : " hours ago");
    var days = Math.round(secs / 86400);
    if (days < 30)   return days + (days === 1 ? " day ago" : " days ago");
    var months = Math.round(days / 30);
    if (months < 12) return months + (months === 1 ? " month ago" : " months ago");
    var years = Math.round(days / 365);
    return years + (years === 1 ? " year ago" : " years ago");
}

// 1234 -> "1.2k", 1500000 -> "1.5M"
function compact(n) {
    if (n === undefined || n === null)
        return "0";
    n = Number(n);
    if (n < 1000)      return "" + n;
    if (n < 1000000)   return (n / 1000).toFixed(n < 10000 ? 1 : 0).replace(/\.0$/, "") + "k";
    return (n / 1000000).toFixed(1).replace(/\.0$/, "") + "M";
}

function escapeHtml(s) {
    if (!s)
        return "";
    return ("" + s).replace(/&/g, "&amp;")
                   .replace(/</g, "&lt;")
                   .replace(/>/g, "&gt;");
}

// A deliberately light Markdown -> Qt StyledText converter. Handles the
// common cases seen in issues/READMEs; it is not a full CommonMark parser.
function markdownToHtml(md) {
    if (!md)
        return "";
    var lines = ("" + md).replace(/\r\n/g, "\n").split("\n");
    var out = [];
    var inCode = false;
    var codeBuf = [];
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (/^```/.test(line)) {
            if (inCode) {
                out.push('<pre>' + escapeHtml(codeBuf.join("\n")) + '</pre>');
                codeBuf = [];
                inCode = false;
            } else {
                inCode = true;
            }
            continue;
        }
        if (inCode) { codeBuf.push(line); continue; }

        var h = line.match(/^(#{1,6})\s+(.*)$/);
        if (h) {
            var sz = [null, "x-large", "large", "large", "medium", "medium", "medium"][h[1].length];
            out.push('<font size="' + (h[1].length <= 2 ? 5 : 4) + '"><b>' + inline(h[2]) + '</b></font>');
            continue;
        }
        if (/^\s*[-*]\s+/.test(line)) {
            out.push('&nbsp;&nbsp;&#8226; ' + inline(line.replace(/^\s*[-*]\s+/, "")));
            continue;
        }
        if (/^\s*$/.test(line)) { out.push("<br/>"); continue; }
        out.push(inline(line) + '<br/>');
    }
    if (inCode)
        out.push('<pre>' + escapeHtml(codeBuf.join("\n")) + '</pre>');
    return out.join("\n");
}

// Inline formatting: code spans, bold, italic, links, @mentions, #refs.
function inline(s) {
    s = escapeHtml(s);
    s = s.replace(/`([^`]+)`/g, '<font face="monospace" color="#4fc3f7">$1</font>');
    s = s.replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>');
    s = s.replace(/(^|[\s(])\*([^*\s][^*]*)\*/g, '$1<i>$2</i>');
    s = s.replace(/\[([^\]]+)\]\((https?:\/\/[^)]+)\)/g, '<a href="$2">$1</a>');
    s = s.replace(/(^|\s)(https?:\/\/[^\s<]+)/g, '$1<a href="$2">$2</a>');
    return s;
}
