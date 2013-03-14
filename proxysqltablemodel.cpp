#include "proxysqltablemodel.h"
#include <QSqlTableModel>
#include <QSqlRecord>

ProxySQLTableModel::ProxySQLTableModel(QObject *parent, QSqlDatabase db) :
    QSqlTableModel(parent)
{
    QSqlTableModel::QSqlTableModel(parent, db);
}

QVariant ProxySQLTableModel::data (const QModelIndex & Index, int iRole) const
{
  if (iRole>=Qt::UserRole)
    return QSqlTableModel::data(index(Index.row(),iRole-Qt::UserRole));

  return QSqlTableModel::data(Index,iRole);
}

void ProxySQLTableModel::setProxyModel(const QString& sTable)
{
  QHash<int, QByteArray> hashRoles;

  QSqlTableModel Table;
  Table.setTable(sTable);
  QSqlRecord Record = Table.record();

  for (int i=0; i<Record.count(); i++)
    hashRoles.insert(Qt::UserRole+i,Record.fieldName(i).toAscii());
  setRoleNames(hashRoles);
  setTable(sTable);
  select();
}



