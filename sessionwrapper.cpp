#include <IrcCommand>
#include <IrcMessage>
#include <IrcSession>
#include <QStringList>
#include <Irc>
#include <IrcUtil>
#include <QDateTime>
#include <QColor>
#include "channellistitem.h"
#include "userlistitem.h"
#include <QDeclarativeContext>
#include <QtAlgorithms>
#include "connectionsettings.h"
#include "sessionwrapper.h"


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

bool Session::currentListItemLessThanChannel(QObject *left, QObject *right)
{
    ChannelListItem *leftChannel = (ChannelListItem *)left;
    ChannelListItem *rightChannel = (ChannelListItem *)right;

    return leftChannel->channel().toLower() < rightChannel->channel().toLower();
}

bool Session::userListItemLessThan(QObject *left, QObject *right)
{
    UserListItem *leftItem = (UserListItem *)left;
    UserListItem *rightItem = (UserListItem *)right;

    return leftItem->name().toLower() < rightItem->name().toLower();
}

void Session::onInputReceived(QString channel,QString input)
{
    IrcCommand *command = 0;

    //qDebug() << "Channel: " << channel << "\n"<< "String: " << input;


    // Check to see if the input is a message or a command...
    if(input[0] == '/')
    {
        // Input is a command. Parse and create the IrcCommand
        const QStringList words = input.mid(1).split(" ", QString::SkipEmptyParts);
        const QString commandString = words[0].toUpper();
        const QStringList paramsList = words.mid(1);

        //qDebug() << "commandString: " << commandString;
        //qDebug() << "Parameters: " << paramsList;


        if (commandString == "AWAY")
            command = parseAway(channel, paramsList);
        else if (commandString == "INVITE")
            command = parseInvite(channel, paramsList);
        else if (commandString == "JOIN")
            command = parseJoin(channel, paramsList);
        else if (commandString == "KICK")
            command = parseKick(channel, paramsList);
        else if (commandString == "ME")
            command = parseMe(channel, paramsList);
        else if (commandString == "MODE")
            command = parseMode(channel, paramsList);
        else if (commandString == "NAMES")
            command = parseNames(channel, paramsList);
        else if (commandString == "NICK")
            command = parseNick(channel, paramsList);
        else if (commandString == "NOTICE")
            command = parseNotice(channel, paramsList);
        else if (commandString == "PART")
            command = parsePart(channel, paramsList);
        else if (commandString == "PING")
            command = parsePing(channel, paramsList);
        else if (commandString == "QUIT")
            command = parseQuit(channel, paramsList);
        else if (commandString == "QUOTE")
            command = parseQuote(channel, paramsList);
        else if (commandString == "TIME")
            command = parseTime(channel, paramsList);
        else if (commandString == "TOPIC")
            command = parseTopic(channel, paramsList);
        else if (commandString == "VERSION")
            command = parseVersion(channel, paramsList);
        else if (commandString == "WHOIS")
            command = parseWhois(channel, paramsList);
        else if (commandString == "WHOWAS")
            command = parseWhowas(channel, paramsList);
        if (!command)
        {
            // Output an error message...
            emit outputString(this->host(), tr("Unable to understand command!"));
            return;
        }
    }
    else
    {
        // It's a message. Create a Message IrcCommand...
        command = IrcCommand::createMessage(channel, input);
    }
    if (command->type() == IrcCommand::Message || command->type() == IrcCommand::CtcpAction)
    {
        // If a message or an action, echo the output to the client...
        IrcMessage* msg = IrcMessage::fromCommand(this->nickName(), command);
        emit messageReceived(msg);
        delete msg;
    }

    // Finally send the command...
    if (command)
    {
        //qDebug() << "Sending command " << command->toString();
        sendCommand(command);
    }
}

