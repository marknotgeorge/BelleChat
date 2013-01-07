#ifndef COLOURPACKAGE_H
#define COLOURPACKAGE_H

#include <QObject>

class ColourPackage : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QString colours READ colours WRITE setColours)
    Q_PROPERTY (QString message READ message WRITE setMessage)

public:
    explicit ColourPackage(QObject *parent = 0);

    QString colours();
    QString message();

    
signals:
    
public slots:
    void setColours(QString newColours);
    void setMessage(QString newMessage);

private:
    QString m_colours;
    QString m_message;
    
};

#endif // COLOURPACKAGE_H
