﻿import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Item {

    enum DisplayMode {
        Open,
        Top,
        Compact,
        Minimal,
        Auto
    }

    property url logo
    property string title: ""
    property FluObject items
    property FluObject footerItems
    property int displayMode: FluNavigationView2.Open
    property Component  autoSuggestBox
    property var window : {
        if(Window.window == null)
            return null
        return Window.window
    }

    id:control

    QtObject{
        id:d
        property bool enableStack: true
        property var stackItems: []
        property bool enableNavigationPanel: false
        function handleItems(){
            var idx = 0
            var data = []
            if(items){
                for(var i=0;i<items.children.length;i++){
                    var item = items.children[i]
                    item.idx = idx
                    data.push(item)
                    idx++
                    if(item instanceof FluPaneItemExpander){
                        for(var j=0;j<item.children.length;j++){
                            var itemChild = item.children[j]
                            itemChild.parent = item
                            itemChild.idx = idx
                            data.push(itemChild)
                            idx++
                        }
                    }
                }
                if(footerItems){
                    var comEmpty = Qt.createComponent("FluPaneItemEmpty.qml");
                    for(var k=0;k<footerItems.children.length;k++){
                        var itemFooter = footerItems.children[k]
                        if (comEmpty.status === Component.Ready) {
                            var objEmpty = comEmpty.createObject(items,{idx:idx});
                            itemFooter.idx = idx;
                            data.push(objEmpty)
                            idx++
                        }
                    }
                }
            }
            return data
        }
    }

    Component{
        id:com_panel_item_empty
        Item{
            visible: false
        }
    }

    Component{
        id:com_panel_item_separatorr
        FluDivider{
            width: layout_list.width
            height: {
                if(model.parent){
                    return model.parent.isExpand ? 1 : 0
                }
                return 1
            }
            Behavior on height {
                NumberAnimation{
                    duration: 150
                }
            }
        }
    }

    Component{
        id:com_panel_item_header
        Item{
            height: {
                if(model.parent){
                    return model.parent.isExpand ? 30 : 0
                }
                return 30
            }
            Behavior on height {
                NumberAnimation{
                    duration: 150
                }
            }
            width: layout_list.width
            FluText{
                text:model.title
                fontStyle: FluText.BodyStrong
                anchors{
                    bottom: parent.bottom
                    left:parent.left
                    leftMargin: 10
                }
            }
        }
    }

    Component{
        id:com_panel_item_expander
        Item{
            height: 38
            width: layout_list.width
            Rectangle{
                radius: 4
                anchors{
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 2
                    bottomMargin: 2
                    leftMargin: 6
                    rightMargin: 6
                }
                Rectangle{
                    width: 3
                    height: 18
                    radius: 1.5
                    color: FluTheme.primaryColor.dark
                    visible: {
                        for(var i=0;i<model.children.length;i++){
                            var item = model.children[i]
                            if(item.idx === nav_list.currentIndex && !model.isExpand){
                                return true
                            }
                        }
                        return false
                    }
                    anchors{
                        verticalCenter: parent.verticalCenter
                    }
                }
                FluIcon{
                    rotation: model.isExpand?0:180
                    iconSource:FluentIcons.ChevronUp
                    iconSize: 15
                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 12
                    }
                    visible: {
                        if(displayMode === FluNavigationView2.Compact){
                            return false
                        }
                        return true
                    }
                    Behavior on rotation {
                        NumberAnimation{
                            duration: 150
                        }
                    }
                }
                MouseArea{
                    id:item_mouse
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        if(displayMode === FluNavigationView2.Compact){

                            return
                        }
                        model.isExpand = !model.isExpand

                    }
                }
                color: {
                    if(FluTheme.dark){
                        if((nav_list.currentIndex === idx)&&type===0){
                            return Qt.rgba(1,1,1,0.06)
                        }
                        if(item_mouse.containsMouse){
                            return Qt.rgba(1,1,1,0.03)
                        }
                        return Qt.rgba(0,0,0,0)
                    }else{
                        if(nav_list.currentIndex === idx&&type===0){
                            return Qt.rgba(0,0,0,0.06)
                        }
                        if(item_mouse.containsMouse){
                            return Qt.rgba(0,0,0,0.03)
                        }
                        return Qt.rgba(0,0,0,0)
                    }
                }
                FluIcon{
                    id:item_icon
                    iconSource: {
                        if(model.icon){
                            return model.icon
                        }
                        return 0
                    }
                    width: 30
                    height: 30
                    iconSize: 15
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left:parent.left
                        leftMargin: 3
                    }
                }
                FluText{
                    id:item_title
                    text:model.title
                    visible: {
                        if(displayMode === FluNavigationView2.Compact){
                            return false
                        }
                        return true
                    }
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left:item_icon.right
                    }
                    color:{
                        if(item_mouse.pressed){
                            return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120
                        }
                        return FluTheme.dark ? FluColors.White : FluColors.Grey220
                    }
                }
            }
        }
    }

    Component{
        id:com_panel_item
        Item{
            Behavior on height {
                NumberAnimation{
                    duration: 150
                }
            }
            clip: true
            height: {
                if(model.parent){
                    return model.parent.isExpand ? 38 : 0
                }
                return 38
            }
            width: layout_list.width
            Rectangle{
                radius: 4
                anchors{
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 2
                    bottomMargin: 2
                    leftMargin: 6
                    rightMargin: 6
                }
                MouseArea{
                    id:item_mouse
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        if(type === 0){
                            if(model.tapFunc){
                                model.tapFunc()
                            }else{
                                nav_list.currentIndex = idx
                                layout_footer.currentIndex = -1
                            }
                        }else{
                            if(model.tapFunc){
                                model.tapFunc()
                            }else{
                                model.tap()
                                d.stackItems.push(model)
                                nav_list.currentIndex = nav_list.count-layout_footer.count+idx
                                layout_footer.currentIndex = idx
                            }
                        }
                    }
                }
                color: {
                    if(FluTheme.dark){
                        if(type===0){
                            if(nav_list.currentIndex === idx){
                                return Qt.rgba(1,1,1,0.06)
                            }
                        }else{
                            if(nav_list.currentIndex === (nav_list.count-layout_footer.count+idx)){
                                return Qt.rgba(1,1,1,0.06)
                            }
                        }
                        if(item_mouse.containsMouse){
                            return Qt.rgba(1,1,1,0.03)
                        }
                        return Qt.rgba(0,0,0,0)
                    }else{
                        if(type===0){
                            if(nav_list.currentIndex === idx){
                                return Qt.rgba(0,0,0,0.06)
                            }
                        }else{
                            if(nav_list.currentIndex === (nav_list.count-layout_footer.count+idx)){
                                return Qt.rgba(0,0,0,0.06)
                            }
                        }
                        if(item_mouse.containsMouse){
                            return Qt.rgba(0,0,0,0.03)
                        }
                        return Qt.rgba(0,0,0,0)
                    }
                }
                FluIcon{
                    id:item_icon
                    iconSource: {
                        if(model.icon){
                            return model.icon
                        }
                        return 0
                    }
                    width: 30
                    height: 30
                    iconSize: 15
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left:parent.left
                        leftMargin: 3
                    }
                }
                FluText{
                    id:item_title
                    text:model.title
                    visible: {
                        if(displayMode === FluNavigationView2.Compact){
                            return false
                        }
                        return true
                    }
                    color:{
                        if(item_mouse.pressed){
                            return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120
                        }
                        return FluTheme.dark ? FluColors.White : FluColors.Grey220
                    }
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left:item_icon.right
                    }
                }
            }
        }
    }


    Item {
        id:nav_app_bar
        width: parent.width
        height: 50
        z:999
        RowLayout{
            height:parent.height
            spacing: 0
            FluIconButton{
                iconSource: FluentIcons.ChromeBack
                Layout.leftMargin: 5
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter
                disabled:  nav_swipe.depth === 1
                iconSize: 13
                onClicked: {
                    nav_swipe.pop()
                    d.stackItems.pop()
                    var item = d.stackItems[d.stackItems.length-1]
                    d.enableStack = false
                    if(item.idx<(nav_list.count - layout_footer.count)){
                        layout_footer.currentIndex = -1
                    }else{
                        console.debug(item.idx-(nav_list.count-layout_footer.count))
                        layout_footer.currentIndex = item.idx-(nav_list.count-layout_footer.count)
                    }
                    nav_list.currentIndex = item.idx
                    d.enableStack = true
                }
            }
            FluIconButton{
                id:btn_nav
                iconSource: FluentIcons.GlobalNavButton
                iconSize: 15
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                visible: displayMode === FluNavigationView2.Minimal
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    d.enableNavigationPanel = !d.enableNavigationPanel
                }
            }
            Image{
                id:image_logo
                Layout.preferredHeight: 20
                Layout.preferredWidth: 20
                source: control.logo
                Layout.leftMargin: {
                    if(btn_nav.visible){
                        return 12
                    }
                    return 5
                }
                Layout.alignment: Qt.AlignVCenter
            }
            FluText{
                Layout.alignment: Qt.AlignVCenter
                text:control.title
                Layout.leftMargin: 12
                fontStyle: FluText.Body
            }
        }
    }

    Item{
        anchors{
            left: displayMode === FluNavigationView2.Minimal ? parent.left : layout_list.right
            top: nav_app_bar.bottom
            right: parent.right
            bottom: parent.bottom
        }
        StackView{
            id:nav_swipe
            anchors.fill: parent
            clip: true
            popEnter : Transition{}
            popExit : Transition {
                NumberAnimation { properties: "y"; from: 0; to: nav_swipe.height; duration: 200 }
            }
            pushEnter: Transition {
                NumberAnimation { properties: "y"; from: nav_swipe.height; to: 0; duration: 200 }
            }
            pushExit : Transition{}
            replaceEnter : Transition{}
            replaceExit : Transition{}
        }
    }

    MouseArea{
        anchors.fill: parent
        enabled: (displayMode === FluNavigationView2.Minimal && d.enableNavigationPanel)
        onClicked: {
            d.enableNavigationPanel = false
        }
    }

    Rectangle{
        id:layout_list
        width: {
            if(displayMode === FluNavigationView2.Compact){
                return 50
            }
            return 300
        }
        anchors{
            top: parent.top
            bottom: parent.bottom
        }
        border.color: FluTheme.dark ? Qt.rgba(45/255,45/255,45/255,1) : Qt.rgba(226/255,230/255,234/255,1)
        border.width:  displayMode === FluNavigationView2.Minimal ? 1 : 0
        color: {
            if(displayMode === FluNavigationView2.Minimal){
                return FluTheme.dark ? Qt.rgba(61/255,61/255,61/255,1) : Qt.rgba(243/255,243/255,243/255,1)
            }
            if(window && window.active){
                return FluTheme.dark ? Qt.rgba(32/255,32/255,32/255,1) : Qt.rgba(238/255,244/255,249/255,1)
            }
            return FluTheme.dark ? Qt.rgba(32/255,32/255,32/255,1) : Qt.rgba(243/255,243/255,243/255,1)
        }
        Behavior on color{
            ColorAnimation {
                duration: 300
            }
        }
        x: {
            if(displayMode !== FluNavigationView2.Minimal)
                return 0
            return (displayMode === FluNavigationView2.Minimal && d.enableNavigationPanel)  ? 0 : -width
        }
        Item{
            id:layout_header
            width: layout_list.width
            clip: true
            y:nav_app_bar.height
            height: 38
            Loader{
                id:loader_auto_suggest_box
                anchors.centerIn: parent
                sourceComponent: autoSuggestBox
                visible: {
                    if(displayMode === FluNavigationView2.Compact){
                        return false
                    }
                    return true
                }
            }

            FluIconButton{
                visible:displayMode === FluNavigationView2.Compact
                hoverColor: FluTheme.dark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.03)
                pressedColor: FluTheme.dark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.03)
                normalColor: FluTheme.dark ? Qt.rgba(0,0,0,0) : Qt.rgba(0,0,0,0)
                width:38
                height:34
                x:6
                y:2
                iconSize: 15
                iconSource: {
                    if(loader_auto_suggest_box.item){
                        return loader_auto_suggest_box.item.autoSuggestBoxReplacement
                    }
                    return 0
                }
            }
        }

        ListView{
            id:nav_list
            clip: true
            ScrollBar.vertical: FluScrollBar {}
            model:d.handleItems()
            highlightMoveDuration: 150
            highlight: Item{
                clip: true
                Rectangle{
                    height: 18
                    radius: 1.5
                    color: FluTheme.primaryColor.dark
                    width: 3
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 6
                    }
                }
            }
            onCurrentIndexChanged: {
                if(d.enableStack){
                    var item = model[currentIndex]
                    if(item instanceof FluPaneItem){
                        item.tap()
                        d.stackItems.push(item)
                    }
                }
            }
            currentIndex: -1
            anchors{
                top: layout_header.bottom
                topMargin: 6
                left: parent.left
                right: parent.right
                bottom: layout_footer.top
            }
            delegate: Loader{
                property var model: modelData
                property var idx: index
                property int type: 0
                sourceComponent: {
                    if(modelData instanceof FluPaneItem){
                        return com_panel_item
                    }
                    if(modelData instanceof FluPaneItemHeader){
                        return com_panel_item_header
                    }
                    if(modelData instanceof FluPaneItemSeparator){
                        return com_panel_item_separatorr
                    }
                    if(modelData instanceof FluPaneItemExpander){
                        return com_panel_item_expander
                    }
                    if(modelData instanceof FluPaneItemEmpty){
                        return com_panel_item_empty
                    }
                }
            }
        }
        ListView{
            id:layout_footer
            clip: true
            width: layout_list.width
            height: childrenRect.height
            anchors.bottom: parent.bottom
            interactive: false
            currentIndex: -1
            model: {
                if(footerItems){
                    return footerItems.children
                }
            }
            highlightMoveDuration: 150
            highlight: Item{
                clip: true
                Rectangle{
                    height: 18
                    radius: 1.5
                    color: FluTheme.primaryColor.dark
                    width: 3
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 6
                    }
                }
            }
            delegate: Loader{
                property var model: modelData
                property var idx: index
                property int type: 1
                sourceComponent: {
                    if(modelData instanceof FluPaneItem){
                        return com_panel_item
                    }
                    if(modelData instanceof FluPaneItemHeader){
                        return com_panel_item_header
                    }
                    if(modelData instanceof FluPaneItemSeparator){
                        return com_panel_item_separatorr
                    }
                }
            }
        }
    }

    function setCurrentIndex(index){
        nav_list.currentIndex = index
    }

    function getItems(){
        return nav_list.model
    }

    function push(url){
        nav_swipe.push(url)
    }

    function getCurrentIndex(){
        return nav_list.currentIndex
    }

}