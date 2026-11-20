/*
    RooThub - in-app file downloads.
    Copyright (C) 2026 RootGPT - GPL-3.0
*/
#include "downloader.h"

#include <QDir>
#include <QFileInfo>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QStandardPaths>

Downloader::Downloader(QObject *parent)
    : QObject(parent)
    , m_nam(new QNetworkAccessManager(this))
{
}

QString Downloader::downloadDir() const
{
    QString dir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    if (dir.isEmpty())
        dir = QDir::homePath() + QStringLiteral("/Downloads");
    QDir().mkpath(dir);
    return dir;
}

QString Downloader::uniquePath(const QString &name) const
{
    const QString dir = downloadDir();
    QString path = dir + QLatin1Char('/') + name;
    if (!QFile::exists(path) && !QFile::exists(path + QStringLiteral(".part")))
        return path;
    // name.rpm -> name(1).rpm, name.tar.gz -> name(1).tar.gz
    const bool tgz = name.endsWith(QStringLiteral(".tar.gz"));
    const int dot = tgz ? name.size() - 7 : name.lastIndexOf(QLatin1Char('.'));
    const QString base = dot > 0 ? name.left(dot) : name;
    const QString ext = dot > 0 ? name.mid(dot) : QString();
    for (int i = 1; i < 1000; ++i) {
        path = dir + QLatin1Char('/') + base + QStringLiteral("(%1)").arg(i) + ext;
        if (!QFile::exists(path) && !QFile::exists(path + QStringLiteral(".part")))
            return path;
    }
    return path;
}

void Downloader::start(const QString &url, const QString &fileName)
{
    const QUrl u(url);
    if (!u.isValid() || (u.scheme() != QLatin1String("https") && u.scheme() != QLatin1String("http")))
        return;
    QString name = fileName.isEmpty() ? u.fileName() : fileName;
    name.replace(QLatin1Char('/'), QLatin1Char('_'));
    if (name.isEmpty() || name.startsWith(QLatin1Char('.')))
        name = QStringLiteral("download") + name;
    m_queue.append(qMakePair(u, name));
    if (!active())
        next();
    else
        emit stateChanged();
}

void Downloader::next()
{
    if (m_queue.isEmpty()) {
        m_name.clear();
        emit stateChanged();
        return;
    }
    const QPair<QUrl, QString> job = m_queue.takeFirst();
    m_name = QFileInfo(uniquePath(job.second)).fileName();
    m_path = downloadDir() + QLatin1Char('/') + m_name;
    m_received = 0;
    m_total = 0;
    m_cancelled = false;

    m_file.setFileName(m_path + QStringLiteral(".part"));
    if (!m_file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        emit failed(m_name, m_file.errorString());
        next();
        return;
    }

    QNetworkRequest req(job.first);
    // GitHub sends assets through a redirect to its storage host.
    req.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);
    req.setRawHeader("User-Agent", "RooThub (Sailfish OS)");
    req.setRawHeader("Accept", "application/octet-stream");
    m_reply = m_nam->get(req);
    connect(m_reply.data(), &QNetworkReply::readyRead, this, &Downloader::onReadyRead);
    connect(m_reply.data(), &QNetworkReply::downloadProgress, this, &Downloader::onProgress);
    connect(m_reply.data(), &QNetworkReply::finished, this, &Downloader::onFinished);
    emit stateChanged();
    emit progressChanged();
}

void Downloader::onReadyRead()
{
    if (m_reply)
        m_file.write(m_reply->readAll());
}

void Downloader::onProgress(qint64 received, qint64 total)
{
    m_received = received;
    m_total = total;
    emit progressChanged();
}

void Downloader::onFinished()
{
    QNetworkReply *reply = m_reply.data();
    if (!reply)
        return;
    onReadyRead();
    m_file.close();

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (m_cancelled) {
        m_file.remove();
    } else if (reply->error() != QNetworkReply::NoError || status >= 400) {
        m_file.remove();
        emit failed(m_name, reply->error() != QNetworkReply::NoError
                    ? reply->errorString() : QStringLiteral("HTTP %1").arg(status));
    } else if (!m_file.rename(m_path)) {
        emit failed(m_name, m_file.errorString());
    } else {
        emit finished(m_path, m_name);
    }
    reply->deleteLater();
    m_reply.clear();
    next();
}

void Downloader::cancel()
{
    m_queue.clear();
    if (m_reply) {
        m_cancelled = true;
        m_reply->abort();
    }
}
