import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Window 2.15
import FluentUI 1.0

FluScrollablePage{

    title:"TimePicker"
    leftPadding:10
    rightPadding:10
    bottomPadding:20

    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 80
        paddings: 10

        ColumnLayout{

            anchors{
                verticalCenter: parent.verticalCenter
                left: parent.left
            }

            FluText{
                text:"hourFormat=FluTimePicker.H"
            }

            FluTimePicker{
            }

        }
    }


    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 80
        paddings: 10

        ColumnLayout{

            anchors{
                verticalCenter: parent.verticalCenter
                left: parent.left
            }

            FluText{
                text:"hourFormat=FluTimePicker.HH"
            }

            FluTimePicker{
                hourFormat:FluTimePicker.HH
            }

        }
    }


}
