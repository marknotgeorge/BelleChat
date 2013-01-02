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
#include <QSystemDeviceInfo>
#include "sleeper.h"
#include <QKeyEvent>
#include <QCoreApplication>

QTM_USE_NAMESPACE

// Definitions used in handleNumericMessage...
#define P_(x) message->parameters().value(x)
#define MID_(x) QStringList(message->parameters().mid(x)).join(" ")


Session::Session(QObject *parent) :
    IrcSession(parent)
{
    connect(this, SIGNAL(connected()), this, SLOT(onConnected()));
    connect(this, SIGNAL(messageReceived(IrcMessage*)), this, SLOT(onMessageReceived(IrcMessage*)));
    //connect(parent, SIGNAL(sendInputString(QString, QString)), this, SLOT(onInputReceived(QString, QString)));
    //connect(parent, SIGNAL(refreshNames(QString)), this, SLOT(onRefreshNames(QString)));
    connect(this, SIGNAL(password(QString*)), this, SLOT(onPassword(QString*)));
    //connect(parent, SIGNAL(updateSettings(Connection*)), this, SLOT(onUpdateConnection(Connection*)));

    // Connect up the ident server slots and strings
    connect(&identServer, SIGNAL(newConnection()), this, SLOT(onIdentNewConnection()));

    m_currentChannel = "Server";
    m_lastChannel = "Server";
    newNames = true;
    m_isAway = false;

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
    //qDebug() << message->toString();
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
    QString output = colorize(tr("*** %1 invited to %3").arg(sender, message->channel()),
                              colourPalette.serverReply());
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
    QString joinString =  colorize(tr("*** %1 joined %2").arg(prettySender, channel),
                                   colourPalette.serverReply());
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
        QString output = colorize(tr("*** %1 kicked %2 (%3)").arg(sender, user, message->reason()),
                                  colourPalette.kickColour());
        emit outputString(message->channel(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 kicked %2").arg(sender, user),
                                  colourPalette.kickColour());
        emit outputString(message->channel(), output);
    }
}

void Session::handleModeMessage(IrcModeMessage *message)
{
    const QString sender = prettyUser(message->sender());
    QString output = colorize(tr("*** %1 sets mode %2 %3").arg(sender, message->mode(), message->argument()),
                              colourPalette.serverReply());
    emit outputString(this->host(), output);
}

void Session::handleNickMessage(IrcNickMessage *message)
{
    IrcSender sender = message->sender();

    const QString oldNick = sender.name();
    const QString newNick = message->nick();
    QString output = colorize(tr("*** %1 changed nick to %2")
                              .arg(prettyUser(oldNick), prettyUser(newNick)),
                              colourPalette.nickColour());
    QStringList outputChannels;
    QStringList mutualChannels;

    // Obtain a list of channels to which both we and the nick changer
    // are both joined. First get all the channels...
    outputChannels = nicknames.keys();

    foreach (QString chan, outputChannels)
    {
        QStringList chanList = nicknames.value(chan);

        // If the channel contains the old nickname...
        if (chanList.contains(oldNick))
        {
            // Add it to the list of mutual channels...
            mutualChannels.append(chan);

            // Change the old nickname to the new one...
            int oldNickIndex = chanList.indexOf(oldNick);
            chanList.replace(oldNickIndex, newNick);

            // Put the list back in the hashtable...
            nicknames.insert(chan, chanList);

            // If this list is open, update the UserModel.
            if (openUserList == chan)
            {
                context->setContextProperty("UserModel", QVariant::fromValue(chanList));
                // Update the user count
                emit userCountChanged(chanList.count());
            }
        }
    }

    // Send the output to each channel in the list...
    foreach (QString chan, mutualChannels)
        outputString(chan, output);
}

