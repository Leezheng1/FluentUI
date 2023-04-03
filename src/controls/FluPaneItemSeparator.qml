import QtQuick 2.15

QtObject {
    readonly property int flag : 2
    readonly property string key : FluApp.uuid()
    property var parent
    property int idx
}
