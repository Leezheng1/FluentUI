import QtQuick 2.15
import FluentUI 1.0

FluObject {
    readonly property int flag : 3
    readonly property string key : FluApp.uuid()
    property string title
    property int icon
    property bool isExpand: false
    property var parent
    property int idx
    signal tap
    signal repTap
}