void Session::onRefreshNames(QString channel)
{
    // send a NAMES command to the server...
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
    IrcSender sender = message->sender();
    const QString prettySender = prettyUser(sender);

    // Check to see if we are the one joining. If we are, signal
    // the UI, so it can open a new tab...
    if (sender.name() == this->nickName())
        emit channelJoined(message->channel());

    // Add user to nickname list

    if (!nicknameHash.contains(sender.name()))
    {
        ConnectionSettings settings;

        UserListItem *newUser = new UserListItem();
        newUser->setName(sender.name());
        if (settings.autoFetchWhois())
            whoIs(sender.name());
        nicknameList.append(newUser);
        nicknameHash.insert(sender.name(), newUser);
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
    }


    QString joinString =  colorize(tr("*** %1 joined %2").arg(prettySender, message->channel()),"green");
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
    ChannelListItem *clitem;
    UserListItem *whoisUser;
    QString topic;
    int index;
    bool newNames = true;
    ConnectionSettings settings;


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
        // qDebug() << message->parameters();
        // Set the complete flag. This is used by the UI to allow the user to
        // open the UserDetails page.
        whoisUser = (UserListItem *)nicknameHash.value(P_(1));
        if (whoisUser)
            whoisUser->setDataComplete(true);
        //emit outputString(this->host(), QString());
        emit whoIsReceived(whoisUser->name());
        // Update the UserModel
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
        break;
    case Irc::RPL_WHOISOPERATOR:
    case Irc::RPL_WHOISHELPOP: // "is available for help"
    case Irc::RPL_WHOISSPECIAL: // "is identified to services"
    case Irc::RPL_WHOISSECURE: // nick is using a secure connection
        //qDebug() << message->parameters();
        //emit outputString(this->host(), colorize(tr("*** %1").arg(MID_(1)), "green"));
        break;
    case Irc::RPL_WHOISHOST: // nick is connecting from <...>

        //qDebug() << "RPL_WHOISHOST" << message->parameters();
        //emit outputString(this->host(), colorize(tr("*** %1").arg(MID_(1)), "green"));
        break;
    case Irc::RPL_WHOISUSER:
        //qDebug() << message->parameters();
        whoisUser = (UserListItem *)nicknameHash.value(P_(1), 0);
        if (whoisUser)
        {
            whoisUser->setUser(QString("%1@%2").arg(P_(2),P_(3)));
            whoisUser->setRealname(P_(5));
        }
        //emit outputString(this->host(), colorize(tr("*** %1 is %2@%3 (%4)")
        //                                         .arg(P_(1), P_(2), P_(3),
        //                                              IrcUtil::messageToHtml(MID_(5))), "green"));
        // Update the UserModel
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
        break;
    case Irc::RPL_WHOISSERVER:
        // qDebug() << message->parameters();
        whoisUser = (UserListItem *)nicknameHash.value(P_(1), 0);
        if (whoisUser)
        {
            whoisUser->setServer(P_(2));

        }
        //emit outputString(this->host(), colorize(tr("*** %1 is online via %2 (%3)")
        //                                         .arg(P_(1), P_(2), P_(3)), "green"));
        // Update the UserModel
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
        break;
    case Irc::RPL_WHOISACCOUNT: // nick user is logged in as
        //qDebug() << message->parameters();
        //emit outputString(this->host(), colorize(tr("*** %1 %3 %2").arg(P_(1), P_(2), P_(3)), "green"));
        break;
    case Irc::RPL_WHOWASUSER:
        emit outputString(this->host(), colorize(tr("*** %1 was %2@%3 %4 %5")
                                                 .arg(P_(1), P_(2), P_(3), P_(4), P_(5)), "green"));
        break;
    case Irc::RPL_WHOISIDLE:
        myDateTime = QDateTime::fromTime_t(P_(3).toInt());
        myTime = QTime().addSecs(P_(2).toInt());
        whoisUser = (UserListItem *)nicknameHash.value(P_(1), 0);
        // Save to nicknameList. I'm not bothering with the idle time, as it's going
        // to be very inaccurate by the time the user sees it.
        if (whoisUser)
        {
            whoisUser->setOnlineSince(myDateTime);
        }
        //emit outputString(this->host(), colorize(tr("*** %1 has been online since %2 (idle for %3)")
        //                                         .arg(P_(1), myDateTime.toString(), myTime.toString()), "green"));
        // Update the UserModel
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
        break;
    case Irc::RPL_WHOISCHANNELS:
        // qDebug() << message->parameters();
        // Save to nicknameList
        whoisUser = (UserListItem *)nicknameHash.value(P_(1), 0);
        if (whoisUser)
        {
            whoisUser->setChannels(P_(2));
        }
        //emit outputString(this->host(), colorize(tr("*** %1 is on channels %2").arg(P_(1), P_(2)), "green"));
        // Update the UserModel
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
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
        //qDebug() << MID_(0);
        // If first RPL_NAMEREPLY in a group, clear the list.
        if (newNames)
        {
            nicknameList.clear();
            nicknameHash.clear();
        }
        // Parse through the list adding the names to the list.
        // It's in a single string, so it's necessary to split it.
        foreach (const QString& name, P_(3).split(" ", QString::SkipEmptyParts))
        {
            UserListItem *newUser = new UserListItem();

            newUser->setName(name);
            nicknameList.append(newUser);
            nicknameHash.insert(name, newUser);
            if (settings.autoFetchWhois())
                whoIs(name);
        }
        // Stop the list clearing when another RPL_NAMEREPLY comes in.
        newNames = false;
        break;

    case Irc::RPL_ENDOFNAMES:
        channel = P_(1);
        msg = colorize(tr("*** %1 has %2 user(s)").arg(channel).arg(nicknameList.count()), "green");
        qStableSort(nicknameList.begin(), nicknameList.end(), userListItemLessThan);
        emit newNamesList(channel, nicknameList.count());
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
        emit outputString(this->host(), msg);
        newNames = true;
        break;

    case Irc::RPL_LISTSTART:
        channelList.clear();
        break;

    case Irc::RPL_LIST:
        topic = P_(3);
        index = topic.indexOf("]");
        clitem = new ChannelListItem(P_(1),P_(2).toInt(), P_(3).remove(0, index+2));
        channelList.append(clitem);
        break;

    case Irc::RPL_LISTEND:
        qStableSort(channelList.begin(), channelList.end(), currentListItemLessThanChannel);
        context->setContextProperty("ChannelModel", QVariant::fromValue(channelList));
        emit newChannelList();
        break;
    }

}

