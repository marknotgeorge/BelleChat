#ifndef SESSIONWRAPPER_H
#define SESSIONWRAPPER_H

#include <QString>
#include <IrcSession>
#include <QStringList>
#include <IrcMessage>
#include "connectionsettings.h"
#include <QList>
#include <QDeclarativeContext>
#include "whoisitem.h"
#include "channellistitem.h"
#include "palette.h"
#include <QTcpServer>
#include <QTcpSocket>




class Session : public IrcSession
{
    Q_OBJECT
    Q_PROPERTY(QString currentChannel READ currentChannel WRITE setCurrentChannel NOTIFY currentChannelChanged)
    Q_PROPERTY(QString lastChannel READ lastChannel WRITE setLastChannel NOTIFY lastChannelChanged)
    Q_PROPERTY(int userCount READ userCount NOTIFY userCountChanged)
    Q_PROPERTY(bool isAway READ isAway WRITE setIsAway NOTIFY isAwayChanged)

public:
    explicit Session(QObject *parent = 0);
    QDeclarativeContext *context;


private:
    QString colorCodeToName(int code, const QString &defaultColor);
    QStringList parseColours(QString noFlag);
    QString formatFragment(QString source);
    QString formatString(QString source);
signals:
    void outputString(QString channel, QString output);
    void newNamesList(QString channel, int count);
    void newChannelList(int numberOfChannels);
    void channelJoined(QString channel);
    void whoIsReceived(WhoIsItem *user);
    void currentChannelChanged(QString newCurrentChannel);
    void lastChannelChanged(QString newLastChannel);
    void userCountChanged(int newUserCount);
    void queryReceived(QString sender, QString message);
    void isAwayChanged(bool newIsAway);
    void channelRequiresKey(QString channel);
    void displayError(QString errorString);

public slots:
    void onConnected();
    Q_INVOKABLE void onMessageReceived(IrcMessage *message);
    Q_INVOKABLE void onInputReceived(QString channel, QString input);
    Q_INVOKABLE void onRefreshNames(QString channel);
    Q_INVOKABLE void updateConnection();
    void onPassword(QString *password);
    Q_INVOKABLE void joinChannel(QString channel);
    Q_INVOKABLE void joinProtectedChannel(QString channel, QString key);
    Q_INVOKABLE void partChannel(QString channel);
    Q_INVOKABLE bool sessionConnected();
    Q_INVOKABLE void getChannelList(QString channel);
    Q_INVOKABLE void getNicknames (QString channel);
    Q_INVOKABLE void whoIs(QString user);
    Q_INVOKABLE void kick(QString channel, QString user, QString reason);
    Q_INVOKABLE QString currentChannel();
    Q_INVOKABLE void setCurrentChannel(QString newCurrentChannel);
    Q_INVOKABLE QString lastChannel();
    Q_INVOKABLE void setLastChannel(QString newLastChannel);
    Q_INVOKABLE void quit(QString quitMessage);
    Q_INVOKABLE int userCount();
    Q_INVOKABLE QString getRealname(QString user);
    Q_INVOKABLE void sendNames(QString channel);
    Q_INVOKABLE QString removeMode(QString user);
    Q_INVOKABLE bool isAway();
    Q_INVOKABLE void markAway(bool newIsAway);
    Q_INVOKABLE void setIsAway(bool newIsAway);
    Q_INVOKABLE bool isValidChannelName(QString channel);
    Q_INVOKABLE void autoJoinChannels();
    Q_INVOKABLE void sendCtcpRequest(QString target, QString request);
    Q_INVOKABLE WhoIsItem* getWhoIs(QString user);
    Q_INVOKABLE QString getTimeString();
    Q_INVOKABLE void open();
    Q_INVOKABLE void sendNickServPassword(QString password);
    Q_INVOKABLE void pressReturn();

    void onIdentNewConnection();
    void onIdentReadyRead();



private:
    QHash<QString, QStringList> nicknames;
    QHash<QString, QObject *>whoisHash;
    QString password;
    QList<QObject *> channelList;
    QString openUserList;
    QString m_currentChannel;
    QString m_lastChannel;
    bool m_isAway;
    QStringList nicknameList;
    bool newNames;
    Palette colourPalette;
    QTcpServer identServer;
    QTcpSocket *identSocket;


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

    static bool currentListItemLessThanChannel(QObject *left, QObject *right);

    static bool caseInsensitiveLessThan(const QString &s1, const QString &s2);



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
    void handleRequestMessage(IrcPrivateMessage *message);
    void handleNAMREPLY(IrcMessage* message);
    void processWhoIs(IrcNumericMessage* message);

    QString prettyUser(const IrcSender& sender);
    QString prettyUser(const QString& user);
    QString colorize(const QString& str, const QString& colourName);
    QString formatPingReply(const IrcSender& sender, const QString& arg);
    QString getTimestamp();
    QString formatInput(const QString& inputString);
    bool removeUser(QString user, QString channel);






};


#endif // SESSIONWRAPPER_H
