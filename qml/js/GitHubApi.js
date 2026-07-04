// RooThub - GitHub REST client (pure JS, no dependencies)
// Copyright (C) 2026 RootGPT - GPL-3.0
//
// Shared library: `.pragma library` gives every importer the SAME module
// instance, so constants/helpers are defined once for the whole app.
.pragma library

var API = "https://api.github.com";
var WEB = "https://github.com";

function _resolve(path) {
    if (path.indexOf("http://") === 0 || path.indexOf("https://") === 0)
        return path;
    if (path.charAt(0) !== "/")
        path = "/" + path;
    return API + path;
}

// Parse the RFC5988 Link header and return the URL for rel="next", or null.
function nextLink(linkHeader) {
    if (!linkHeader)
        return null;
    var parts = linkHeader.split(",");
    for (var i = 0; i < parts.length; i++) {
        var section = parts[i].split(";");
        if (section.length < 2)
            continue;
        var url = section[0].replace(/<(.*)>/, "$1").trim();
        for (var j = 1; j < section.length; j++) {
            if (section[j].indexOf('rel="next"') !== -1)
                return url;
        }
    }
    return null;
}

// Core request. cb(err, data, meta)
//   err  = null on success, else { status, message, data }
//   data = parsed JSON (or raw text)
//   meta = { status, link, next, xhr }
function request(method, path, token, body, cb) {
    var xhr = new XMLHttpRequest();
    // Qt 5.6's QML XMLHttpRequest rejects PATCH (open() throws), so tunnel
    // PATCH through POST + X-HTTP-Method-Override, which GitHub honours.
    var httpMethod = (method === "PATCH") ? "POST" : method;
    try {
        xhr.open(httpMethod, _resolve(path));
        xhr.setRequestHeader("Accept", "application/vnd.github+json");
        xhr.setRequestHeader("X-GitHub-Api-Version", "2022-11-28");
        if (method === "PATCH")
            xhr.setRequestHeader("X-HTTP-Method-Override", "PATCH");
        if (token)
            xhr.setRequestHeader("Authorization", "token " + token);
        if (body !== undefined && body !== null)
            xhr.setRequestHeader("Content-Type", "application/json");
    } catch (e) {
        cb({ status: 0, message: "" + e, data: null }, null, { status: 0 });
        return xhr;
    }

    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4)
            return;
        var text = xhr.responseText;
        var data = null;
        if (text) {
            try { data = JSON.parse(text); }
            catch (e) { data = text; }
        }
        var link = null;
        try { link = xhr.getResponseHeader("Link"); } catch (e) {}
        var meta = { status: xhr.status, link: link, next: nextLink(link), xhr: xhr };
        if (xhr.status >= 200 && xhr.status < 300) {
            cb(null, data, meta);
        } else {
            var msg = (data && data.message) ? data.message
                    : (xhr.status === 0 ? qsTrId_fallback("Network error")
                                        : ("HTTP " + xhr.status));
            cb({ status: xhr.status, message: msg, data: data }, null, meta);
        }
    };

    try {
        xhr.send((body !== undefined && body !== null) ? JSON.stringify(body) : undefined);
    } catch (e) {
        cb({ status: 0, message: "" + e, data: null }, null, { status: 0 });
    }
    return xhr;
}

// qsTr is not available inside a `.pragma library`; keep messages plain.
function qsTrId_fallback(s) { return s; }

// GET returning the raw resource (e.g. a README or file blob) as text.
// cb(err, text, meta)
function getRaw(path, token, cb) {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", _resolve(path));
    xhr.setRequestHeader("Accept", "application/vnd.github.raw");
    xhr.setRequestHeader("X-GitHub-Api-Version", "2022-11-28");
    if (token)
        xhr.setRequestHeader("Authorization", "token " + token);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4)
            return;
        var meta = { status: xhr.status };
        if (xhr.status >= 200 && xhr.status < 300)
            cb(null, xhr.responseText, meta);
        else
            cb({ status: xhr.status, message: "HTTP " + xhr.status }, null, meta);
    };
    xhr.send();
    return xhr;
}

function get(path, token, cb)          { return request("GET",    path, token, null, cb); }
function post(path, token, body, cb)   { return request("POST",   path, token, body, cb); }
function patch(path, token, body, cb)  { return request("PATCH",  path, token, body, cb); }
function put(path, token, body, cb)    { return request("PUT",    path, token, body, cb); }
function del(path, token, cb)          { return request("DELETE", path, token, null, cb); }

// ── OAuth Device Authorization Flow ───────────────────────────────────
// Requires a GitHub OAuth App with "Device Flow" enabled. Only the public
// client_id is needed (no client secret), which is why the flow is safe on
// a mobile device.

function _form(url, params, cb) {
    var query = [];
    for (var k in params)
        query.push(encodeURIComponent(k) + "=" + encodeURIComponent(params[k]));
    var xhr = new XMLHttpRequest();
    xhr.open("POST", url + "?" + query.join("&"));
    xhr.setRequestHeader("Accept", "application/json");
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4)
            return;
        var data = null;
        try { data = JSON.parse(xhr.responseText); } catch (e) {}
        if (xhr.status >= 200 && xhr.status < 300 && data)
            cb(null, data);
        else
            cb({ status: xhr.status, message: (data && data.error) ? data.error : ("HTTP " + xhr.status), data: data }, null);
    };
    xhr.send();
    return xhr;
}

// Step 1: request a device + user code.
// cb(err, { device_code, user_code, verification_uri, expires_in, interval })
function requestDeviceCode(clientId, scope, cb) {
    return _form(WEB + "/login/device/code", { client_id: clientId, scope: scope }, cb);
}

// Step 2 (polled): exchange the device code for an access token.
// On success data.access_token is set; while waiting data.error is
// "authorization_pending" or "slow_down".
function pollAccessToken(clientId, deviceCode, cb) {
    return _form(WEB + "/login/oauth/access_token", {
        client_id: clientId,
        device_code: deviceCode,
        grant_type: "urn:ietf:params:oauth:grant-type:device_code"
    }, function(err, data) {
        // The token endpoint returns HTTP 200 even for pending states.
        cb(null, data || (err ? err.data : null));
    });
}
