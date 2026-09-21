import QtQuick
import QtQuick.Layouts

import "../code" as Code

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 8

    property real accumulator: 0
    property string pendingOp: ""
    property bool freshEntry: true
    property string display: "0"

    function digitPressed(d) {
        if (root.freshEntry || root.display === "0") {
            root.display = d
            root.freshEntry = false
        } else {
            root.display = root.display + d
        }
    }

    function decimalPressed() {
        if (root.freshEntry) {
            root.display = "0."
            root.freshEntry = false
            return
        }
        if (root.display.indexOf(".") === -1) {
            root.display = root.display + "."
        }
    }

    function clearPressed() {
        root.accumulator = 0
        root.pendingOp = ""
        root.freshEntry = true
        root.display = "0"
    }

    function applyPending() {
        var current = parseFloat(root.display)
        switch (root.pendingOp) {
        case "+":
            root.accumulator += current
            break
        case "-":
            root.accumulator -= current
            break
        case "*":
            root.accumulator *= current
            break
        case "/":
            root.accumulator = current !== 0 ? root.accumulator / current : 0
            break
        default:
            root.accumulator = current
        }
    }

    function opPressed(op) {
        if (root.pendingOp !== "" && !root.freshEntry) {
            root.applyPending()
        } else {
            root.accumulator = parseFloat(root.display)
        }
        root.pendingOp = op
        root.freshEntry = true
        root.display = root._format(root.accumulator)
    }

    function equalsPressed() {
        if (root.pendingOp === "") {
            return
        }
        root.applyPending()
        root.pendingOp = ""
        root.freshEntry = true
        root.display = root._format(root.accumulator)
    }

    function _format(n) {
        if (Number.isInteger(n)) {
            return String(n)
        }
        return String(Math.round(n * 1e8) / 1e8)
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: 10
        color: Code.Theme.card
        border.width: 1
        border.color: Code.Theme.borderColor

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 12
            text: root.display
            color: Code.Theme.textPrimary
            font.pixelSize: 20
            font.bold: true
            elide: Text.ElideLeft
            width: parent.width - 24
            horizontalAlignment: Text.AlignRight
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 4
        rowSpacing: 6
        columnSpacing: 6

        component CalcButton: Rectangle {
            id: btn
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            property string label: ""
            property bool accent: false
            color: mouse.containsMouse
                   ? Code.Theme.cardHover
                   : (btn.accent ? Qt.rgba(Code.Theme.neonRed.r, Code.Theme.neonRed.g, Code.Theme.neonRed.b, 0.18) : Code.Theme.card)
            border.width: 1
            border.color: btn.accent ? Code.Theme.neonRed : Code.Theme.borderColor

            signal pressed()

            Text {
                anchors.centerIn: parent
                text: btn.label
                color: btn.accent ? Code.Theme.neonRed : Code.Theme.textPrimary
                font.pixelSize: 14
                font.bold: true
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: btn.pressed()
            }
        }

        CalcButton { label: "C"; accent: true; onPressed: root.clearPressed() }
        CalcButton { label: "÷"; accent: true; onPressed: root.opPressed("/") }
        CalcButton { label: "×"; accent: true; onPressed: root.opPressed("*") }
        CalcButton { label: "−"; accent: true; onPressed: root.opPressed("-") }

        CalcButton { label: "7"; onPressed: root.digitPressed("7") }
        CalcButton { label: "8"; onPressed: root.digitPressed("8") }
        CalcButton { label: "9"; onPressed: root.digitPressed("9") }
        CalcButton { label: "+"; accent: true; Layout.rowSpan: 2; onPressed: root.opPressed("+") }

        CalcButton { label: "4"; onPressed: root.digitPressed("4") }
        CalcButton { label: "5"; onPressed: root.digitPressed("5") }
        CalcButton { label: "6"; onPressed: root.digitPressed("6") }

        CalcButton { label: "1"; onPressed: root.digitPressed("1") }
        CalcButton { label: "2"; onPressed: root.digitPressed("2") }
        CalcButton { label: "3"; onPressed: root.digitPressed("3") }
        CalcButton { label: "="; accent: true; Layout.rowSpan: 2; onPressed: root.equalsPressed() }

        CalcButton { label: "0"; Layout.columnSpan: 2; onPressed: root.digitPressed("0") }
        CalcButton { label: "."; onPressed: root.decimalPressed() }
    }
}