void Session::handleNoticeMessage(IrcNoticeMessage *message)
{
    WhoIsItem *user;
    if (message->isReply())
    {
        const QStringList params = message->message().split(" ", QString::SkipEmptyParts);
        const QString cmd = params.value(0);
        const QString arg = params.value(1);
        const QString prettySender = prettyUser(message->sender());
        const QString output = QStringList(params.mid(1)).join(" ");
        const QString sender = message->sender().name();


        // First get hold of a UserListItem...
        if (whoisHash.contains(sender))
            user = (WhoIsItem *)whoisHash.value(sender);
        else
        {
            //qDebug() << "New whois!";
            user = new WhoIsItem();
            user->setName(sender);
            // Put the user in the hashtable...
            whoisHash.insert(sender, user);
        }

        if (cmd.toUpper() == "PING")
            emit outputString(this->currentChannel(),
                              colorize(formatPingReply(message->sender(), arg),
                                       colourPalette.ctcpReplyColour()));

        else if (cmd.toUpper() == "TIME")
            emit outputString(this->currentChannel(),
                              colorize(tr("! %1 time is %2").arg(prettySender, output),
                                       colourPalette.ctcpReplyColour()));

        else if (cmd.toUpper() == "VERSION")
        {
            emit outputString(this->currentChannel(),
                              colorize(tr("! %1 version is %2").arg(prettySender, output),
                                       colourPalette.ctcpReplyColour()));
            if (user)
                user->setClientVersion(output);
        }
        else if (cmd.toUpper() == "USERINFO")
        {
            emit outputString(this->currentChannel(),
                              colorize(tr("! %1 is %2").arg(prettySender, output),
                                       colourPalette.ctcpReplyColour()));
            if (user)
                user->setUserInfo(output);
        }
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
        emit outputString(this->host(),
                          colorize(tr("[INFO] %1").arg(IrcUtil::messageToHtml(MID_(1))),
                                   colourPalette.info()));
    if (QByteArray(Irc::toString(message->code())).startsWith("ERR_") &&
            message->code() != Irc::ERR_BADCHANNELKEY)
    {
        emit outputString(this->host(),
                          colorize(tr("[ERROR] %1").arg(IrcUtil::messageToHtml(MID_(1))),
                                   colourPalette.info()));
        emit displayError(MID_(1));
    }

    switch (message->code())
    {
    case Irc::ERR_BADCHANNELKEY:
        // This code is received when a join attempt on a protected channel fails
        // due to a missing or wrong key.
        //
        // Tell the UI a key is required.
        emit channelRequiresKey(P_(1));
        break;
    case Irc::RPL_MOTDSTART:
    case Irc::RPL_MOTD:
        emit outputString(this->host(),
                          colorize(IrcUtil::messageToHtml(MID_(1)), colourPalette.motd()));
        break;
    case Irc::RPL_AWAY:

        emit outputString(this->host(),
                          colorize(tr("*** %1 is away (%2)").arg(P_(1), MID_(2)),
                                   colourPalette.serverReply()));
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
        emit outputString(this->host(),
                          colorize(tr("*** %1 mode is %2").arg(P_(1), P_(2)),
                                   colourPalette.serverReply()));
        break;
    case Irc::RPL_CHANNEL_URL:
        emit outputString(this->host(), colorize(tr("*** %1 url is %2")
                                                 .arg(P_(1), IrcUtil::messageToHtml(P_(2))),
                                                 colourPalette.serverReply()));
        break;
    case Irc::RPL_CREATIONTIME:
        myDateTime = QDateTime::fromTime_t(P_(2).toInt());
        emit outputString(this->host(), colorize(tr("*** %1 was created %2")
                                                 .arg(P_(1), myDateTime.toString()),
                                                 colourPalette.serverReply()));
        break;
    case Irc::RPL_NOTOPIC:
        emit outputString(P_(1), colorize(tr("*** %1 has no topic set").arg(P_(1)),
                                          colourPalette.serverReply()));
        break;
    case Irc::RPL_TOPIC:
        emit outputString(P_(1), colorize(tr("*** %1 topic is \"%2\"")
                                          .arg(P_(1), IrcUtil::messageToHtml(P_(2))),
                                          colourPalette.serverReply()));
        break;
    case Irc::RPL_TOPICWHOTIME:
        myDateTime = QDateTime::fromTime_t(P_(3).toInt());
        emit outputString(P_(1), colorize(tr("*** %1 topic was set %2 by %3")
                                          .arg(P_(1), myDateTime.toString(), P_(2)),
                                          colourPalette.serverReply()));
        break;
    case Irc::RPL_INVITING:
        emit outputString(this->host(), colorize(tr("*** inviting %1 to %2").arg(P_(1), P_(2)),
                                                 colourPalette.serverReply()));
        break;
    case Irc::RPL_VERSION:
        emit outputString(this-> host(), colorize(tr("*** %1 version is %2")
                                                  .arg(message->sender().name(), P_(1)),
                                                  colourPalette.serverReply()));
        break;
    case Irc::RPL_TIME:
        emit outputString(this->host(), colorize(tr("*** %1 time is %2").arg(P_(1), P_(2)),
                                                 colourPalette.serverReply()));
        break;
    case Irc::RPL_UNAWAY:
        setIsAway(false);
        emit outputString(this->host(), colorize(tr("*** %1").arg(P_(1)),
                                                 colourPalette.serverReply()));
        break;
    case Irc::RPL_NOWAWAY:
        setIsAway(true);
        emit outputString(this->host(), colorize(tr("*** %1").arg(P_(1)),
                                                 colourPalette.serverReply()));
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
        msg = colorize(tr("*** %1 has %2 user(s)").arg(channel).arg(nicknameList.count()),
                       colourPalette.serverReply());
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
        topic = P_(3).remove(0, index+1);
        clitem = new ChannelListItem(P_(1),P_(2).toInt(), topic.trimmed());
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
                                       IrcUtil::messageToHtml(message->reason())),
                                  colourPalette.serverReply());
        emit outputString(message->channel(), output);
    }
    else
    {
        QString output = colorize(tr("*** %1 left %2")
                                  .arg(senderString, channel),colourPalette.serverReply());
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
    const QString senderName = message->sender().name();
    const QString msg = formatString(message->message());
    QString timestamp = "";
    QString output;

    qDebug() << message->message();
    if (settings.showTimestamp())
    {
        timestamp = getTimestamp();
    }

    // First format the message...

    if (message->isRequest())
        // Requests require special handling...
        handleRequestMessage(message);
    else
    {

        if (message->isAction())
            output = colorize(tr("*** %1 %2").arg(sender, msg), colourPalette.action());

        else
            output = tr("%3&lt;%1&gt; %2").arg(sender, msg, timestamp);

        // Now send it to the UI...
        if (message->target() == nickName())
        {
            // This is a private message.
            if (!isAway())
                emit queryReceived(senderName, output);
        }
        else
            // It's a channel message...
            emit outputString(message->target(), output);
    }
}

