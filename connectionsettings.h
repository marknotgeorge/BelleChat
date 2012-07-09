#ifndef CONNECTIONSETTINGS_H
#define CONNECTIONSETTINGS_H

#include <QObject>
#include <QSettings>

class ConnectionSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QString host READ host WRITE setHost NOTIFY hostChanged)
    Q_PROPERTY (int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY (QString nickname READ nickname WRITE setNickname NOTIFY nicknameChanged)
    Q_PROPERTY (QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY (QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY (QString realname READ realname WRITE setRealname NOTIFY realnameChanged)
    Q_PROPERTY (bool showTimestamp READ showTimestamp WRITE setShowTimestamp NOTIFY showTimestampChanged)
    Q_PROPERTY (bool autoFetchWhois READ autoFetchWhois WRITE setAutoFetchWhois NOTIFY autoFetchWhoisChanged)
    Q_PROPERTY (int textColour READ textColour WRITE setTextColour NOTIFY textColourChanged)
    Q_PROPERTY (int backgroundColour READ backgroundColour WRITE setBackgroundColour NOTIFY backgroundColourChanged)
    Q_PROPERTY (bool textBold READ textBold WRITE setTextBold NOTIFY textBoldChanged)
    Q_PROPERTY (bool textItalic READ textItalic WRITE setTextItalic NOTIFY textItalicChanged)
    Q_PROPERTY (bool textUnderline READ textUnderline WRITE setTextUnderline NOTIFY textUnderlineChanged)
    Q_PROPERTY (bool formatText READ formatText WRITE setFormatText NOTIFY formatTextChanged)
    Q_PROPERTY (bool showChannelList READ showChannelList WRITE setShowChannelList NOTIFY showChannelListChanged)
    Q_PROPERTY (QString quitMessage READ quitMessage WRITE setQuitMessage NOTIFY quitMessageChanged)
    Q_PROPERTY (bool supressStartPage READ supressStartPage WRITE setSupressStartPage NOTIFY supressStartPageChanged)
    Q_PROPERTY (QString awayMessage READ awayMessage WRITE setAwayMessage NOTIFY awayMessageChanged)
    Q_PROPERTY (int timeoutInterval READ timeoutInterval WRITE setTimeoutInterval NOTIFY timeoutIntervalChanged)
    Q_PROPERTY (bool autoJoinChannels READ autoJoinChannels WRITE setAutoJoinChannels NOTIFY autoJoinChannelsChanged)
    Q_PROPERTY (QString autoJoinChanList READ autoJoinChanList WRITE setAutoJoinChanList NOTIFY autoJoinChanListChanged)
    Q_PROPERTY (bool allowUserInfo READ allowUserInfo WRITE setAllowUserInfo NOTIFY allowUserInfoChanged)
    Q_PROPERTY (QString userInfo READ userInfo WRITE setUserInfo NOTIFY userInfoChanged)
    Q_PROPERTY (bool respondToIdent READ respondToIdent WRITE setRespondToIdent NOTIFY respondToIdentChanged)

public:
    explicit ConnectionSettings(QObject *parent = 0);
    
    Q_INVOKABLE QString host();
    Q_INVOKABLE int port();    
    Q_INVOKABLE QString nickname();
    Q_INVOKABLE QString password();
    Q_INVOKABLE QString username();
    Q_INVOKABLE QString realname();
    Q_INVOKABLE bool showTimestamp();
    Q_INVOKABLE bool autoFetchWhois();
    Q_INVOKABLE int textColour();
    Q_INVOKABLE int backgroundColour();
    Q_INVOKABLE bool textBold();
    Q_INVOKABLE bool textItalic();
    Q_INVOKABLE bool textUnderline();
    Q_INVOKABLE bool formatText();
    Q_INVOKABLE bool showChannelList();
    Q_INVOKABLE QString quitMessage();
    Q_INVOKABLE bool supressStartPage();
    Q_INVOKABLE QString awayMessage();
    Q_INVOKABLE int timeoutInterval();
    Q_INVOKABLE bool autoJoinChannels();
    Q_INVOKABLE QString autoJoinChanList();
    Q_INVOKABLE bool allowUserInfo();
    Q_INVOKABLE QString userInfo();
    Q_INVOKABLE bool respondToIdent();



signals:
    void hostChanged(QString newHost);
    void portChanged(QString newPort);
    void nicknameChanged(QString newNickname);
    void passwordChanged(QString newPassword);
    void usernameChanged(QString newUsername);
    void realnameChanged(QString newRealname);
    void showTimestampChanged(bool newShowTimestamp);
    void autoFetchWhoisChanged(bool newAutoFetchWhois);
    void textColourChanged(int newTextColour);
    void backgroundColourChanged(int newBackgroundColour);
    void textBoldChanged (bool newTextBold);
    void textItalicChanged (bool newTextItalic);
    void textUnderlineChanged (bool newTextUnderline);
    void formatTextChanged (bool newFormatText);
    void showChannelListChanged (bool newShowChannelList);
    void quitMessageChanged(QString newQuitMessage);
    void supressStartPageChanged(bool newSupressStartPage);
    void awayMessageChanged(QString newAwayMessage);
    void timeoutIntervalChanged(QString newTimeoutInterval);
    void autoJoinChannelsChanged(bool newAutoJoinChannels);
    void autoJoinChanListChanged(QString newAutoJoinChanList);
    void allowUserInfoChanged(bool newAllowUserInfo);
    void userInfoChanged(QString newUserInfo);
    void respondToIdentChanged(bool newRespondToIdent);
    
public slots:
    Q_INVOKABLE void setHost(QString newHost);
    Q_INVOKABLE void setPort(int newPort);
    Q_INVOKABLE void setPort(QString newPortString);
    Q_INVOKABLE void setNickname(QString newNickname);
    Q_INVOKABLE void setPassword(QString newPassword);
    Q_INVOKABLE void setUsername(QString newUsername);
    Q_INVOKABLE void setRealname(QString newRealname);
    Q_INVOKABLE void setShowTimestamp(bool newShowTimestamp);
    Q_INVOKABLE void setAutoFetchWhois(bool newAutoFetchWhois);
    Q_INVOKABLE void setTextColour(int newTextColour);
    Q_INVOKABLE void setBackgroundColour(int newBackgroundColour);
    Q_INVOKABLE void setTextBold(bool newTextBold);
    Q_INVOKABLE void setTextItalic(bool newTextItalic);
    Q_INVOKABLE void setTextUnderline(bool newTextUnderline);
    Q_INVOKABLE void setFormatText(bool newFormatText);
    Q_INVOKABLE void setShowChannelList(bool newShowChannelList);
    Q_INVOKABLE void setQuitMessage(QString newQuitMessage);
    Q_INVOKABLE void setSupressStartPage(bool newSupressStartPage);
    Q_INVOKABLE void setAwayMessage(QString newAwayMessage);
    Q_INVOKABLE void setTimeoutInterval(int newTimeoutInterval);
    Q_INVOKABLE void setTimeoutInterval(QString newTimeoutIntervalString);
    Q_INVOKABLE void setAutoJoinChannels(bool newAutoJoinChannels);
    Q_INVOKABLE void setAutoJoinChanList(QString newAutoJoinChanList);
    Q_INVOKABLE void setAllowUserInfo(bool newAllowUserInfo);
    Q_INVOKABLE void setUserInfo(QString newUserInfo);
    Q_INVOKABLE void setRespondToIdent(bool newRespondToIdent);

private:


};

#endif // CONNECTIONSETTINGS_H
