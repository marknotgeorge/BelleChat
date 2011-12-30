#include "sessionwrapper.h"
#include <IrcCommand>
#include <IrcMessage>
#include <IrcSession>
#include <QStringList>
#include <Irc>
#include <IrcUtil>
#include <QDateTime>
#include <QColor>


Session::Session(QObject *parent) :
    IrcSession(parent)
{
    //connect(this, SIGNAL(connected()), this, SLOT(onConnected()));
    connect(this, SIGNAL(messageReceived(IrcMessage*)), this, SLOT(onMessageReceived(IrcMessage*)));
    //connect(parent, SIGNAL(sendInputString(QString, QString)), this, SLOT(onInputReceived(QString, QString)));
    //connect(parent, SIGNAL(refreshNames(QString)), this, SLOT(onRefreshNames(QString)));
    connect(this, SIGNAL(password(QString*)), this, SLOT(onPassword(QString*)));
    //connect(parent, SIGNAL(updateSettings(Connection*)), this, SLOT(onUpdateConnection(Connection*)));
}

void Session::onConnected()
{

}


void Session::onInputReceived(QString channel,QString input)
{
    IrcCommand *command = 0;

    // qDebug() << "Channel: " << channel << "\n"<< "String: " << input;

    if(input[0] == '/')
    {
        // parse the input.
        typedef IrcCommand*(*ParseFunc)(const QString&, const QStringList&);

        static QHash<QString, ParseFunc> parseFunctions;
        if (parseFunctions.isEmpty())
        {
            parseFunctions.insert("AWAY", &Session::parseAway);
            parseFunctions.insert("INVITE", &Session::parseInvite);
            parseFunctions.insert("JOIN", &Session::parseJoin);
            parseFunctions.insert("KICK", &Session::parseKick);
            parseFunctions.insert("ME", &Session::parseMe);
            parseFunctions.insert("MODE", &Session::parseMode);
            parseFunctions.insert("NAMES", &Session::parseNames);
            parseFunctions.insert("NICK", &Session::parseNick);
            parseFunctions.insert("NOTICE", &Session::parseNotice);
            parseFunctions.insert("PART", &Session::parsePart);
            parseFunctions.insert("PING", &Session::parsePing);
            parseFunctions.insert("QUIT", &Session::parseQuit);
            parseFunctions.insert("QUOTE", &Session::parseQuote);
            parseFunctions.insert("TIME", &Session::parseTime);
            parseFunctions.insert("TOPIC", &Session::parseTopic);
            parseFunctions.insert("VERSION", &Session::parseVersion);
            parseFunctions.insert("WHOIS", &Session::parseWhois);
            parseFunctions.insert("WHOWAS", &Session::parseWhowas);
        }

        const QStringList words = input.mid(1).split(" ", QString::SkipEmptyParts);
        const QString commandString = words.value(0).toUpper();
        ParseFunc parseFunc = parseFunctions.value(commandString);
        if (parseFunc)
        {
            command = parseFunc(channel, words.mid(1));
            if (!command)
            {
                emit outputString(this->host(), tr("Unable to understand command!"));
                return;
            }
        }
    }
    else
    {
        command = IrcCommand::createMessage(channel, input);
    }
    if (command->type() == IrcCommand::Message || command->type() == IrcCommand::CtcpAction)
    {
        IrcMessage* msg = IrcMessage::fromCommand(this->nickName(), command);
        emit messageReceived(msg);
        delete msg;
    }
    if (command)
        sendCommand(command);
}

void Session::onRefreshNames(QString channel)
{
    // send a names command to the server...
    IrcCommand *command = IrcCommand::createNames(channel);
    this->sendCommand(command);
}

void Session::updateConnection()
{
    ConnectionSettings settings;
    setHost(settings.host());
    setPort(settings.port());
    setNickName(settings.nickname());
    setUserName(settings.username());
    setRealName(settings.realname());
}



