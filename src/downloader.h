/*
    RooThub - in-app file downloads (release assets, source archives).
    Copyright (C) 2026 RootGPT - GPL-3.0

    Files are saved to ~/Downloads (sailjail "Downloads" permission), one
    at a time: further requests wait in a queue. Data goes to "<name>.part"
    and is renamed when complete, so a broken download never looks finished.
*/
#ifndef ROOTHUB_DOWNLOADER_H
#define ROOTHUB_DOWNLOADER_H

#include <QObject>
#include <QFile>
#include <QList>
#include <QPair>
#include <QPointer>
#include <QUrl>

class QNetworkAccessManager;
class QNetworkReply;

class Downloader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY stateChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY stateChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(qint64 received READ received NOTIFY progressChanged)
    Q_PROPERTY(qint64 total READ total NOTIFY progressChanged)
    Q_PROPERTY(int queued READ queued NOTIFY stateChanged)

public:
    explicit Downloader(QObject *parent = nullptr);

    bool active() const { return !m_reply.isNull(); }
    QString fileName() const { return m_name; }
    qreal progress() const { return m_total > 0 ? qreal(m_received) / m_total : -1; }
    qint64 received() const { return m_received; }
    qint64 total() const { return m_total; }
    int queued() const { return m_queue.size(); }

    // Queue a download; fileName may be empty (taken from the URL).
    Q_INVOKABLE void start(const QString &url, const QString &fileName = QString());
    Q_INVOKABLE void cancel();
    Q_INVOKABLE QString downloadDir() const;

signals:
    void stateChanged();
    void progressChanged();
    void finished(const QString &path, const QString &fileName);
    void failed(const QString &fileName, const QString &error);

private slots:
    void onReadyRead();
    void onProgress(qint64 received, qint64 total);
    void onFinished();

private:
    void next();
    QString uniquePath(const QString &name) const;

    QNetworkAccessManager *m_nam;
    QPointer<QNetworkReply> m_reply;
    QFile m_file;
    QString m_name;
    QString m_path;
    qint64 m_received = 0;
    qint64 m_total = 0;
    bool m_cancelled = false;
    QList<QPair<QUrl, QString>> m_queue;
};

#endif