void Session::handlePartMessage(IrcPartMessage *message)
{
    IrcSender sender = message->sender();
    const QString senderString = prettyUser(message->sender());

    // Remove the user from the nickname list...
    UserListItem *user = (UserListItem *)nicknameHash.value(sender.name(), 0);
    if (user)
    {
        int index = nicknameList.indexOf(user);
        nicknameList.removeAt(index);
        nicknameHash.remove(sender.name());
    }

    // Update the channel list
    context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));

    if (!message->reason().isEmpty())
    {
        QString output = colorize(tr("*** %1 left %2 (%3)")
                                  .arg(senderString, message->channel(),
                                       IrcUtil::messageToHtml(message->reason())),"green");
        emit outputString(message->channel(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 left %2")
                                  .arg(senderString, message->channel()),"green");
        emit outputString(message->channel(), output);
    }
}

void Session::handlePongMessage(IrcPongMessage *message)
{
    emit outputString(this->host(), formatPingReply(message->sender(), message->argument()));
}

void Session::handlePrivateMessage(IrcPrivateMessage *message)
{
    ConnectionSettings settings;
    const QString sender = prettyUser(message->sender());
    const QString msg = IrcUtil::messageToHtml(message->message());
    QString timestamp = "";
    if (settings.showTimestamp())
    {
        timestamp = getTimestamp();
    }

    if (message->isAction())
        emit outputString(message->target(), colorize(tr("*** %1 %2").arg(sender, msg), "purple"));
    else if (message->isRequest())
        emit outputString(message->target(), colorize(tr("*** %1 requested %2")
                                                      .arg(sender,
                                                           msg.split(" ").value(0).toLower()), "green"));
    else
        emit outputString(message->target(), tr("%3&lt;%1&gt; %2").arg(sender, msg, timestamp));
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

QString Session::getTimestamp()
{
    QString timeNow = "[" + QTime::currentTime().toString("hh:mm") + "]";
    return colorize(timeNow, "grey");
}



IrcCommand* Session::parseAway(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    return IrcCommand::createAway(params.value(0));

}

IrcCommand* Session::parseInvite(const QString& channel, const QStringList& params)
{
    if (params.count() == 1)
        return IrcCommand::createInvite(params.value(0), channel);
    return 0;
}

IrcCommand* Session::parseJoin(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    if (params.count() == 1 || params.count() == 2)
        return IrcCommand::createJoin(params.value(0), params.value(1));
    return 0;
}

IrcCommand* Session::parseKick(const QString& channel, const QStringList& params)
{
    if (params.count() >= 1)
        return IrcCommand::createKick(channel, params[0], QStringList(params.mid(1)).join(" "));
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
    QString user = params[0];
    qDebug() << user;
    if (!user.isEmpty())
        return IrcCommand::createWhois(user);
    return 0;
}

IrcCommand* Session::parseWhowas(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    QString user = params[0];
    qDebug() << user;
    if (!user.isEmpty())
        return IrcCommand::createWhowas(user);
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

void Session::getChannelList(QString channel)

{
    IrcCommand *command;
    command = IrcCommand::createList(channel);
    sendCommand(command);

}

void Session::whoIs(QString user)
{
    IrcCommand *command;
    command = IrcCommand::createWhois(user);
    sendCommand(command);
}

void Session::kick(QString channel, QString user, QString reason)
{
    IrcCommand *command;
    command = IrcCommand::createKick(channel, user, reason);
    sendCommand(command);

}










