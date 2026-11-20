// RooThub - small formatting helpers
// Copyright (C) 2026 RootGPT - GPL-3.0
.pragma library

// "3 minutes ago", "yesterday", "2 months ago" ... (Italian on Italian phones;
// qsTr is not available in a .pragma library, hence the small table).
var REL = {
    en: { now: "just now", min1: "a minute ago", mins: "%1 minutes ago", hour1: "an hour ago", hours: "%1 hours ago",
          day1: "yesterday", days: "%1 days ago", month1: "a month ago", months: "%1 months ago",
          year1: "a year ago", years: "%1 years ago" },
    it: { now: "adesso", min1: "un minuto fa", mins: "%1 minuti fa", hour1: "un'ora fa", hours: "%1 ore fa",
          day1: "ieri", days: "%1 giorni fa", month1: "un mese fa", months: "%1 mesi fa",
          year1: "un anno fa", years: "%1 anni fa" }
};
function _rel() {
    var lang = "en";
    try { lang = ("" + Qt.locale().name).substring(0, 2); } catch (e) {}
    return REL[lang] || REL.en;
}
function relativeTime(iso) {
    if (!iso)
        return "";
    var then = new Date(iso).getTime();
    if (isNaN(then))
        return iso;
    var t = _rel();
    var secs = Math.floor((Date.now() - then) / 1000);
    if (secs < 0) secs = 0;
    if (secs < 45)   return t.now;
    if (secs < 90)   return t.min1;
    var mins = Math.round(secs / 60);
    if (mins < 45)   return t.mins.replace("%1", mins);
    var hours = Math.round(secs / 3600);
    if (hours < 24)  return hours === 1 ? t.hour1 : t.hours.replace("%1", hours);
    var days = Math.round(secs / 86400);
    if (days < 30)   return days === 1 ? t.day1 : t.days.replace("%1", days);
    var months = Math.round(days / 30);
    if (months < 12) return months === 1 ? t.month1 : t.months.replace("%1", months);
    var years = Math.round(days / 365);
    return years === 1 ? t.year1 : t.years.replace("%1", years);
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

// GitHub's language colours (the dot next to the language name).
var LANG_COLORS = {
    "JavaScript": "#f1e05a", "TypeScript": "#3178c6", "Python": "#3572A5", "C++": "#f34b7d",
    "C": "#555555", "QML": "#44a51c", "Java": "#b07219", "Kotlin": "#A97BFF", "Rust": "#dea584",
    "Go": "#00ADD8", "Shell": "#89e051", "HTML": "#e34c26", "CSS": "#663399", "Ruby": "#701516",
    "PHP": "#4F5D95", "C#": "#178600", "Swift": "#F05138", "Dart": "#00B4AB", "Lua": "#000080",
    "Makefile": "#427819", "CMake": "#DA3434", "Vue": "#41b883", "Jupyter Notebook": "#DA5B0B",
    "Objective-C": "#438eff", "Perl": "#0298c3", "Haskell": "#5e5086", "Zig": "#ec915c",
    "Nix": "#7e7eff", "Dockerfile": "#384d54", "TeX": "#3D6117", "Assembly": "#6E4C13",
    "Vim Script": "#199f4b", "Emacs Lisp": "#c065db", "SCSS": "#c6538c", "Scala": "#c22d40",
    "Elixir": "#6e4a7e", "Clojure": "#db5855", "R": "#198CE7", "Julia": "#a270ba",
    "PowerShell": "#012456", "Batchfile": "#C1F12E", "Svelte": "#ff3e00", "Fortran": "#4d41b1"
};
function langColor(lang) {
    return LANG_COLORS[lang] || "#00e5ff";
}
