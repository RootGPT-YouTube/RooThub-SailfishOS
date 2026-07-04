# RooThub - a native GitHub client for Sailfish OS
# Copyright (C) 2026 RootGPT - GPL-3.0
#
# NOTICE:
# Application name defined in TARGET has a corresponding QML filename.
# If TARGET changes, rename the main QML file, the .desktop file, the
# icon files and the .desktop Icon= entry accordingly.

TARGET = harbour-roothub

# Single source of truth for the version. Exposed to QML as the
# `appVersion` context property (see src/harbour-roothub.cpp) and read
# by AboutPage.
RH_APP_VERSION = 0.4.0
VERSION = $$RH_APP_VERSION
DEFINES += APP_VERSION=\\\"$$RH_APP_VERSION\\\"

CONFIG += sailfishapp sailfishapp_i18n c++17

# Translations. SailfishApp auto-loads harbour-roothub-<locale>.qm matching the
# phone language and falls back to the source (English) strings otherwise.
TRANSLATIONS += translations/harbour-roothub-it.ts

SOURCES += src/harbour-roothub.cpp

DISTFILES += \
    qml/harbour-roothub.qml \
    qml/Settings.qml \
    qml/qmldir \
    qml/cover/CoverPage.qml \
    qml/js/GitHubApi.js \
    qml/js/Format.js \
    qml/components/CircuitBackground.qml \
    qml/components/NeonHeader.qml \
    qml/components/NeonButton.qml \
    qml/components/NeonSeparator.qml \
    qml/components/NavItem.qml \
    qml/components/BusyPlaceholder.qml \
    qml/components/Avatar.qml \
    qml/components/StateBadge.qml \
    qml/components/RepoDelegate.qml \
    qml/components/IssueDelegate.qml \
    qml/components/UserDelegate.qml \
    qml/components/NotificationDelegate.qml \
    qml/components/CommentItem.qml \
    qml/components/MarkdownText.qml \
    qml/pages/LoginPage.qml \
    qml/pages/DeviceFlowPage.qml \
    qml/pages/HomePage.qml \
    qml/pages/RepoListPage.qml \
    qml/pages/RepoPage.qml \
    qml/pages/CodePage.qml \
    qml/pages/FilePage.qml \
    qml/pages/EditFilePage.qml \
    qml/pages/IssueListPage.qml \
    qml/pages/IssuePage.qml \
    qml/pages/NewIssuePage.qml \
    qml/pages/PullPage.qml \
    qml/pages/NotificationsPage.qml \
    qml/pages/SearchPage.qml \
    qml/pages/UserPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/AboutPage.qml \
    rpm/harbour-roothub.spec \
    rpm/harbour-roothub.yaml \
    harbour-roothub.desktop

# Bundle the images directory (logo, circuit background, family assets)
images.files = images
images.path = /usr/share/$${TARGET}
INSTALLS += images

# Installed application icons (hicolor)
icon86.files = icons/86x86/harbour-roothub.png
icon86.path = /usr/share/icons/hicolor/86x86/apps
icon108.files = icons/108x108/harbour-roothub.png
icon108.path = /usr/share/icons/hicolor/108x108/apps
icon128.files = icons/128x128/harbour-roothub.png
icon128.path = /usr/share/icons/hicolor/128x128/apps
icon172.files = icons/172x172/harbour-roothub.png
icon172.path = /usr/share/icons/hicolor/172x172/apps
icon256.files = icons/256x256/harbour-roothub.png
icon256.path = /usr/share/icons/hicolor/256x256/apps
INSTALLS += icon86 icon108 icon128 icon172 icon256
