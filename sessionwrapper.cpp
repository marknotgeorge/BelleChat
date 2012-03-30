#include <IrcCommand>
#include <IrcMessage>
#include <IrcSession>
#include <QStringList>
#include <Irc>
#include <IrcUtil>
#include <QDateTime>
#include <QColor>
#include "channellistitem.h"
#include "whoisitem.h"
#include <QDeclarativeContext>
#include <QtAlgorithms>
#include "connectionsettings.h"
#include "sessionwrapper.h"

// Definitions used in handleNumericMessage...
#define P_(x) message->parameters().value(x)
#define MID_(x) QStringList(message->parameters().mid(x)).join(" ")


Session::Session(QObject *parent) :
    IrcSession(parent)
{
    //connect(this, SIGNAL(connected()), this, SLOT(onConnected()));
    connect(this, SIGNAL(messageReceived(IrcMessage*)), this, SLOT(onMessageReceived(IrcMessage*)));
    //connect(parent, SIGNAL(sendInputString(QString, QString)), this, SLOT(onInputReceived(QString, QString)));
    //connect(parent, SIGNAL(refreshNames(QString)), this, SLOT(onRefreshNames(QString)));
    connect(this, SIGNAL(password(QString*)), this, SLOT(onPassword(QString*)));
    //connect(parent, SIGNAL(updateSettings(Connection*)), this, SLOT(onUpdateConnection(Connection*)));

    m_currentChannel = "Server";
    m_lastChannel = "Server";
    newNames = true;
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

bool Session::caseInsensitiveLessThan(const QString &s1, const QString &s2)

{
    return s1.toLower() < s2.toLower();
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
        command = IrcCommand::createMessage(channel, formatInput(input));
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
    //qDebug() << message->type;
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
    QString channel = message->channel();
    const QString prettySender = prettyUser(sender);
    bool updateList = false;

    // Check to see if we are the one joining. If we are, signal
    // the UI, so it can open a new tab...
    //qDebug() << sender.name();
    if (sender.name() == this->nickName())
        emit channelJoined(channel);

    // Add user to nickname list
    QStringList nickList = nicknames.value(channel);
    //qDebug() << "Count: " << nickList.count();
    //qDebug() << nickList;
    // See if we're the only user in the list.
    // If we aren't, update the list
    if (nickList.count() == 1 )
    {
        QString nickInList = nickList.first();
        //qDebug() << nickInList;
        // Using endsWith because the first user is usually the op
        // so has a @ character in front.
        if (!nickInList.endsWith(sender.name()))
            updateList = true;
    }
    // If we're not in the list, update it.
    else if (!nickList.contains(sender.name()))
        updateList = true;

    if(updateList)
    {
        nickList.append(sender.name());
        qSort(nickList.begin(), nickList.end(), caseInsensitiveLessThan);
        nicknames.insert(channel, nickList);
    }

    // If this list is open, update the UserModel.
    if (openUserList == channel)
    {
        context->setContextProperty("UserModel", QVariant::fromValue(nickList));
        // Update the user count
        emit userCountChanged(nickList.count());
    }


    // Send output to the channel tab.
    QString joinString =  colorize(tr("*** %1 joined %2").arg(prettySender, channel),"green");
    emit outputString(channel, joinString);
}

void Session::handleKickMessage(IrcKickMessage *message)
{
    const QString sender = prettyUser(message->sender());
    const QString user = prettyUser(message->user());

    // Remove user from nickname list
    removeUser(message->user(), message->channel());
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


void Session::handleNumericMessage(IrcNumericMessage *message)
{
    QDateTime myDateTime;
    QString channel;
    QString msg;
    ChannelListItem *clitem;
    //UserListItem *whoisUser;
    QString topic;
    int index;


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
    case Irc::RPL_WHOISOPERATOR:
    case Irc::RPL_WHOISHELPOP: // "is available for help"
    case Irc::RPL_WHOISSPECIAL: // "is identified to services"
    case Irc::RPL_WHOISSECURE: // nick is using a secure connection
    case Irc::RPL_WHOISHOST: // nick is connecting from <...>
    case Irc::RPL_WHOISUSER:
    case Irc::RPL_WHOISSERVER:
    case Irc::RPL_WHOISACCOUNT:
    case Irc::RPL_WHOWASUSER:
    case Irc::RPL_WHOISIDLE:
    case Irc::RPL_WHOISCHANNELS:
        processWhoIs(message);
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
        handleNAMREPLY(message);
        break;
    case Irc::RPL_ENDOFNAMES:
        //qDebug() << message->parameters();
        channel = P_(1);

        // Sort the list...
        qSort(nicknameList.begin(), nicknameList.end(), caseInsensitiveLessThan);
        nicknames.insert(channel, nicknameList);

        // If the list's the latest one to be looked at, update it.
        if (channel == openUserList)
            context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
        msg = colorize(tr("*** %1 has %2 user(s)").arg(channel).arg(nicknameList.count()), "green");
        emit outputString(this->host(), msg);
        newNames = true;
        break;

    case Irc::RPL_LISTSTART:
        channelList.clear();
        break;

    case Irc::RPL_LIST:
        // Remove the mode hieroglyphics from the start of the topic string.
        // This ends with a ] character, so find this...
        index = P_(3).indexOf("]");
        topic = P_(3).remove(0, index);
        // Remove any whitespace from the start of the string...
        topic.remove(QRegExp("\\s+"));

        clitem = new ChannelListItem(P_(1),P_(2).toInt(), topic);
        channelList.append(clitem);
        break;

    case Irc::RPL_LISTEND:
        qStableSort(channelList.begin(), channelList.end(), currentListItemLessThanChannel);
        context->setContextProperty("ChannelModel", QVariant::fromValue(channelList));
        emit newChannelList(channelList.count());
        break;
    }

}

void Session::handlePartMessage(IrcPartMessage *message)
{
    IrcSender sender = message->sender();
    const QString senderString = prettyUser(sender.name());
    QString channel = message->channel();

    // Remove the user from the list...
    removeUser(sender.name(), channel);

    // Sent output to the channel tab.
    if (!message->reason().isEmpty())
    {
        QString output = colorize(tr("*** %1 left %2 (%3)")
                                  .arg(senderString, channel,
                                       IrcUtil::messageToHtml(message->reason())),"green");
        emit outputString(message->channel(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 left %2")
                                  .arg(senderString, channel),"green");
        emit outputString(channel, output);
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
    IrcSender sender = message->sender();
    QString prettySender = prettyUser(sender.name());

    // Remove the user from the hashtable.
    // First get all the channels...
    QStringList openChannels = nicknames.keys();
    // Remove the user from each channel in turn...
    foreach (QString channelString, openChannels)
    {
        removeUser(sender.name(), channelString);
    }

    if (!message->reason().isEmpty())
    {
        QString output = colorize(tr("*** %1 has quit (%2)")
                                  .arg(prettySender,
                                       IrcUtil::messageToHtml(message->reason())), "blue");

        emit outputString(this->currentChannel(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 has quit")
                                  .arg(prettySender), "blue");

        emit outputString(this->currentChannel(), output);
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

void Session::handleNAMREPLY(IrcMessage *message)
{
    QStringList names = message->parameters().value(3).split(" ", QString::SkipEmptyParts);
    //qDebug() << "New names:" << names.count();

    // If first RPL_NAMEREPLY in a group, clear the list.
    if (newNames) {
        nicknameList.clear();
    }
    //qDebug() << "Names b/f: " << nicknameList.count();
    // Append the list to the nickname list.
    nicknameList.append(names);
    //qDebug() << "Names c/f" << nicknameList.count();
    // Stop the list clearing when another RPL_NAMEREPLY comes in.
    newNames = false;
}

void Session::processWhoIs(IrcNumericMessage *message)
{
    WhoIsItem* whoisUser;
    QString name = P_(1);
    QTime myTime;
    QDateTime myDateTime;


    //qDebug() << "name:";
    // First get hold of a UserListItem...
    if (whoisHash.contains(name))
        whoisUser = (WhoIsItem *)whoisHash.value(name);
    else
    {
        //qDebug() << "New whois!";
        whoisUser = new WhoIsItem();
        whoisUser->setName(name);
    }

    // Now fill up

    switch (message->code())
    {
    case Irc::RPL_ENDOFWHOIS:
        // Put the details in the hashtable, and send it to the UI.
        emit whoIsReceived(whoisUser);
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
        whoisUser->setUser(QString("%1@%2").arg(P_(2),P_(3)));
        whoisUser->setRealname(P_(5));
        break;
    case Irc::RPL_WHOISSERVER:
        whoisUser->setServer(P_(2));
        break;
    case Irc::RPL_WHOISACCOUNT: // nick user is logged in as
        break;
    case Irc::RPL_WHOWASUSER:
        emit outputString(this->host(), colorize(tr("*** %1 was %2@%3 %4 %5")
                                                 .arg(P_(1), P_(2), P_(3), P_(4), P_(5)), "green"));
        break;
    case Irc::RPL_WHOISIDLE:
        myDateTime = QDateTime::fromTime_t(P_(3).toInt());
        myTime = QTime().addSecs(P_(2).toInt());
        whoisUser->setOnlineSince(myDateTime);
        break;
    case Irc::RPL_WHOISCHANNELS:
        whoisUser->setChannels(P_(2));
        break;

    }
    // Put the user in the hashtable...
    whoisHash.insert(name, whoisUser);
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

QString Session::formatInput(const QString &inputString)
{
    QString prefix = "";
    QString suffix = "";
    ConnectionSettings settings;


    // Formatting code goes here...
    if(settings.formatText())
    {
        // Coloured text
        prefix = QChar(3) + QString("%1,%2").arg(settings.textColour()).arg(settings.backgroundColour());
        suffix = QChar(15); // This turns everything off.
        // Bold...
        if (settings.textBold())
            prefix += QChar(2);
        // Italic...
        if(settings.textItalic())
            prefix += QChar(29);
        // Underline...
        if(settings.textUnderline())
            prefix += QChar(31);
    }


    QString formattedInput = prefix + inputString + suffix;

    return formattedInput;
}

bool Session::removeUser(QString user, QString channel)
{
    bool foundUser = false;
    // Get the channel's nickname list from the hashtable...
    QStringList nicknameList = nicknames.value(channel);

    // Remove the user from the nickname list...
    foundUser = (bool)nicknameList.removeAll(user);

    // Put the list back in the hashtable...
    nicknames.insert(channel, nicknameList);


    // If this list is open, update it.
    if (openUserList == channel)
    {
        context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
        emit userCountChanged(nicknameList.count());
    }

    return foundUser;
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
    //qDebug() << user;
    if (!user.isEmpty())
        return IrcCommand::createWhois(user);
    return 0;
}

IrcCommand* Session::parseWhowas(const QString& channel, const QStringList& params)
{
    Q_UNUSED(channel);
    QString user = params[0];
    //qDebug() << user;
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

void Session::getNicknames(QString channel)
{
    QStringList nicknameList = nicknames.value(channel);
    openUserList = channel;
    context->setContextProperty("UserModel", QVariant::fromValue(nicknameList));
}

void Session::whoIs(QString user)
{
    // If the details are in the hashtable send them to the UI...
    WhoIsItem* whoisUser = (WhoIsItem *)whoisHash.value(user,0);
    if (whoisUser)
    {
        //qDebug() << "Existing whois!";
        emit whoIsReceived(whoisUser);
    }
    else
    {
        // Get the details from the server.
        IrcCommand *command;
        command = IrcCommand::createWhois(user);
        sendCommand(command);
    }
}

void Session::kick(QString channel, QString user, QString reason)
{
    IrcCommand *command;
    command = IrcCommand::createKick(channel, user, reason);
    sendCommand(command);
}

QString Session::currentChannel()
{
    return m_currentChannel;
}

void Session::setCurrentChannel(QString newCurrentChannel)
{
    m_currentChannel = newCurrentChannel;
    emit currentChannelChanged(newCurrentChannel);
}

QString Session::lastChannel()
{
    return m_lastChannel;
}

void Session::setLastChannel(QString newLastChannel)
{
    m_lastChannel = newLastChannel;
    emit lastChannelChanged(newLastChannel);
}

void Session::quit(QString quitMessage)
{
    IrcCommand* command;
    command = IrcCommand::createQuit(quitMessage);
    sendCommand(command);
}

int Session::userCount()
{
    return nicknames.value(this->currentChannel()).count();
}

QString Session::getRealname(QString user)
{
    if (whoisHash.contains(user))
    {
        WhoIsItem* who = (WhoIsItem *)whoisHash.value(user);
        return who->realname();
    }
    else
        return "";

}

void Session::sendNames(QString channel)
{
    IrcCommand *command;
    command = IrcCommand::createNames(channel);
    sendCommand(command);
}










