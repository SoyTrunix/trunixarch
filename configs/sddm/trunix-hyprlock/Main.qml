import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#1e1e2e"

    readonly property color ctpBase: "#1e1e2e"
    readonly property color ctpText: "#cdd6f4"
    readonly property color ctpSurface: "#45475a"
    readonly property color ctpBlue: "#89b4fa"
    readonly property color ctpRed: "#f38ba8"
    readonly property color fieldFill: Qt.rgba(30/255, 30/255, 46/255, 0.8)

    // ---------- Fondo con blur ----------
    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://__WALLPAPER__"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        visible: false
    }

    FastBlur {
        anchors.fill: wallpaper
        source: wallpaper
        radius: 48
        visible: true
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.15)
    }

    // ---------- Reloj ----------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -160
        spacing: 8

        Text {
            id: clockLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(new Date(), "hh:mm")
            color: ctpText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 90
            font.bold: true
            style: Text.Raised
            styleColor: Qt.rgba(0, 0, 0, 0.35)
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(new Date(), "dddd, d MMMM")
            color: ctpText
            opacity: 0.75
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockLabel.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }

    // ---------- Panel de login ----------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 60
        spacing: 14
        width: 300

        // Usuario (ComboBox con userModel)
        ComboBox {
            id: userBox
            width: 300
            height: 54
            model: userModel
            textRole: "name"
            currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0

            background: Rectangle {
                color: fieldFill
                radius: 10
                border.color: ctpBlue
                border.width: 3
            }
            contentItem: Text {
                anchors.fill: parent
                text: userBox.displayText
                color: ctpText
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            popup: Popup {
                y: userBox.height + 4
                width: userBox.width
                implicitHeight: contentItem.implicitHeight
                padding: 4
                background: Rectangle {
                    color: ctpBase
                    radius: 10
                    border.color: ctpSurface
                    border.width: 1
                }
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: userBox.popup.visible ? userBox.delegateModel : null
                    currentIndex: userBox.highlightedIndex
                }
            }
            delegate: ItemDelegate {
                width: userBox.width
                contentItem: Text {
                    text: model.name
                    color: ctpText
                    font.family: "JetBrainsMono Nerd Font"
                    leftPadding: 10
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: highlighted ? ctpSurface : "transparent"
                }
            }
        }

        // Contraseña
        TextField {
            id: passwordField
            width: 300
            height: 60
            echoMode: TextInput.Password
            placeholderText: "Password..."
            placeholderTextColor: Qt.rgba(205/255, 214/255, 244/255, 0.5)
            color: ctpText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            horizontalAlignment: TextInput.AlignHCenter
            selectByMouse: true
            focus: true

            background: Rectangle {
                color: fieldFill
                radius: 10
                border.color: ctpBlue
                border.width: 3
            }

            Keys.onReturnPressed: loginButton.doLogin()
            Keys.onEnterPressed: loginButton.doLogin()
        }

        // Mensaje de error
        Text {
            id: errorLabel
            anchors.horizontalCenter: parent.horizontalCenter
            color: ctpRed
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            text: ""
            visible: text.length > 0
        }

        // Selector de sesión/entorno
        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            ComboBox {
                id: sessionBox
                width: 300
                height: 40
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

                background: Rectangle {
                    color: fieldFill
                    radius: 10
                    border.color: ctpSurface
                    border.width: 1
                }
                contentItem: Text {
                    leftPadding: 10
                    rightPadding: 22
                    text: sessionBox.displayText
                    color: ctpText
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    clip: true
                }
            }
        }

        // Botón de login
        Rectangle {
            id: loginButton
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300
            height: 46
            radius: 10
            color: loginMouse.pressed ? Qt.darker(ctpBlue, 1.2) : ctpBlue

            function doLogin() {
                errorLabel.text = ""
                sddm.login(userBox.currentText, passwordField.text, sessionBox.currentIndex)
            }

            Text {
                anchors.centerIn: parent
                text: "Ingresar"
                color: ctpBase
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                font.pixelSize: 15
            }

            MouseArea {
                id: loginMouse
                anchors.fill: parent
                onClicked: loginButton.doLogin()
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorLabel.text = "Usuario o contraseña incorrectos"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
