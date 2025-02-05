#include "FluTreeModel.h"

#include <QMetaEnum>

Node::Node(QObject *parent)
    : QObject{parent}
{

}

FluTreeModel::FluTreeModel(QObject *parent)
    : QAbstractTableModel{parent}
{
    dataSourceSize(0);
}

int FluTreeModel::rowCount(const QModelIndex &parent) const {
    return _rows.count();
};

int FluTreeModel::columnCount(const QModelIndex &parent) const {
    return 1;;
};

QVariant FluTreeModel::data(const QModelIndex &index, int role) const {
    switch (role) {
    case Qt::DisplayRole:
        return  QVariant::fromValue(_rows.at(index.row()));
    default:
        break;
    }
    return QVariant();
};

QHash<int, QByteArray> FluTreeModel::roleNames() const {
    return { {Qt::DisplayRole, "modelData"} };
};

void FluTreeModel::setData(QList<Node*> data){
    beginResetModel();
    _rows = data;
    endResetModel();
}

void FluTreeModel::removeRows(int row,int count){
    if (row < 0 || row + count > _rows.size() || count==0)
        return;
    beginRemoveRows(QModelIndex(),row, row + count - 1);
    for (int i = 0; i < count; ++i) {
        _rows.removeAt(row);
    }
    endRemoveRows();
}

void FluTreeModel::insertRows(int row,QList<Node*> data){
    if (row < 0 || row > _rows.size() || data.size() == 0)
        return;;
    beginInsertRows(QModelIndex(), row, row + data.size() - 1);
    for (const auto& item : data) {
        _rows.insert(row++, item);
    }
    endInsertRows();
}

QObject* FluTreeModel::getRow(int row){
    return _rows.at(row);
}

void FluTreeModel::setDataSource(QList<QMap<QString,QVariant>> data){
    _dataSource.clear();
    if(_root){
        delete _root;
        _root = nullptr;
    }
    _root = new Node(this);
    std::reverse(data.begin(), data.end());
    while (data.count() > 0) {
        auto item = data.at(data.count()-1);
        data.pop_back();
        Node* node = new Node(this);
        node->_title = item.value("title").toString();
        node->_key = item.value("key").toString();
        node->_depth = item.value("__depth").toInt();
        node->_parent = item.value("__parent").value<Node*>();
        node->_isExpanded = true;
        if(node->_parent){
            node->_parent->_children.append(node);
        }else{
            node->_parent = _root;
            _root->_children.append(node);
        }
        _dataSource.append(node);
        if (item.contains("children")) {
            QList<QVariant> children = item.value("children").toList();
            if(!children.isEmpty()){
                std::reverse(children.begin(), children.end());
                foreach (auto c, children) {
                    auto child = c.toMap();
                    child.insert("__depth",item.value("__depth").toInt(0)+1);
                    child.insert("__parent",QVariant::fromValue(node));
                    data.append(child);
                }
            }
        }
    }
    beginResetModel();
    _rows = _dataSource;
    endResetModel();
    dataSourceSize(_dataSource.size());
}

void FluTreeModel::collapse(int row){
    if(!_rows.at(row)->_isExpanded){
        return;
    }
    _rows.at(row)->_isExpanded = false;
    Q_EMIT dataChanged(index(row,0),index(row,0));
    auto modelData = _rows.at(row);
    int removeCount = 0;
    for(int i=row+1;i<_rows.count();i++){
        auto obj = _rows[i];
        if(obj->_depth<=modelData->_depth){
            break;
        }
        removeCount = removeCount + 1;
    }
    removeRows(row+1,removeCount);
}

void FluTreeModel::expand(int row){
    if(_rows.at(row)->_isExpanded){
        return;
    }
    _rows.at(row)->_isExpanded = true;
    Q_EMIT dataChanged(index(row,0),index(row,0));
    auto modelData = _rows.at(row);
    QList<Node*> insertData;
    QList<Node*> stack = modelData->_children;
    std::reverse(stack.begin(), stack.end());
    while (stack.count() > 0) {
        auto item = stack.at(stack.count()-1);
        stack.pop_back();
        if(item->isShown()){
            insertData.append(item);
        }
        QList<Node*> children = item->_children;
        if(!children.isEmpty()){
            std::reverse(children.begin(), children.end());
            foreach (auto c, children) {
                stack.append(c);
            }
        }
    }
    insertRows(row+1,insertData);
}

void FluTreeModel::dragAnddrop(int dragIndex,int dropIndex){
    if(dragIndex == dropIndex+1){
        return;
    }
    auto dragItem = _rows[dragIndex];
    auto dropItem = _rows[dropIndex];
    if (!beginMoveRows(QModelIndex(), dragIndex, dragIndex, QModelIndex(), dropIndex > dragIndex ? dropIndex+1 : dropIndex)) {
        return;
    }
    if(dragItem->_parent == dropItem->_parent){
        if(dragItem->hasChildren()){

        }else{
            QList<Node*>* children = &(dragItem->_parent->_children);
            int srcIndex = children->indexOf(dragItem);
            int destIndex = children->indexOf(dropItem);
            children->move(srcIndex,destIndex>srcIndex? destIndex : destIndex +1);
            _rows.move(dragIndex,dropIndex>dragIndex? dropIndex : dropIndex+1);
        }
    }else{
        if(dragItem->hasChildren()){

        }else{
            QList<Node*>* srcChildren = &(dragItem->_parent->_children);
            QList<Node*>* destChildren = &(dropItem->_parent->_children);
            int srcIndex = srcChildren->indexOf(dragItem);
            int destIndex = destChildren->indexOf(dropItem);
            dragItem->_depth = dropItem->_depth;
            dragItem->_parent = dropItem->_parent;
            srcChildren->removeAt(srcIndex);
            destChildren->insert(destIndex+1,dragItem);
            _rows.move(dragIndex,dropIndex>dragIndex? dropIndex : dropIndex+1);
        }
    }
    endMoveRows();
}
