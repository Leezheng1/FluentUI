import QtQuick 2.15

QtObject {
    readonly property int flag : 1
    readonly property string key : FluApp.uuid()
    property string title
    property var parent
    property int idx
}