void Session::handleRequestMessage(IrcPrivateMessage *message)
{
    const QString sender = prettyUser(message->sender());
    const QString senderName = message->sender().name();
    const QString msg = IrcUtil::messageToHtml(message->message());
    QString output;
    QString reply;
    QString upperMessage = message->message().toUpper();
    // Get the device info for the phone model...
    QSystemDeviceInfo *deviceInfo = new QSystemDeviceInfo(this);
    IrcCommand *command;
    ConnectionSettings settings;

    // First output the request...
    output = colorize(tr("*** %1 requested %2")
                      .arg(sender, msg.split(" ").value(0).toLower()),
                      colourPalette.serverReply());
    emit outputString(this->host(), output);
    qDebug() << upperMessage;

    // Formulate the reply...
    if(upperMessage == "VERSION")
    {
        QString ver = VERSIONNO;
        reply = "VERSION BelleChat:" + ver.remove('\"') + ":" +
                deviceInfo->manufacturer() + " " + deviceInfo->model();
        qDebug() << reply;

    }
    else if (upperMessage == "SOURCE")
    {
        reply = "SOURCE https://github.com/marknotgeorge/BelleChat";
    }
    else if (upperMessage == "USERINFO" && settings.allowUserInfo())
    {
        reply = "USERINFO " + settings.userInfo();
    }
    else if (upperMessage == "CLIENTINFO")
    {
        reply = "CLIENTINFO VERSION SOURCE TIME PING";
        if (settings.allowUserInfo())
            reply = reply + " USERINFO";
    }
    else if (upperMessage == "TIME")
    {
        // Do nothing. It's handled by Communi...
    }
    else if (upperMessage.startsWith("PING"))
    {
        // Do nothing. It's handled by Communi...
    }
    else
    {
        reply = "ERRMSG I don't understand that request.";
    }

    // Send the reply and echo it to UI...
    if (!reply.isEmpty())
    {
        command = IrcCommand::createCtcpReply(senderName, reply);
        if(command)
        {
            QString replyString = colorize(tr("*** Reply to %1: %2")
                                           .arg(sender, reply),
                                           colourPalette.serverReply());
            outputString(this->host(), replyString);
            sendCommand(command);
        }
    }
}


