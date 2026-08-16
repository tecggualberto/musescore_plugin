import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// MuseScore 4.7 still exposes the QML plugin API as MuseScore 3.0.
// The application version and plugin API version are not the same thing.
import MuseScore 3.0

import "ChordScanner.js" as ChordScanner

MuseScore {
    version: "2.0"
    title: "Identificador de Acordes v2"
    description: qsTr("Identifica acordes da seleção e insere cifras.")
    pluginType: "dialog"
    categoryCode: "composing-arranging-tools"
    thumbnailName: "ChordIdentifier.png"

    width: 360
    height: 190

    property bool overwriteExisting: false
   property bool tipoCifra:true

    onRun: {
        if (!curScore) {
            messageBox.text = qsTr("Abra uma partitura antes de executar o plugin.")
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
          
			curScore.startCmd();
            var options = {
                overwriteExisting: overwriteExisting,
             
            }
			ChordScanner.tipoCifra = tipoCifra;
            var result = ChordScanner.runsheet(options,curScore);
			curScore.endCmd();	
           

            messageBox.text = result.message
            messageBox.open()
        } catch (error) {
            try {
               curScore.endCmd(); 
            } catch (ignored) {
            }

            messageBox.text = qsTr("Erro ao identificar acordes:\n") + error.message
            messageBox.open()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Label {
            text: qsTr("Identificador de Acordes v2")
            font.bold: true
            Layout.fillWidth: true
        }

        CheckBox {
            text: qsTr("Substituir cifras existentes")
            checked: overwriteExisting
            onCheckedChanged: overwriteExisting = checked
            Layout.fillWidth: true
        }

        CheckBox {
           text: qsTr("Símbolos (C, G7) ou  Números Romanos (I, IV)")
            checked: tipoCifra
            onCheckedChanged: ChordScanner.tipoCifra = (tipoCifra)?0:1
            Layout.fillWidth: true
        }
		
     

       
		


        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("Identificar acordes")
                Layout.fillWidth: true
                onClicked: runIdentifier()
            }

            Button {
                text: qsTr("Cancelar")
                onClicked: quit()
            }
        }

        Label {
            text: qsTr("Analisa a seleção; sem seleção, analisa a partitura.")
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    MessageDialog {
        id: messageBox
        title: qsTr("Identificador de Acordes")
        text: ""
        onAccepted: quit()
    }
}
