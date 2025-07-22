import "root:/modules/common"
import "root:/modules/common/widgets"
import "root:/services"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

Item {
    id: root
    property list<NotificationWidget> notificationWidgetList: []
    property int maxNotifications: ConfigOptions.notifications ? ConfigOptions.notifications.maxCount : 10

    // Signal handlers to add/remove notifications
    Connections {
        target: Notifications
        function onInitDone() {
            // Filter out any null notifications before processing
            const validNotifications = Notifications.list.filter(notification => notification != null);
            validNotifications.slice().reverse().forEach((notification) => {
                if (!notification) return; // Skip null notifications
                try {
                    const notif = notificationComponent.createObject(columnLayout, { notificationObject: notification });
                    if (notif) {
                        notificationWidgetList.push(notif)
                    }
                } catch (error) {
                    // Error handling disabled
                }
            })
        }

        function onNotify(notification) {
            if (!notification) return; // Skip null notifications
            try {
                const notif = notificationComponent.createObject(columnLayout, { notificationObject: notification });
                if (notif) {
                    notificationWidgetList.unshift(notif)
                }
            } catch (error) {
                // Error handling disabled
            }

            // Remove stuff from the column, add back
            for (let i = 0; i < notificationWidgetList.length; i++) {
                if (notificationWidgetList[i].parent === columnLayout) {
                    notificationWidgetList[i].parent = null;
                }
            }

            // Add notification widgets to the column
            for (let i = 0; i < notificationWidgetList.length; i++) {
                if (notificationWidgetList[i].parent === null) {
                    notificationWidgetList[i].parent = columnLayout;
                }
            }
        }

        function onDiscard(id) {
            for (let i = notificationWidgetList.length - 1; i >= 0; i--) {
                const widget = notificationWidgetList[i];
                if (widget && widget.notificationObject && widget.notificationObject.id === id) {
                    widget.destroyWithAnimation();
                    notificationWidgetList.splice(i, 1);
                    break;
                }
            }
        }

        function onDiscardAll() {
            for (let i = notificationWidgetList.length - 1; i >= 0; i--) {
                const widget = notificationWidgetList[i];
                if (widget) {
                    widget.destroyWithAnimation();
                }
            }
            notificationWidgetList = [];
        }

        function onTimeout(id) {
            for (let i = notificationWidgetList.length - 1; i >= 0; i--) {
                const widget = notificationWidgetList[i];
                if (widget && widget.notificationObject && widget.notificationObject.id === id) {
                    widget.destroyWithAnimation();
                    // notificationWidgetList.splice(i, 1);
                    break;
                }
            }
        }
    }

    Component {
        id: notificationComponent
        NotificationWidget {}
    }

    Component.onCompleted: {
        // Component completed
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Notifications Section (now full height)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true // Fills all available space
            radius: Appearance.rounding.large
            color: Qt.rgba(
                Appearance.colors.colLayer1.r,
                Appearance.colors.colLayer1.g,
                Appearance.colors.colLayer1.b,
                0.3
            )
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Item { Layout.fillWidth: true }

                    StyledText {
                        text: `${(notificationWidgetList?.length ?? 0)} notification${(notificationWidgetList?.length ?? 0) > 1 ? "s" : ""}`
                        font.pixelSize: Appearance.font.pixelSize.tiny
                        color: Appearance.colors.colOnLayer1
                        opacity: 0.7
                        visible: (notificationWidgetList?.length ?? 0) > 0
                    }

                    NotificationStatusButton {
                        buttonIcon: "clear_all"
                        buttonText: qsTr("Clear")
                        onClicked: () => {
                            Notifications.discardAllNotifications()
                        }
                    }
                }

                // Scrollable notifications content
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Flickable {
                        id: flickable
                        anchors.fill: parent
                        contentHeight: columnLayout.height
                        clip: true

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: flickable.width
                                height: flickable.height
                                radius: Appearance.rounding.large
                            }
                        }

                        ColumnLayout {
                            id: columnLayout
                            width: parent.width
                            spacing: 0

                            // Notifications are added by the above signal handlers
                        }
                    }

                    // Placeholder when list is empty
                    Item {
                        anchors.fill: flickable
                        visible: opacity > 0
                        opacity: (root.notificationWidgetList ? root.notificationWidgetList.length : 0) === 0 ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Appearance.animation.menuDecel.duration
                                easing.type: Appearance.animation.menuDecel.type
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 5

                            // Removed MaterialSymbol icon to avoid duplicate large bell
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                text: qsTr("No notifications")
                            }
                        }
                    }
                }
            }
        }

        // Media Player Section (50% height)
        // Rectangle {
        //     Layout.fillWidth: true
        //     Layout.fillHeight: true // Fills remaining space
        //     radius: Appearance.rounding.large
        //     color: Qt.rgba(
        //         Appearance.colors.colLayer1.r,
        //         Appearance.colors.colLayer1.g,
        //         Appearance.colors.colLayer1.b,
        //         0.3
        //     )
        //     border.color: Qt.rgba(1, 1, 1, 0.1)
        //     border.width: 1
        //
        //     SimpleMediaPlayerSidebar {
        //         anchors.fill: parent
        //     }
        // }
    }
}