void Session::handleQuitMessage(IrcQuitMessage *message)
{
    IrcSender sender = message->sender();
    QString prettySender = prettyUser(sender.name());
    QString output;

    qDebug() << "Sender: " << sender.name();


    if (!message->reason().isEmpty())
    {
        output = colorize(tr("*** %1 has quit (%2)")
                          .arg(prettySender,
                               IrcUtil::messageToHtml(message->reason())), colourPalette.quitColour());
    }
    else
    {
        output = colorize(tr("*** %1 has quit")
                          .arg(prettySender), colourPalette.quitColour());
    }

    // Remove the user from the hashtable.
    // First get all the channels...
    QStringList openChannels = nicknames.keys();
    // Remove the user from each channel in turn...
    foreach (QString channelString, openChannels)
    {
        QStringList chanList = nicknames.value(channelString);

        qDebug() << "Testing channel " << channelString;
        if (chanList.contains(sender.name()))
        {
            removeUser(sender.name(), channelString);
            outputString(channelString, output);
        }
    }
}

void Session::handleTopicMessage(IrcTopicMessage *message)
{
    const QString sender = prettyUser(message->sender());
    const QString topic = IrcUtil::messageToHtml(message->topic());
    QString output = colorize(tr("*** %1 sets topic \"%2\" on %3")
                              .arg(sender, topic, message->channel()),
                              colourPalette.serverReply());
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
    case Irc::RPL_WHOISHOST: // nick is connecting from <...>
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
        return colorize(name, colourPalette.userColour());
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
    return colorize(timeNow, colourPalette.timestampColour());
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

    // Remove if the user is in the WhoIs table, delete the entry...
    WhoIsItem *itemToRemove = (WhoIsItem *)whoisHash.value(user);
    if (itemToRemove)
        delete itemToRemove;


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

void Session::joinProtectedChannel(QString channel, QString key)
{
    if (!channel.isEmpty())
    {
        IrcCommand *command;
        command = IrcCommand::createJoin(channel, key);
        sendCommand(command);
    }
}

void Session::partChannel(QString channel)
{
    if (!channel.isEmpty())
    {
        IrcCommand *command;
        command = IrcCommand::createPart(channel, "Bye!");
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
    WhoIsItem* whoisUser = (WhoIsItem *)whoisHash.value(removeMode(user),0);
    if (whoisUser)
    {
        //qDebug() << "Existing whois!";
        emit whoIsReceived(whoisUser);
    }
    else
    {
        // Get the details from the server.
        IrcCommand *command;
        command = IrcCommand::createWhois(removeMode(user));
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

QString Session::removeMode(QString user)
{
    // Returns a nickname string with the mode prefix
    // @ or + removed.
    if (user.startsWith("@")||user.startsWith("+"))
        return user.remove(0,1);
    else
        return user;
}

bool Session::isAway()
{
    return m_isAway;
}

void Session::markAway(bool newIsAway)
{
    ConnectionSettings settings;
    IrcCommand *command;
    qDebug() << newIsAway;
    if (newIsAway)
    {
        // Set the AWAY message...
        command = IrcCommand::createAway(settings.awayMessage());
    }
    else
    {
        // Clear the AWAY message...
        command = IrcCommand::createAway();
    }
    // Send the command...
    sendCommand(command);
}

void Session::setIsAway(bool newIsAway)
{
    m_isAway = newIsAway;
    emit isAwayChanged(newIsAway);
}

bool Session::isValidChannelName(QString channel)
{
    QRegExp channelRegExp("[#&+!]*", Qt::CaseInsensitive, QRegExp::Wildcard);
    // TODO: Find a better regular expression!

    bool valid = channelRegExp.exactMatch(channel);

    qDebug() << valid;

    return valid;

}

void Session::autoJoinChannels()
{
    ConnectionSettings settings;

    QString chanList = settings.autoJoinChanList();

    // See if we're using the new style "channel1 key1, channel2 key2 style...
    if (chanList.contains(","))
    {

        QStringList channelsToJoin = chanList.split(",");
        qDebug() << channelsToJoin;

        foreach (QString chanString, channelsToJoin)
        {
            QStringList chanAndKey = chanString.split(" ", QString::SkipEmptyParts);
            qDebug() << chanAndKey;

            if (isValidChannelName(chanAndKey[0]))
            {
                IrcCommand *command;
                if (chanAndKey.count() == 1)
                    // channel has no key...
                    command = IrcCommand::createJoin(chanAndKey[0]);
                else
                    // channel has key...
                    command = IrcCommand::createJoin(chanAndKey[0], chanAndKey[1]);
                sendCommand(command);
            }
            else
            {
                qDebug() << chanAndKey[0];
                emit displayError(tr("%1 is not a valid channel name!").arg(chanAndKey[0]));

            }
        }
    }
    else
    {
        // We must be using the old style channel list...
        QStringList channelsToJoin = chanList.split(" ");

        foreach (QString chanString, channelsToJoin)
        {
            if (isValidChannelName(chanString))
            {
                IrcCommand *command;
                command = IrcCommand::createJoin(chanString);
                sendCommand(command);
            }
            else
            {
                emit displayError(tr("%1 is not a valid channel name!").arg(chanString));
            }
        }
    }

}

void Session::sendCtcpRequest(QString target, QString request)
{
    IrcCommand *command;
    command = IrcCommand::createCtcpRequest(target, request);
    sendCommand(command);
}

WhoIsItem *Session::getWhoIs(QString user)
{
    return (WhoIsItem *)whoisHash.value(user);
}

QString Session::getTimeString()
{
    return QString::number(QDateTime::currentDateTime().toTime_t());
}

void Session::open()
{
    ConnectionSettings settings;

    // Listen on port 113 for an ident request...
    if (settings.respondToIdent())
    {
        if(!identServer.isListening())
        {
            qDebug() << "Opening ident port...";
            identServer.listen(QHostAddress::Any, 113);
            // Wait a couple of seconds...
            //Sleeper snooze;
            //snooze.sleep(2);
        }
    }

    IrcSession::open();
}

void Session::sendNickServPassword(QString password)
{
    // Send a NickServ IDENTIFY message...
    QString message = "IDENTIFY " + password;

    IrcCommand *command;
    command = IrcCommand::createMessage("NickServ", message);

    sendCommand(command);
}

void Session::pressReturn()
{
    QKeyEvent *event = new QKeyEvent(QEvent::KeyPress, Qt::Key_Enter, Qt::NoModifier, "Return", false);
    QCoreApplication::postEvent (this, event);

}

void Session::onIdentNewConnection()
{
    // The host has opened a TCP socket. Connect the signal to the slot to read the data.
    qDebug() << "TCP Socket opened...";
    identSocket = identServer.nextPendingConnection();
    connect(identSocket, SIGNAL(readyRead()), this, SLOT(onIdentReadyRead()));
}

void Session::onIdentReadyRead()
{
    // An ident request has been received from the IRC server.
    // This function creates a response.
    char buffer[1024] = {0};

    // Read the request...
    identSocket->read(buffer, identSocket->bytesAvailable());
    qDebug() << "Ident: " << buffer;
    QString bufferString = QString::fromLatin1(buffer);

    // Create a response...
    QString responseString = bufferString + " : USERID : UNIX : " + nickName();
    qDebug() << "Response: " << responseString;
    identSocket->write(responseString.toUtf8());

    // Close the socket and the server...
    identSocket->close();
    identServer.close();
}

QString Session::colorCodeToName(int code, const QString& defaultColor)
{
    switch (code)
    {
    case 0:  return QLatin1String("white");
    case 1:  return QLatin1String("black");
    case 2:  return QLatin1String("navy");
    case 3:  return QLatin1String("green");
    case 4:  return QLatin1String("red");
    case 5:  return QLatin1String("maroon");
    case 6:  return QLatin1String("purple");
    case 7:  return QLatin1String("orange");
    case 8:  return QLatin1String("yellow");
    case 9:  return QLatin1String("lime");
    case 10: return QLatin1String("darkcyan");
    case 11: return QLatin1String("cyan");
    case 12: return QLatin1String("blue");
    case 13: return QLatin1String("magenta");
    case 14: return QLatin1String("gray");
    case 15: return QLatin1String("lightgray");
    default: return defaultColor;
    }
}

QStringList Session::parseColours (QString noFlag)
{
    QStringList returnList;
    QString colours;
    QRegExp rx(QLatin1String("(\\d{1,2})(?:,(\\d{1,2}))?"));
    int idx = rx.indexIn(noFlag);
    if (!idx)
    {
        bool ok = false;
        QStringList styles;
        noFlag.remove(idx, rx.matchedLength());

        // foreground
        int code = rx.cap(1).toInt(&ok);
        if (ok)
            styles += QString(QLatin1String("color:%1")).arg(colorCodeToName(code, QLatin1String("black")));

        // background
        code = rx.cap(2).toInt(&ok);
        if (ok)
            styles += QString(QLatin1String("background-color:%1")).arg(colorCodeToName(code, QLatin1String("transparent")));

        // Override black-on-black text...
        if(styles[0]== "color:black")
            if (styles[1] == "background-color:black" || styles[1] == "background-colour:transparent")
                styles[0] = "colour:white";

        colours = styles.join(";");
        returnList[0] = colours;
        returnList[1] = noFlag;
    }
    return returnList;
}




// New code to format mIRC strings, given that the Communi code doesn't
// handle non-terminated formatting codes.

QString Session::formatString(QString source)
{
    QString message = source;
    QRegExp formatCodes("\\x03|\\x02|\\x16|\\x09|\\x13|\\x15|\\x1f");

    QStringList pieces;
    int position = 0;
    int lastMatch = position;

    // Chop the string into pieces beginning with a formatting character...
    while (position < message.length())
    {
        if (formatCodes.exactMatch(message.at(position)))
        {
            int newMatch = position;
            if (newMatch > lastMatch)
            {
                QString fragment = message.mid(lastMatch, ((newMatch)- lastMatch));
                if (!fragment.isEmpty())
                    pieces.append(fragment);
            }

            lastMatch = newMatch;
        }
        position++;
    }

    // Format each part of the string, and join them back together...

    QString returnString;

    // These indicate if we've seen an opening flag...
    bool boldFlag = false;
    bool italicFlag = false;
    bool underlineFlag = false;
    bool colourFlag = false;
    bool strikethruFlag = false;

    foreach (QString fragment, pieces)
    {
        ConnectionSettings settings;
        QString formatted;
        QStringList parsedColourFragment;
        QString noFlag = fragment.mid(1);


        switch (fragment.at(0).unicode())
        {
        case '\x02': // Bold...
            if (settings.showMircColours())
            {
                if (!boldFlag)  // Must be an opening code...
                {
                    formatted = QString("<span style='font-weight: bold'>%1").arg(noFlag);
                    boldFlag = true;
                }
                else            // Must be a closing flag...
                {
                    formatted = "</span>";
                    boldFlag = false;
                }
            }
            else
            {
                formatted = noFlag;
            }
            break;

        case '\x03': // Coloured...
            parsedColourFragment = parseColours(noFlag);
            if(settings.showMircColours())
            {
                if (!parsedColourFragment[0].isEmpty())     // We must have an opening flag...
                {
                    if (colourFlag) // There's no closing flag, so we must add one...
                    {
                        formatted = QString("</span><span style='%1'>%2").arg(parsedColourFragment[0]).arg(parsedColourFragment[1]);
                    }
                    else
                    {
                        formatted = QString("<span style='%1'>%2").arg(parsedColourFragment[0]).arg(parsedColourFragment[1]);
                        colourFlag = true;
                    }
                }
                else // There's no colour information, so this must be a closing flag...
                {
                    if (colourFlag)
                        formatted = "</span>";
                    colourFlag = false;
                }
            }
            else
            {
                formatted = parsedColourFragment[1];
            }
            break;
        case '\x09': // Italic...
            if (settings.showMircColours())
            {
                if (!italicFlag)  // Must be an opening code...
                {
                    formatted = QString("<span style='font-style: italic'>%1").arg(noFlag);
                    italicFlag = true;
                }
                else            // Must be a closing flag...
                {
                    formatted = "</span>";
                    italicFlag = false;
                }
            }
            else
            {
                formatted = noFlag;
            }
            break;
        case '\x13': // Strikethru...
            if (settings.showMircColours())
            {
                if (!strikethruFlag)  // Must be an opening code...
                {
                    formatted = QString("<span style='text-decoration: line-through'>%1").arg(noFlag);
                    strikethruFlag = true;
                }
                else            // Must be a closing flag...
                {
                    formatted = "</span>";
                    strikethruFlag = false;
                }
            }
            else
            {
                formatted = noFlag;
            }
            break;
        case '\x15': // Underline...
        case '\x1f':
            if(!noFlag.isEmpty())
                formatted = QString("<span style='text-decoration: underline'>%1</span>").arg(noFlag);
            if (settings.showMircColours())
            {
                if (!underlineFlag)  // Must be an opening code...
                {
                    formatted = QString("<span style='text-decoration: underline'>%1").arg(noFlag);
                    underlineFlag = true;
                }
                else            // Must be a closing flag...
                {
                    formatted = "</span>";
                    underlineFlag = false;
                }
            }
            else
            {
                formatted = noFlag;
            }
            break;
        default:
            if(!noFlag.isEmpty())
                formatted = noFlag;
            break;
        }

        returnString.append(formatted);
    }

    // Make sure any open flags are closed...
    if (boldFlag)
        returnString.append("</span>");
    if (colourFlag)
        returnString.append("</span>");
    if (italicFlag)
        returnString.append("</span>");
    if (strikethruFlag)
        returnString.append("</span>");
    if (underlineFlag)
        returnString.append("</span>");


    qDebug() << pieces;
    qDebug() << returnString;

    return returnString;
}













