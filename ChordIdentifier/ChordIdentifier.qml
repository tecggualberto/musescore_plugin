import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import MuseScore 3.0
import Muse.UiComponents 1.0

MuseScore {
	version: "1.0"
	title: "Identificador de Acordes"
	description: qsTr("Identifica acordes a partir das notas na partitura.")
	pluginType: "dialog"
	categoryCode: "composing-arranging-tools"
	thumbnailName: "ChordIdentifier.png"


	width: 300
	height: 124


	property var notesWithSharps: ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
	property var notesWithFlats: ['C', 'D♭', 'D', 'E♭', 'E', 'F', 'G♭', 'G', 'A♭', 'A', 'B♭', 'B'];
	property var notesWithSharpsRoman: ['I', 'I#', 'II', 'II#', 'III', 'IV', 'IV#', 'V', 'V#', 'VI', 'VI#', 'VII'];
	property var notesWithFlatsRoman: ['i', 'i♭', 'ii', 'ii♭', 'iii', 'iv', 'v♭', 'v', 'vi♭', 'vi', 'vii♭', 'vii'];
	property var chordsRoman: {

		"BDF": "VII°","DFB": "VII°","FBD": "VII°",
		"D#F##A#": "II#","F##A#D#": "II#",
		"A#D#F##": "II#",	"BE♭♭F": "vii°",
		"E♭♭FB": "vii°",	"FBE♭♭": "vii°"
	};
	property var acordesSeparadoTraco:"";
	property var  notaBase:"";
	property var dictAcorde:[];
	property var chords: {

		"A#F##D#": "D#","E#G##B#": "E#","G##B#E#": "E#","B#E#G##": "E#",
		"B#D##F##": "B#","D##F##B#": "B#","F##B#D##": "B#",	"D♭F♭♭A♭": "D♭",
		"F♭♭A♭D♭": "D♭","A♭D♭F♭♭": "D♭","A♭F♭♭D♭": "D♭","E♭G♭♭B♭": "E♭",
		"G♭♭B♭E♭": "E♭",
		"B♭E♭G♭♭": "E♭",
		"F♭A♭C♭": "F♭",
		"A♭C♭F♭": "F♭",
		"C♭F♭A♭": "F♭",
		"G♭B♭D♭": "G♭",
		"B♭D♭G♭": "G♭",
		"D♭G♭B♭": "G♭",
		"A♭C♭E♭": "A♭",
		"C♭E♭A♭": "A♭",
		"E♭A♭C♭": "A♭",
		"B♭D♭♭F♭♭": "B♭",
		"D♭♭F♭♭B♭": "B♭",
		"F♭♭B♭D♭♭": "B♭",
		"BDF": "B°",
		"DFB": "B°",
		"FBD": "B°",
		"BE♭♭F": "Bm",
		"E♭♭FB": "Bm",
		"FBE♭♭": "Bm",
		// Acordes Maiores com Inversões
		

	};
	
	onRun: {
		if (!curScore) {
			message("No score open.\nThis plugin requires an open score to run.\n", "Error")
			quit()
		}
	}
	function runsheet() {
		try {


			var cursor = curScore.newCursor();
			var startStaff;
			var endStaff;
			var endTick;
			var fullScore = false;
			cursor.rewind(1);
			if (!cursor.segment) { // no selection
				fullScore = true;
				startStaff = 0; // start with 1st staff
				endStaff = curScore.nstaves - 1; // and end with last
			} else {
				startStaff = cursor.staffIdx;
				cursor.rewind(2);
				if (cursor.tick === 0) {
					// this happens when the selection includes
					// the last measure of the score.
					// rewind(2) goes behind the last segment (where
					// there's none) and sets tick=0
					endTick = curScore.lastSegment.tick + 1;
				} else {
					endTick = cursor.tick;
				}
				endStaff = cursor.staffIdx;
			}
			console.log(startStaff + " - " + endStaff + " - " + endTick)

			for (var staff = startStaff; staff <= endStaff; staff++) {
				for (var voice = 0; voice < 4; voice++) {
					cursor.rewind(1); // beginning of selection
					cursor.voice = voice;
					cursor.staffIdx = staff;

					if (fullScore) // no selection
						cursor.rewind(0); // beginning of score
					while (cursor.segment && (fullScore || cursor.tick < endTick)) {
						if (cursor.element && cursor.element.type === Element.CHORD) {
							var text = newElement(Element.HARMONY); // Make a HARMONY

							// First...we need to scan grace notes for existence and break them
							// into their appropriate lists with the correct ordering of notes.
							var leadingLifo = Array(); // List for leading grace notes
							var trailingFifo = Array(); // List for trailing grace notes
							var graceChords = cursor.element.graceNotes;
							// Build separate lists of leading and trailing grace note chords.
							if (graceChords.length > 0) {
								for (var chordNum = 0; chordNum < graceChords.length; chordNum++) {
									var noteType = graceChords[chordNum].notes[0].noteType
									if (noteType === NoteType.GRACE8_AFTER || noteType === NoteType.GRACE16_AFTER ||
										noteType === NoteType.GRACE32_AFTER) {
										trailingFifo.unshift(graceChords[chordNum])
									} else {
										leadingLifo.push(graceChords[chordNum])
									}
								}
							}

							// Next process the leading grace notes, should they exist...
							text = renderGraceNoteNames(cursor, leadingLifo, text, true)

							// Now handle the note names on the main chord...
							var notes = cursor.element.notes;
							nameChord(notes, text, false);
							if (text.text) {
								text.text = identifyChordSymbol(text.text)
								cursor.add(text);
							}
							switch (cursor.voice) {
								case 1:
								case 3:
									text.placement = Placement.BELOW;
									break;
							}

							if (text.text)
								text = newElement(Element.HARMONY) // Make another STAFF_TEXT object

							// Finally process trailing grace notes if they exist...
							text = renderGraceNoteNames(cursor, trailingFifo, text, true)
						} // end if CHORD
						cursor.next();
					} // end while segment
				} // end for voice
			} // end for staff


			// Notify user of completion
			message("Acordes identificados com sucesso!", "Success");
		} catch (error) {
			message("Um erro ocorreu: " + error.message, "Error");
		}
	}
	function gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao){
		try {
			
		var aux =acordesSeparadoTraco.split("-");
		
		
		dictAcorde[aux[0]+acrescimo+ aux[1]+aux[2]]  = nota
		dictAcorde[aux[1]+acrescimo+ aux[2]+aux[0]]  = nota
		dictAcorde[aux[2]+acrescimo+ aux[0]+aux[1]]  =nota
		
		dictAcorde[aux[0]+aux[1]+acrescimo+aux[2]]  = nota7
		dictAcorde[aux[1]+aux[2]+acrescimo+aux[0]]  = nota7
		dictAcorde[aux[2]+aux[0]+acrescimo+aux[1]]  =nota7

		dictAcorde[primeiraInversao + acrescimo] = nota
		dictAcorde[segundaInversao + acrescimo] = nota
		dictAcorde[terceiraInversao + acrescimo] = nota
		
		dictAcorde[acrescimo+primeiraInversao ] = aux[0]+"/"+acrescimo;
		dictAcorde[acrescimo+segundaInversao ] = aux[0]+"/"+acrescimo;
		dictAcorde[acrescimo+terceiraInversao] =aux[0]+"/"+acrescimo;
		} catch (error) {
			throw new Error("Um erro gerarTetrades: " + error.message, "Error");
		}
	}
	function setAddedChord(index, primeiraInversao, segundaInversao, terceiraInversao, flat,key) {
		try {
			
			// Acorde  com inversões
			dictAcorde[primeiraInversao] = notaBase; // Primeira inversão
			dictAcorde[segundaInversao] = notaBase; // Segunda inversão
			dictAcorde[terceiraInversao] = notaBase; // Terceira inversão
			// Notas Bemol
			if (flat) {
				var acrescimo = notesWithFlats[(index + 1) % 12]; // Segunda menor 
				var nota = notaBase + "2";
				var nota7= notaBase + "9";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithFlats[(index + 2) % 12]; // Segunda maior 
				nota = notaBase + "2M";
			    nota7= notaBase + "9M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithFlats[(index + 3) % 12]; // Terça menor 
				nota = notaBase + "3";
			    nota7= notaBase + "10";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithFlats[(index + 4) % 12]; // Terça maior 
				nota = notaBase + "3M";
			    nota7= notaBase + "10M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithFlats[(index + 5) % 12]; // Quarta justa 
				nota = notaBase + "4";
			    nota7= notaBase + "11";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithFlats[(index + 6) % 12]; // Quinta minuta 
				nota = notaBase + "5-";
			    nota7= notaBase + "12-";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithFlats[(index + 7) % 12]; // Quinta justa 
				nota = notaBase + "5";
			    nota7= notaBase + "12";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithFlats[(index + 8) % 12]; // Sexta menor 
				nota = notaBase + "6";
			    nota7= notaBase + "13";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithFlats[(index + 9) % 12]; // Sexta maior 
				nota = notaBase + "6M";
			    nota7= notaBase + "13M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithFlats[(index + 10) % 12]; // Sétima menor 
				nota = notaBase + "7";
			    nota7= notaBase + "14";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithFlats[(index + 11) % 12]; // Sétima maior 
				nota = notaBase + "7M";
			    nota7= notaBase + "14M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
			} else {
				//Notas Sustenido
				var acrescimo = notesWithSharps [(index + 1) % 12]; // Segunda menor 
				var nota = notaBase + "2";
				var nota7= notaBase + "9";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithSharps[(index + 2) % 12]; // Segunda maior 
				nota = notaBase + "2M";
			    nota7= notaBase + "9M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithSharps[(index + 3) % 12]; // Terça menor 
				nota = notaBase + "3";
			    nota7= notaBase + "10";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithFlats[(index + 4) % 12]; // Terça maior 
				nota = notaBase + "3M";
			    nota7= notaBase + "10M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithSharps[(index + 5) % 12]; // Quarta justa 
				nota = notaBase + "4";
			    nota7= notaBase + "11";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithSharps[(index + 6) % 12]; // Quinta minuta 
				nota = notaBase + "5-";
			    nota7= notaBase + "12-";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithSharps[(index + 7) % 12]; // Quinta justa 
				nota = notaBase + "5";
			    nota7= notaBase + "12";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithSharps[(index + 8) % 12]; // Sexta menor 
				nota = notaBase + "6";
			    nota7= notaBase + "13";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithSharps[(index + 9) % 12]; // Sexta maior 
				nota = notaBase + "6M";
			    nota7= notaBase + "13M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				
				acrescimo = notesWithSharps[(index + 10) % 12]; // Sétima menor 
				nota = notaBase + "7";
			    nota7= notaBase + "14";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
				
				acrescimo = notesWithSharps[(index + 11) % 12]; // Sétima maior 
				nota = notaBase + "7M";
			    nota7= notaBase + "14M";
				gerarTetrades(nota ,nota7,acrescimo,primeiraInversao,segundaInversao,terceiraInversao);
			}
			
			return dictAcorde[key];
		} catch (error) {
			throw new Error("Um erro setAddedChord: " + error.message, "Error");
		}
	}
	function returnNote(key) {
		try {
			var nota="";
			for (let i = 0; i < 12; i++) {
				if (tipoCifra.currentIndex !== 1) {
					notaBase = notesWithFlats[i] + "m"; // Nota base  menor com bemol
					var primeiraInversao = identifychordsAndIntervals(i, "m", 1, true);
					var segundaInversao = identifychordsAndIntervals(i, "m", 2, true);
					var terceiraInversao = identifychordsAndIntervals(i, "m", 3, true);
					
					nota= setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao, true,key);
					if(nota){
						break;
					}
					
					notaBase = notesWithSharps[i] + "m"; // Nota base menor com sustenido
					primeiraInversao = identifychordsAndIntervals(i, "m", 1, false);
					segundaInversao = identifychordsAndIntervals(i, "m", 2, false);
					terceiraInversao = identifychordsAndIntervals(i, "m", 3, false);
					nota=  setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao, false,key);
					if(nota){
						break;
					}
					
					
					
					notaBase = notesWithFlats[i]; // Nota base maior com bemol
					primeiraInversao = identifychordsAndIntervals(i, "", 1, true);
					segundaInversao = identifychordsAndIntervals(i, "", 2, true);
					terceiraInversao = identifychordsAndIntervals(i, "", 3, true);
					nota=setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao,  true,key);
					if(nota){
						break;
					}
					
					
					notaBase = notesWithSharps[i]; // Nota base maior com sustenido
					primeiraInversao = identifychordsAndIntervals(i, "", 1, false);
					segundaInversao = identifychordsAndIntervals(i, "", 2, false);
					terceiraInversao = identifychordsAndIntervals(i, "", 3, false);
					nota=setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao,  false,key);
					if(nota){
						break;
					}
					
					
					
					notaBase = notesWithFlats[i] + "°"; // Nota base diminuto bemol
					primeiraInversao = identifychordsAndIntervals(i, "°", 1, true);
					segundaInversao = identifychordsAndIntervals(i, "°", 2, true);
					terceiraInversao = identifychordsAndIntervals(i, "°", 3, true);
					nota=setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao, true,key);
					if(nota){
						break;
					}
					
					notaBase = notesWithSharps[i] + "+"; // Nota base  aumentada
					primeiraInversao = identifychordsAndIntervals(i, "+", 1, false);
					segundaInversao = identifychordsAndIntervals(i, "+", 2, false);
					terceiraInversao = identifychordsAndIntervals(i, "+", 3, false);
					nota=setAddedChord(i, primeiraInversao, segundaInversao, terceiraInversao, false,key);
					if(nota){
						break;
					}
					notaBase = notesWithSharps[i] + "sus4 "; // Nota base sus4
					primeiraInversao = identifychordsAndIntervals(i, "+", 1, false);
					segundaInversao = identifychordsAndIntervals(i, "+", 2, false);
					terceiraInversao = identifychordsAndIntervals(i, "+", 3, false);
					nota=setAddedChord(i, primeiraInversao, segundaInversao, terceiraInversao, false,key);
					if(nota){
						break;
					}
					

				} else {
					//Romanos menores
					notaBase = notesWithFlatsRoman[i]  
					var primeiraInversao = identifychordsAndIntervals(i, "m", 1, true);
					var segundaInversao = identifychordsAndIntervals(i, "m", 2, true);
					var terceiraInversao = identifychordsAndIntervals(i, "m", 3, true);
					nota= setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao, true,key);
					if(nota){
						break;
					}
					primeiraInversao = identifychordsAndIntervals(i, "m", 1, false);
					segundaInversao = identifychordsAndIntervals(i, "m", 2, false);
					terceiraInversao = identifychordsAndIntervals(i, "m", 3, false);
					nota=  setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao, false,key);
					if(nota){
						break;
					}
					
					
					//Romanos maiores
					notaBase = notesWithSharpsRoman[i]; 
					primeiraInversao = identifychordsAndIntervals(i, "", 1, true);
					segundaInversao = identifychordsAndIntervals(i, "", 2, true);
					terceiraInversao = identifychordsAndIntervals(i, "", 3, true);
					nota=setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao,  true,key);
					if(nota){
						break;
					}
					
					primeiraInversao = identifychordsAndIntervals(i, "", 1, false);
					segundaInversao = identifychordsAndIntervals(i, "", 2, false);
					terceiraInversao = identifychordsAndIntervals(i, "", 3, false);
					nota=setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao,  false,key);
					if(nota){
						break;
					}
					
					
					
					notaBase = notesWithFlatsRoman[i] + "°"; // Nota base di°uto bemol
					primeiraInversao = identifychordsAndIntervals(i, "°", 1, true);
					segundaInversao = identifychordsAndIntervals(i, "°", 2, true);
					terceiraInversao = identifychordsAndIntervals(i, "°", 3, true);
					nota=setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao, true,key);
					if(nota){
						break;
					}
					
					notaBase = notesWithSharpsRoman[i] + "+"; // Nota base base aumentada
					primeiraInversao = identifychordsAndIntervals(i, "+", 1, false);
					segundaInversao = identifychordsAndIntervals(i, "+", 2, false);
					terceiraInversao = identifychordsAndIntervals(i, "+", 3, false);
					nota=setAddedChord(i,  primeiraInversao, segundaInversao, terceiraInversao, false,key);
					if(nota){
						break;
					}
					
				}
			}
			return nota;
			
		} catch (error) {
			throw new Error("returnNo=> " + error.message, "Error");
		}
	}
	// Função para identificar o símbolo do acorde
	function identifyChordSymbol(pitchNames) {
		var useRomanNumerals = (tipoCifra.currentIndex === 1);
		var chordMap = useRomanNumerals ? chordsRoman : chords;

		var chord_uniq = pitchNames.split('-').filter(function (elem, index, self) {
			return index == self.indexOf(elem);
		}); //remove duplicates
		
		var chord_notes = chord_uniq.reverse().join('');
		var r = returnNote(chord_notes);
		if (r) {
			return r;
		}
		chord_notes = chord_uniq.reverse().join('');
		r = returnNote(chord_notes);
		if (r) {
			return r;
		}
		if (!(chord_notes in chordMap)) {
			chord_notes = chord_uniq.reverse().join('');
		}
		if (!(chord_notes in chordMap)) {
			return "";
		}

		return chordMap[chord_notes];
	}
	function identifychordsAndIntervals(index, typeIntervals, invesion, flat) {
		try{
		var nota1 = "";
		var nota2 = "";
		var nota3 = "";
		var nota = "";
		switch (typeIntervals) {
			case "":
				if (flat) {
					nota1 = notesWithFlats[index]; // Nota base
					nota2 = notesWithFlats[(index + 4) % 12]; // Terça maior
					nota3 = notesWithFlats[(index + 7) % 12]; // Quinta justa
				} else {
					nota1 = notesWithSharps[index]; // Nota base
					nota2 = notesWithSharps[(index + 4) % 12]; // Terça maior
					nota3 = notesWithSharps[(index + 7) % 12]; // Quinta justa
				}
				if (invesion == 1) {
					nota = nota1 + nota2 + nota3;
					acordesSeparadoTraco=nota1 +"-"+ nota2 +"-"+  nota3;
				}
				if (invesion == 2) {
					nota = nota2 + nota3 + nota1;
				}
				if (invesion == 3) {
					nota = nota3 + nota1 + nota2;
				}
				break;
			case "m":
				if (flat) {
					nota1 = notesWithFlats[index]; // Nota base
					nota2 = notesWithFlats[(index + 3) % 12]; // Terça menor
					nota3 = notesWithFlats[(index + 7) % 12]; // Quinta justa
				} else {
					nota1 = notesWithSharps[index]; // Nota base
					nota2 = notesWithSharps[(index + 3) % 12]; // Terça menor
					nota3 = notesWithSharps[(index + 7) % 12]; // Quinta justa
				}
				if (invesion == 1) {
					nota = nota1 + nota2 + nota3;
					acordesSeparadoTraco=nota1 +"-"+ nota2 +"-"+  nota3;
				}
				if (invesion == 2) {
					nota = nota2 + nota3 + nota1;
				}
				if (invesion == 3) {
					nota = nota3 + nota1 + nota2;
				}
				break;
			case "°":
				if (flat) {
					nota1 = notesWithFlats[index]; // Nota base
					nota2 = notesWithFlats[(index + 3) % 12]; // Terça menor
					nota3 = notesWithFlats[(index + 6) % 12]; // Quinta justa
				} else {
					nota1 = notesWithSharps[index]; // Nota base
					nota2 = notesWithSharps[(index + 3) % 12]; // Terça menor
					nota3 = notesWithSharps[(index + 6) % 12]; // Quinta justa
				}
				if (invesion == 1) {
					nota = nota1 + nota2 + nota3;
					acordesSeparadoTraco=nota1 +"-"+ nota2 +"-"+  nota3;
				}
				if (invesion == 2) {
					nota = nota2 + nota3 + nota1;
				}
				if (invesion == 3) {
					nota = nota3 + nota1 + nota2;
				}
				break;
			case "+":
				if (flat) {
					nota1 = notesWithFlats[index]; // Nota base
					nota2 = notesWithFlats[(index + 4) % 12]; // Terça maior
					nota3 = notesWithFlats[(index + 8) % 12]; // Quinta justa
				} else {
					nota1 = notesWithSharps[index]; // Nota base
					nota2 = notesWithSharps[(index + 4) % 12]; // Terça maior
					nota3 = notesWithSharps[(index + 8) % 12]; // Quinta justa
				}
				if (invesion == 1) {
					nota = nota1 + nota2 + nota3;
					acordesSeparadoTraco=nota1 +"-"+ nota2 +"-"+  nota3;
				}
				if (invesion == 2) {
					nota = nota2 + nota3 + nota1;
				}
				if (invesion == 3) {
					nota = nota3 + nota1 + nota2;
				}
				break;
			case "sus4":
				if (flat) {
					nota1 = notesWithFlats[index]; // Nota base
					nota2 = notesWithFlats[(index + 4) % 12]; // Terça maior
					nota3 = notesWithFlats[(index + 5) % 12]; // Quinta justa
				} else {
					nota1 = notesWithSharps[index]; // Nota base
					nota2 = notesWithSharps[(index + 5) % 12]; // Terça maior
					nota3 = notesWithSharps[(index + 7) % 12]; // Quinta justa
				}
				if (invesion == 1) {
					nota = nota1 + nota2 + nota3;
					acordesSeparadoTraco=nota1 +"-"+ nota2 +"-"+  nota3;
				}
				if (invesion == 2) {
					nota = nota2 + nota3 + nota1;
				}
				if (invesion == 3) {
					nota = nota3 + nota1 + nota2;
				}
				break;
					
		}
		
		return nota;
		} catch (error) {
			throw new Error("Um erro gerarTetrades: " + error.message, "Error");
		}
	}
	function nameChord(notes, text, small) {
		var sep = "-"; // change to "," if you want them horizontally (anybody?)
		var oct = "";
		var name;
		for (var i = 0; i < notes.length; i++) {
			if (!notes[i].visible)
				continue // skip invisible notes
			if (text.text) // only if text isn't empty
				text.text = sep + text.text;
			if (small)
				text.fontSize *= fontSizeMini
			if (typeof notes[i].tpc === "undefined") // like for grace notes ?!?
				return

			var tpc_str = ["C♭♭", "G♭♭", "D♭♭", "A♭♭", "E♭♭", "B♭♭",
				"F♭", "C♭", "G♭", "D♭", "A♭", "E♭", "B♭", "F", "C", "G", "D", "A", "E", "B", "F#", "C#", "G#", "D#", "A#", "E#", "B#",
				"F##", "C##", "G##", "D##", "A##", "E##", "B##", "F♭♭"
			]; //tpc -1 is at number 34 (last item).
			if (notes[i].tpc != 'undefined' && notes[i].tpc <= 33) {
				if (notes[i].tpc == -1)
					name = tpc_str[34];
				else
					name = tpc_str[notes[i].tpc];
			}

			text.text = name + oct + text.text
		} // end for note
	}
	function renderGraceNoteNames(cursor, list, text, small) {
		if (list.length > 0) { // Check for existence.
			// Now render grace note's names...
			for (var chordNum = 0; chordNum < list.length; chordNum++) {
				// iterate through all grace chords
				var chord = list[chordNum];
				// Set note text, grace notes are shown a bit smaller
				nameChord(chord.notes, text, small)
				if (text.text) {

					cursor.add(text)
				}
				// X position the note name over the grace chord
				text.offsetX = chord.posX
				switch (cursor.voice) {
					case 1:
					case 3:
						text.placement = Placement.BELOW;
						break;
				}

				// If we consume a STAFF_TEXT we must manufacture a new one.
				if (text.text)
					text = newElement(Element.STAFF_TEXT); // Make another STAFF_TEXT
			}
		}
		return text
	}

	function message(errorMessage, titulo) {
		errorDialog.text = qsTr(errorMessage)
		errorDialog.title = titulo
		errorDialog.open()
	}
	Item {
		anchors.fill: parent

		GridLayout {
			columns: 2
			anchors.fill: parent
			anchors.margins: 10
			Label {
				text: "Simbolos"
			}
			StyledDropdown {
				id: tipoCifra
				model: ["Símbolos (C, G7)", "Números Romanos (I, IV)"]
				currentIndex: 0
				onActivated: function (index, value) {
					currentIndex = index
				}
			}
			Button {
				id: applyButton
				text: qsTranslate("PrefsDialogBase", "Aplicar")
				onClicked: {
					 curScore.startCmd();
				    runsheet();
					curScore.endCmd();
					quit();
				}
			}
			Button {
				id: cancelButton
				text: qsTranslate("PrefsDialogBase", "Cancela")
				onClicked: {
					quit()
				}
			}
		}
	}

	MessageDialog {
		id: errorDialog
		title: ""
		text: ""
		onAccepted: {
			quit()
		}
		visible: false
	}
}