void Session::onMessageReceived(IrcMessage *message)
{
    switch (message->type())
    {
    case IrcMessage::Invite:
        handleInviteMessage(static_cast<IrcInviteMessage*>(message));
        break;
    case IrcMessage::Join:
        handleJoinMessage(static_cast<IrcJoinMessage*>(message));
        break;
    case IrcMessage::Kick:
        handleKickMessage(static_cast<IrcKickMessage*>(message));
        break;
    case IrcMessage::Mode:
        handleModeMessage(static_cast<IrcModeMessage*>(message));
        break;
    case IrcMessage::Nick:
        handleNickMessage(static_cast<IrcNickMessage*>(message));
        break;
    case IrcMessage::Notice:
        handleNoticeMessage(static_cast<IrcNoticeMessage*>(message));
        break;
    case IrcMessage::Numeric:
        handleNumericMessage(static_cast<IrcNumericMessage*>(message));
        break;
    case IrcMessage::Part:
        handlePartMessage(static_cast<IrcPartMessage*>(message));
        break;
    case IrcMessage::Pong:
        handlePongMessage(static_cast<IrcPongMessage*>(message));
        break;
    case IrcMessage::Private:
        handlePrivateMessage(static_cast<IrcPrivateMessage*>(message));
        break;
    case IrcMessage::Quit:
        handleQuitMessage(static_cast<IrcQuitMessage*>(message));
        break;
    case IrcMessage::Topic:
        handleTopicMessage(static_cast<IrcTopicMessage*>(message));
        break;
    case IrcMessage::Unknown:
        handleUnknownMessage(static_cast<IrcMessage*>(message));
        break;
    default:
        break;
    }
}

void Session::handleInviteMessage(IrcInviteMessage *message)
{
    const QString sender = prettyUser(message->sender());
    QString output = colorize(tr("*** %1 invited to %3").arg(sender, message->channel()), "green");
    emit outputString(this->host(), output);
}

void Session::handleJoinMessage(IrcJoinMessage *message)
{
    const QString sender = prettyUser(message->sender());

    QString joinString =  colorize(tr("*** %1 joined %2").arg(sender, message->channel()),"green");
    emit outputString(message->channel(), joinString);

}

