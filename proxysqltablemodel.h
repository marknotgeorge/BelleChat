#ifndef PROXYSQLTABLEMODEL_H
#define PROXYSQLTABLEMODEL_H

#include <QObject>
#include <QSqlTableModel>
#include <QSqlDatabase>

class ProxySQLTableModel : public QSqlTableModel
{
    Q_OBJECT
public:
    explicit ProxySQLTableModel(QObject *parent = 0, QSqlDatabase db=QSqlDatabase());
    QVariant data (const QModelIndex & Index, int iRole = Qt::DisplayRole) const;
    void setProxyModel(const QString& sTable);
    
signals:
    
public slots:
    
};

#endif // PROXYSQLTABLEMODEL_H
