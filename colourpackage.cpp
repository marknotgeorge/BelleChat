#include "colourpackage.h"

ColourPackage::ColourPackage(QObject *parent) :
    QObject(parent)
{
}

QString ColourPackage::colours()
{
    return m_colours;
}

QString ColourPackage::message()
{
    return m_message;
}


void ColourPackage::setColours(QString newColours)
{
    m_colours = newColours;
}

void ColourPackage::setMessage(QString newMessage)
{
    m_message = newMessage;
}