void Session::handleKickMessage(IrcKickMessage *message)
{
    const QString sender = prettyUser(message->sender());
    const QString user = prettyUser(message->user());
    if (!message->reason().isEmpty())
    {
        QString output = colorize(tr("*** %1 kicked %2 (%3)").arg(sender, user, message->reason()), "red");
        emit outputString(message->channel(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 kicked %2").arg(sender, user), "red");
        emit outputString(message->channel(), output);
    }
}

void Session::handleModeMessage(IrcModeMessage *message)
{
    const QString sender = prettyUser(message->sender());
    QString output = colorize(tr("*** %1 sets mode %2 %3").arg(sender, message->mode(), message->argument()), "green");
    emit outputString(this->host(), output);
}

void Session::handleNickMessage(IrcNickMessage *message)
{
    const QString sender = prettyUser(message->sender());
    const QString nick = prettyUser(message->nick());
    QString output = colorize(tr("*** %1 changed nick to %2").arg(sender, nick), "red");
    emit outputString(this->host(), output);

}

void Session::handleNoticeMessage(IrcNoticeMessage *message)
{
    if (message->isReply())
    {
        const QStringList params = message->message().split(" ", QString::SkipEmptyParts);
        const QString cmd = params.value(0);
        const QString arg = params.value(1);
        if (cmd.toUpper() == "PING")
            emit outputString(this->host(), formatPingReply(message->sender(), arg));
        else if (cmd.toUpper() == "TIME")
            emit outputString(this->host(), tr("! %1 time is %2").arg(prettyUser(message->sender()), QStringList(params.mid(1)).join(" ")));
        else if (cmd.toUpper() == "VERSION")
            emit outputString(this->host(), tr("! %1 version is %2").arg(prettyUser(message->sender()), QStringList(params.mid(1)).join(" ")));
    }
    else
    {
        const QString sender = prettyUser(message->sender());
        const QString msg = IrcUtil::messageToHtml(message->message());
        emit(outputString(this->host(), tr("[%1] %2").arg(sender, msg)));
    }
}


// Definitions used in handleNumericMessage...
#define P_(x) message->parameters().value(x)
#define MID_(x) QStringList(message->parameters().mid(x)).join(" ")

void Session::handleNumericMessage(IrcNumericMessage *message)
{
    QTime myTime;
    QDateTime myDateTime;
    QString channel;
    QString msg;

    if (message->code() < 300)
        emit outputString(this->host(), tr("[INFO] %1").arg(IrcUtil::messageToHtml(MID_(1))));
    if (QByteArray(Irc::toString(message->code())).startsWith("ERR_"))
        emit outputString(this->host(), tr("[ERROR] %1").arg(IrcUtil::messageToHtml(MID_(1))));

    switch (message->code())
    {
    case Irc::RPL_MOTDSTART:
    case Irc::RPL_MOTD:
        emit outputString(this->host(), tr("[MOTD] %1").arg(IrcUtil::messageToHtml(MID_(1))));
        break;
    case Irc::RPL_AWAY:

        emit outputString(this->host(), colorize(tr("*** %1 is away (%2)").arg(P_(1), MID_(2)), "green"));
        break;
    case Irc::RPL_ENDOFWHOIS:
        emit outputString(this->host(), QString());
        break;
    case Irc::RPL_WHOISOPERATOR:
    case Irc::RPL_WHOISHELPOP: // "is available for help"
    case Irc::RPL_WHOISSPECIAL: // "is identified to services"
    case Irc::RPL_WHOISSECURE: // nick is using a secure connection
    case Irc::RPL_WHOISHOST: // nick is connecting from <...>
        emit outputString(this->host(), colorize(tr("*** %1").arg(MID_(1)), "green"));
        break;
    case Irc::RPL_WHOISUSER:
        emit outputString(this->host(), colorize(tr("*** %1 is %2@%3 (%4)")
                                   .arg(P_(1), P_(2), P_(3),
                                        IrcUtil::messageToHtml(MID_(5))), "green"));
        break;
    case Irc::RPL_WHOISSERVER:
        emit outputString(this->host(), colorize(tr("*** %1 is online via %2 (%3)")
                                   .arg(P_(1), P_(2), P_(3)), "green"));
        break;
    case Irc::RPL_WHOISACCOUNT: // nick user is logged in as
        emit outputString(this->host(), colorize(tr("*** %1 %3 %2").arg(P_(1), P_(2), P_(3)), "green"));
        break;
    case Irc::RPL_WHOWASUSER:
        emit outputString(this->host(), colorize(tr("*** %1 was %2@%3 %4 %5")
                                   .arg(P_(1), P_(2), P_(3), P_(4), P_(5)), "green"));
        break;
    case Irc::RPL_WHOISIDLE:
        myDateTime = QDateTime::fromTime_t(P_(3).toInt());
        myTime = QTime().addSecs(P_(2).toInt());
        emit outputString(this->host(), colorize(tr("*** %1 has been online since %2 (idle for %3)")
                                   .arg(P_(1), myDateTime.toString(), myTime.toString()), "green"));

        break;
    case Irc::RPL_WHOISCHANNELS:
        emit outputString(this->host(), colorize(tr("*** %1 is on channels %2").arg(P_(1), P_(2)), "green"));
        break;
    case Irc::RPL_CHANNELMODEIS:
        emit outputString(this->host(), colorize(tr("*** %1 mode is %2").arg(P_(1), P_(2)), "green"));
        break;
    case Irc::RPL_CHANNEL_URL:
        emit outputString(this->host(), colorize(tr("*** %1 url is %2")
                                   .arg(P_(1), IrcUtil::messageToHtml(P_(2))), "green"));
        break;
    case Irc::RPL_CREATIONTIME:
        myDateTime = QDateTime::fromTime_t(P_(2).toInt());
        emit outputString(this->host(), colorize(tr("*** %1 was created %2")
                                   .arg(P_(1), myDateTime.toString()), "green"));
        break;
    case Irc::RPL_NOTOPIC:
        emit outputString(P_(1), colorize(tr("*** %1 has no topic set").arg(P_(1)), "green"));
        break;
    case Irc::RPL_TOPIC:
        emit outputString(P_(1), colorize(tr("*** %1 topic is \"%2\"")
                                   .arg(P_(1), IrcUtil::messageToHtml(P_(2))), "green"));
        break;
    case Irc::RPL_TOPICWHOTIME:
        myDateTime = QDateTime::fromTime_t(P_(3).toInt());
        emit outputString(P_(1), colorize(tr("*** %1 topic was set %2 by %3")
                                   .arg(P_(1), myDateTime.toString(), P_(2)), "green"));
        break;
    case Irc::RPL_INVITING:
        emit outputString(this->host(), colorize(tr("*** inviting %1 to %2").arg(P_(1), P_(2)), "green"));
        break;
    case Irc::RPL_VERSION:
        emit outputString(this-> host(), colorize(tr("*** %1 version is %2")
                                   .arg(message->sender().name(), P_(1)),"green"));
        break;
    case Irc::RPL_TIME:
        emit outputString(this->host(), colorize(tr("*** %1 time is %2").arg(P_(1), P_(2)),"green"));
        break;
    case Irc::RPL_UNAWAY:
    case Irc::RPL_NOWAWAY:
        emit outputString(this->host(), colorize(tr("*** %1").arg(P_(1)), "green"));
        break;
    case Irc::RPL_NAMREPLY:
        foreach (const QString& name, P_(3).split(" ", QString::SkipEmptyParts))
            nicknameList.append(name);
        emit outputString(this->host(), QString());
        break;

    case Irc::RPL_ENDOFNAMES:
        channel = P_(1);
        msg = colorize(tr("*** %1 has %2 user(s)").arg(channel).arg(nicknameList.count()), "green");
        emit newNamesList(channel, nicknameList);
        emit outputString(this->host(), msg);
        nicknameList.clear();
        break;

    }

}

void Session::handlePartMessage(IrcPartMessage *message)
{
    const QString sender = prettyUser(message->sender());
    if (!message->reason().isEmpty())
    {
        QString output = colorize(tr("*** %1 left %2 (%3)")
                                  .arg(sender, message->channel(),
                                       IrcUtil::messageToHtml(message->reason())),"green");
        emit outputString(message->channel(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 left %2")
                                  .arg(sender, message->channel()),"green");
        emit outputString(message->channel(), output);
    }
}

void Session::handlePongMessage(IrcPongMessage *message)
{
    emit outputString(this->host(), formatPingReply(message->sender(), message->argument()));
}

void Session::handlePrivateMessage(IrcPrivateMessage *message)
{
    const QString sender = prettyUser(message->sender());
    const QString msg = IrcUtil::messageToHtml(message->message());
    if (message->isAction())
        emit outputString(message->target(), colorize(tr("*** %1 %2").arg(sender, msg), "purple"));
    else if (message->isRequest())
        emit outputString(message->target(), colorize(tr("*** %1 requested %2")
                                   .arg(sender,
                                        msg.split(" ").value(0).toLower()), "green"));
    else
        emit outputString(message->target(), tr("&lt;%1&gt; %2").arg(sender, msg));
}

void Session::handleQuitMessage(IrcQuitMessage *message)
{
    const QString sender = prettyUser(message->sender());
    if (!message->reason().isEmpty())
    {
        QString output = colorize(tr("*** %1 has quit (%2)")
                                  .arg(sender,
                                       IrcUtil::messageToHtml(message->reason())), "blue");

        emit outputString(this->host(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 has quit")
                                  .arg(sender), "blue");

        emit outputString(this->host(), output);
    }
}

void Session::handleTopicMessage(IrcTopicMessage *message)
{
    const QString sender = prettyUser(message->sender());
    const QString topic = IrcUtil::messageToHtml(message->topic());
    QString output = colorize(tr("*** %1 sets topic \"%2\" on %3")
                              .arg(sender, topic, message->channel()), "green");
    emit outputString(message->channel(), output);
}

void Session::handleUnknownMessage(IrcMessage *message)
{
    const QString sender = prettyUser(message->sender());
    emit outputString(this->host(), tr("? %1 %2 %3")
                      .arg(sender, message->command(), message->parameters().join(" ")));
}

QString Session::prettyUser(const IrcSender& sender)
{
    const QString name = sender.name();
    if (sender.isValid())
        return colorize(name, "red");
    return name;
}

QString Session::prettyUser(const QString& user)
{
    return prettyUser(IrcSender(user));
}

QString Session::colorize(const QString& str, const QString& colourName)
{
    QColor color;
    color.setNamedColor(colourName);
    return QString("<span style='color:%1'>%2</span>").arg(color.name()).arg(str);
}

QString Session::formatPingReply(const IrcSender& sender, const QString& arg)
{
    bool ok;
    int seconds = arg.toInt(&ok);
    if (ok)
    {
        QDateTime time = QDateTime::fromTime_t(seconds);
        QString result = QString::number(time.secsTo(QDateTime::currentDateTime()));
        return tr("*** %1 replied in %2s").arg(prettyUser(sender), result);
    }
    return QString();
}

IrcCommand* Session::parseAway(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    return IrcCommand::createAway(params.value(0));
}

IrcCommand* Session::parseInvite(const QString& channel, const QStringList& params)
{
    if (params.count() == 1)
        return IrcCommand::createInvite(params.at(0), channel);
    return 0;
}

IrcCommand* Session::parseJoin(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.count() == 1 || params.count() == 2)
        return IrcCommand::createJoin(params.at(0), params.value(1));
    return 0;
}

IrcCommand* Session::parseKick(const QString& channel, const QStringList& params)
{
    if (params.count() >= 1)
        return IrcCommand::createKick(channel, params.at(0), QStringList(params.mid(1)).join(" "));
    return 0;
}

IrcCommand* Session::parseMe(const QString& channel, const QStringList& params)
{
    if (!params.isEmpty())
        return IrcCommand::createCtcpAction(channel, params.join(" "));
    return 0;
}

IrcCommand* Session::parseMode(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.count() >= 2 && params.count() <= 4)
        return IrcCommand::createMode(params.at(0), params.at(1), params.value(2));
    return 0;
}

IrcCommand* Session::parseNames(const QString& channel, const QStringList& params)
{
    if (params.isEmpty())
        return IrcCommand::createNames(channel);
    return 0;
}

IrcCommand* Session::parseNick(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.count() == 1)
        return IrcCommand::createNick(params.at(0));
    return 0;
}

IrcCommand* Session::parseNotice(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.count() >= 2)
        return IrcCommand::createNotice(params.at(0), QStringList(params.mid(1)).join(" "));
    return 0;
}

