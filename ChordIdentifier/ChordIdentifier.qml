import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// MuseScore 4.7 still exposes the QML plugin API as MuseScore 3.0.
import MuseScore 3.0

import "ChordScanner.js" as ChordScanner

MuseScore {
    version: "2.0"
    title: "Identificador de Acordes v2"
    description: qsTr("Identifica acordes da seleção e insere cifras.")
    pluginType: "dialog"
    categoryCode: "composing-arranging-tools"
    thumbnailName: "ChordIdentifier.png"

    width: 430
    height: 380

    property bool overwriteExisting: false

    // 0 = Símbolos
    // 1 = Números Romanos
    property int tipoCifra: 0

    onRun: {
        if (!curScore) {
            messageBox.text = qsTr(
                "Abra uma partitura antes de executar o plugin."
            )
            messageBox.open()
            return
        }
    }

    function runIdentifier() {
        if (!curScore) {
            messageBox.text = qsTr("Nenhuma partitura aberta.")
            messageBox.open()
            return
        }

        try {
            curScore.startCmd()

            var options = {
                overwriteExisting: overwriteExisting
            }

            var result = ChordScanner.runsheet(
                options,
                curScore,
                tipoCifra
            )

            curScore.endCmd()

            messageBox.text = result.message
            messageBox.open()

        } catch (error) {

            try {
                curScore.endCmd()
            } catch (ignored) {
            }

            messageBox.text =
                qsTr("Erro ao identificar acordes:\n") +
                error.message

            messageBox.open()
        }
    }

    // ============================================================
    // INTERFACE
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // --------------------------------------------------------
        // CABEÇALHO
        // --------------------------------------------------------

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Label {
                text: qsTr("Identificador de Acordes")
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Identifique os acordes da seleção ou da partitura.")
                font.pixelSize: 12
                opacity: 0.65
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // --------------------------------------------------------
        // SEPARADOR
        // --------------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            height: 1
            opacity: 0.15
        }

        // --------------------------------------------------------
        // OPÇÕES
        // --------------------------------------------------------

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: qsTr("Opções")
                font.bold: true
                font.pixelSize: 13
                Layout.fillWidth: true
            }

            // ----------------------------------------------------
            // TIPO DE CIFRA
            // ----------------------------------------------------

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Label {
                    text: qsTr("Tipo de cifra:")
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox {
                    id: tipoCifraCombo

                    Layout.preferredWidth: 190

                    model: [
                        qsTr("Símbolos (C, G7, Am...)"),
                        qsTr("Números Romanos (I, IV, V...)")
                    ]

                    currentIndex: tipoCifra

                    onCurrentIndexChanged: {
                        tipoCifra = currentIndex
                    }
                }
            }

            // ----------------------------------------------------
            // SUBSTITUIR CIFRAS
            // ----------------------------------------------------

            CheckBox {
                id: overwriteCheck

                text: qsTr("Substituir cifras existentes")
                checked: overwriteExisting

                onCheckedChanged: {
                    overwriteExisting = checked
                }

                Layout.fillWidth: true
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // --------------------------------------------------------
        // INFORMAÇÃO
        // --------------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42

            radius: 6

            opacity: 0.08

            Label {
                anchors.fill: parent
                anchors.margins: 10

                text: qsTr(
                    "Dica: selecione um trecho para analisar apenas a seleção. "
                    + "Sem seleção, toda a partitura será analisada."
                )

                font.pixelSize: 11
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                opacity: 0.8
            }
        }

        // --------------------------------------------------------
        // BOTÕES
        // --------------------------------------------------------

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: qsTr("Identificar acordes")

                Layout.fillWidth: true
                Layout.preferredHeight: 38

                highlighted: true

                onClicked: {
                    runIdentifier()
                }
            }

            Button {
                text: qsTr("Cancelar")

                Layout.preferredWidth: 90
                Layout.preferredHeight: 38

                onClicked: {
                    quit()
                }
            }
        }
    }

    // ============================================================
    // MENSAGEM
    // ============================================================

    MessageDialog {
        id: messageBox

        title: qsTr("Identificador de Acordes")

        text: ""

        onAccepted: {
            quit()
        }
    }
}
