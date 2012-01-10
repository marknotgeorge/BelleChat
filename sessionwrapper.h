#ifndef SESSIONWRAPPER_H
#define SESSIONWRAPPER_H

#include <QString>
#include <IrcSession>
#include <QStringList>
#include <IrcMessage>
#include "connectionsettings.h"



class Session : public IrcSession
{
    Q_OBJECT

public:
    explicit Session(QObject *parent = 0);



signals:
    void outputString(QString channel, QString output);
    void newNamesList(QString channel, QStringList nameList);
    void newChannelList(QStringList channelList);
    void channelJoined(QString channel);

public slots:
    void onConnected();
    Q_INVOKABLE void onMessageReceived(IrcMessage *message);
    Q_INVOKABLE void onInputReceived(QString channel, QString input);
    Q_INVOKABLE void onRefreshNames(QString channel);
    Q_INVOKABLE void updateConnection();
    void onPassword(QString *password);
    Q_INVOKABLE void joinChannel(QString channel);
    Q_INVOKABLE void partChannel(QString channel);
    Q_INVOKABLE bool sessionConnected();

private:
    QStringList nicknameList;
    QString password;


    // Command parsing instructions...
private:
    static IrcCommand* parseAway(const QString& channel, const QStringList& params);
    static IrcCommand* parseInvite(const QString& channel, const QStringList& params);
    static IrcCommand* parseJoin(const QString& channel, const QStringList& params);
    static IrcCommand* parseKick(const QString& channel, const QStringList& params);
    static IrcCommand* parseMe(const QString& channel, const QStringList& params);
    static IrcCommand* parseMode(const QString& channel, const QStringList& params);
    static IrcCommand* parseNames(const QString& channel, const QStringList& params);
    static IrcCommand* parseNick(const QString& channel, const QStringList& params);
    static IrcCommand* parseNotice(const QString& channel, const QStringList& params);
    static IrcCommand* parsePart(const QString& channel, const QStringList& params);
    static IrcCommand* parsePing(const QString& channel, const QStringList& params);
    static IrcCommand* parseQuit(const QString& channel, const QStringList& params);
    static IrcCommand* parseQuote(const QString& channel, const QStringList& params);
    static IrcCommand* parseTime(const QString& channel, const QStringList& params);
    static IrcCommand* parseTopic(const QString& channel, const QStringList& params);
    static IrcCommand* parseVersion(const QString& channel, const QStringList& params);
    static IrcCommand* parseWhois(const QString& channel, const QStringList& params);
    static IrcCommand* parseWhowas(const QString& channel, const QStringList& params);

    // Message Handling functions...
protected:
    void handleInviteMessage(IrcInviteMessage* message);
    void handleJoinMessage(IrcJoinMessage* message);
    void handleKickMessage(IrcKickMessage* message);
    void handleModeMessage(IrcModeMessage* message);
    void handleNickMessage(IrcNickMessage* message);
    void handleNoticeMessage(IrcNoticeMessage* message);
    void handleNumericMessage(IrcNumericMessage* message);
    void handlePartMessage(IrcPartMessage* message);
    void handlePongMessage(IrcPongMessage* message);
    void handlePrivateMessage(IrcPrivateMessage* message);
    void handleQuitMessage(IrcQuitMessage* message);
    void handleTopicMessage(IrcTopicMessage* message);
    void handleUnknownMessage(IrcMessage* message);

    QString prettyUser(const IrcSender& sender);
    QString prettyUser(const QString& user);
    QString colorize(const QString& str, const QString& colourName);
    QString formatPingReply(const IrcSender& sender, const QString& arg);

};


#endif // SESSIONWRAPPER_H