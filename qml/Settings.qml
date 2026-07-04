/*
    RooThub - persistent settings & session (file-based singleton)
    Copyright (C) 2026 RootGPT - GPL-3.0

    Holds the GitHub session (token + identity) and app preferences in
    dconf via Nemo.Configuration, so state survives restarts. Imported as
    `import ".."` / `import "."` and used as `Settings.token`, etc.
*/
pragma Singleton
import QtQuick 2.0
import Nemo.Configuration 1.0

QtObject {
    id: settings

    // ── Raw dconf-backed values ──────────────────────────────────────
    property ConfigurationValue tokenConf:  ConfigurationValue { key: "/apps/harbour-roothub/token";      defaultValue: "" }
    property ConfigurationValue loginConf:  ConfigurationValue { key: "/apps/harbour-roothub/login";      defaultValue: "" }
    property ConfigurationValue nameConf:   ConfigurationValue { key: "/apps/harbour-roothub/name";       defaultValue: "" }
    property ConfigurationValue avatarConf: ConfigurationValue { key: "/apps/harbour-roothub/avatar";     defaultValue: "" }
    property ConfigurationValue clientConf: ConfigurationValue { key: "/apps/harbour-roothub/client_id";  defaultValue: "" }
    property ConfigurationValue neonConf:   ConfigurationValue { key: "/apps/harbour-roothub/neon_theme"; defaultValue: true }

    // ── Reactive convenience aliases ─────────────────────────────────
    property string token:     tokenConf.value
    property string login:     loginConf.value
    property string userName:  nameConf.value
    property string avatarUrl: avatarConf.value
    property string clientId:  clientConf.value
    property bool   neonTheme: neonConf.value

    readonly property bool authenticated: token.length > 0

    // ── Family "neon blue" accents (shared with RooTelegram/RooT*) ───
    readonly property color accent:    "#00e5ff"
    readonly property color accentDim: "#00b4d8"
    readonly property color accentSoft:"#7de8ff"

    // GitHub issue/PR state colours
    readonly property color openColor:   "#3fb950"
    readonly property color closedColor: "#f85149"
    readonly property color mergedColor: "#a371f7"

    function saveSession(tok, lg, nm, av) {
        tokenConf.value  = tok;
        loginConf.value  = lg;
        nameConf.value   = nm;
        avatarConf.value = av;
    }

    function logout() {
        tokenConf.value  = "";
        loginConf.value  = "";
        nameConf.value   = "";
        avatarConf.value = "";
    }

    function setNeon(on)      { neonConf.value = on; }
    function setClientId(id)  { clientConf.value = id; }
}