IrcCommand* Session::parsePart(const QString& channel, const QStringList& params)
{
    return IrcCommand::createPart(channel, params.join(" "));
}

IrcCommand* Session::parsePing(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    QString time = QString::number(QDateTime::currentDateTime().toTime_t());
    if (params.isEmpty())
        return IrcCommand::createQuote(QStringList() << "PING" << time);
    return IrcCommand::createCtcpRequest(params.at(0), "PING " + time);
}

IrcCommand* Session::parseQuit(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    return IrcCommand::createQuit(params.join(" "));
}

IrcCommand* Session::parseQuote(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    return IrcCommand::createQuote(params);
}

IrcCommand* Session::parseTime(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.isEmpty())
        return IrcCommand::createQuote(QStringList() << "TIME");
    return IrcCommand::createCtcpRequest(params.at(0), "TIME");
}

IrcCommand* Session::parseTopic(const QString& channel, const QStringList& params)
{
    return IrcCommand::createTopic(channel, params.join(" "));
}

IrcCommand* Session::parseVersion(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.isEmpty())
        return IrcCommand::createQuote(QStringList() << "VERSION");
    return IrcCommand::createCtcpRequest(params.at(0), "VERSION");
}

IrcCommand* Session::parseWhois(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.count() == 1)
        return IrcCommand::createWhois(params.at(0));
    return 0;
}

IrcCommand* Session::parseWhowas(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.count() == 1)
        return IrcCommand::createWhowas(params.at(0));
    return 0;
}

void Session::onPassword(QString *passwd)
{
    ConnectionSettings settings;

    QString pass = settings.password();
    *passwd = pass;
}

void Session::joinChannel(QString channel)
{
    if (!channel.isEmpty())
    {
        IrcCommand *command;
        command = IrcCommand::createJoin(channel);
        sendCommand(command);
    }
}

void Session::partChannel(QString channel)
{
    if (!channel.isEmpty())
    {
        IrcCommand *command;
        command = IrcCommand::createPart(channel, "Screw you guys, I'm going home!");
        sendCommand(command);
    }
}

bool Session::sessionConnected()
{
    return isConnected();
}






