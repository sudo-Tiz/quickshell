import "root:/modules/common"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

ColumnLayout {
    id: root
    spacing: 0
    required property var tabButtonList // Something like [{"icon": "notifications", "name": qsTr("Notifications")}, {"icon": "volume_up", "name": qsTr("Volume mixer")}]
    required property var externalTrackedTab
    property bool enableIndicatorAnimation: false
    property color colIndicator: Appearance?.colors.colPrimary ?? "#65558F"
    property color colBorder: Appearance?.m3colors.m3outlineVariant ?? "#C6C6D0"
    signal currentIndexChanged(int index)

    property bool centerTabBar: parent.width > Math.max(500, parent ? parent.width * 0.4 : 500) // Responsive centering threshold
    Layout.fillWidth: !centerTabBar
    Layout.alignment: Qt.AlignHCenter
    implicitWidth: Math.max(tabBar.implicitWidth, Math.max(600, parent ? parent.width * 0.8 : 600)) // Responsive width

    TabBar {
        id: tabBar
        clip: true
        Layout.fillWidth: true
        currentIndex: root.externalTrackedTab
        onCurrentIndexChanged: {
            root.onCurrentIndexChanged(currentIndex)
        }

        background: Item {
            WheelHandler {
                onWheel: (event) => {
                    if (event.angleDelta.y < 0)
                        tabBar.currentIndex = Math.min(tabBar.currentIndex + 1, root.tabButtonList.length - 1)
                    else if (event.angleDelta.y > 0)
                        tabBar.currentIndex = Math.max(tabBar.currentIndex - 1, 0)
                }
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            }
        }

        Repeater {
            model: root.tabButtonList
            delegate: PrimaryTabButton {
                selected: (index == root.externalTrackedTab)
                buttonText: modelData.name
                buttonIcon: modelData.icon
                // minimumWidth: Math.max(130, parent ? parent.width * 0.18 : 130) // Responsive minimum width
                minimumWidth: 120
            }
        }
    }



    Rectangle { // Tabbar bottom border
        id: tabBarBottomBorder
        Layout.fillWidth: true
        implicitHeight: 1
        color: root.colBorder
    }
}
