import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import MuseScore 3.0
import "ChordPro.js" as ChordPro

MuseScore {
    version: "1.0"
    title: "Gerar Arquivo ChordPro"
    description: qsTr("Identifica acordes da seleção ou partitura e gera o formato ChordPro.")
    pluginType: "dialog"
    categoryCode: "composing-arranging-tools"

    width: 420
    height: 380

    function runIdentifier() {
        if (!curScore) {
            messageBox.text = qsTr("Nenhuma partitura aberta.")
            messageBox.open()
            return
        }

        try {
			
            curScore.startCmd();
		
            var result = ChordPro.generateChordProText();
            curScore.endCmd();

            if (!result) {
                messageBox.text = qsTr("Nenhum texto ou cifra foi localizado.");
                messageBox.open();
                return;
            }

            outputText.text = result;
        } catch (error) {
            try { curScore.endCmd(); } catch (ignored) {}
            messageBox.text = qsTr("Erro ao processar partitura:\n") + error.message;
            messageBox.open();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Label {
            text: qsTr("Gerador ChordPro")
            font.bold: true
            font.pixelSize: 16
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("Gerar ChordPro")
                Layout.fillWidth: true
                onClicked: runIdentifier()
            }

            Button {
                text: qsTr("Copiar Texto")
                enabled: outputText.text.length > 0
                onClicked: {
                    outputText.selectAll();
                    outputText.copy();
                    messageBox.text = qsTr("Texto ChordPro copiado para a área de transferência!");
                    messageBox.open();
                }
            }

            Button {
                text: qsTr("Fechar")
                onClicked: quit()
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextArea {
                id: outputText
                placeholderText: qsTr("O resultado em formato ChordPro aparecerá aqui...")
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                font.family: "Monospace"
            }
        }
    }

    MessageDialog {
        id: messageBox
        title: qsTr("ChordPro")
        text: ""
    }
}