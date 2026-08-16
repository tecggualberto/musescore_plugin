// ============================================================================
// CONSTANTES E CONFIGURAÇÕES
// ============================================================================
var NOTES_SHARPS = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
var NOTES_FLATS  = ['C', 'D♭', 'D', 'E♭', 'E', 'F', 'G♭', 'G', 'A♭', 'A', 'B♭', 'B'];

var NOTES_ROMAN_SHARPS = ['I', 'I#', 'II', 'II#', 'III', 'IV', 'IV#', 'V', 'V#', 'VI', 'VI#', 'VII'];
var NOTES_ROMAN_FLATS  = ['i', 'i♭', 'ii', 'ii♭', 'iii', 'iv', 'v♭', 'v', 'vi♭', 'vi', 'vii♭', 'vii'];

var FONT_SIZE_MINI = 0.85;

// Mapeamento TPC (Tonal Pitch Class) de -1 a 33
var TPC_MAP = [
  'F♭♭', 'C♭♭', 'G♭♭', 'D♭♭', 'A♭♭', 'E♭♭', 'B♭♭', // -1 a 5 (índices 0-6)
  'F♭',  'C♭',  'G♭',  'D♭',  'A♭',  'E♭',  'B♭',  // 6 a 12 (índices 7-13)
  'F',   'C',   'G',   'D',   'A',   'E',   'B',   // 13 a 19 (índices 14-20)
  'F♯',  'C♯',  'G♯',  'D♯',  'A♯',  'E♯',  'B♯',  // 20 a 26 (índices 21-27)
  'F♯♯', 'C♯♯', 'G♯♯', 'D♯♯', 'A♯♯', 'E♯♯', 'B♯♯'  // 27 a 33 (índices 28-34)
];

// Mapas estáticos de acordes reserva
var CHORDS_ROMAN = {
  "BDF": "VII°", "DFB": "VII°", "FBD": "VII°",
  "D#F##A#": "II#", "F##A#D#": "II#", "A#D#F##": "II#",
  "BE♭♭F": "vii°", "E♭♭FB": "vii°", "FBE♭♭": "vii°"
};

var CHORDS_STANDARD = {
  "BDF": "B°", "DFB": "B°", "FBD": "B°",
  "BE♭♭F": "Bm", "E♭♭FB": "Bm", "FBE♭♭": "Bm",
  "A#F##D#": "D#", "E#G##B#": "E#", "G##B#E#": "E#", "B#E#G##": "E#",
  "B#D##F##": "B#", "D##F##B#": "B#", "F##B#D##": "B#",
  "D♭F♭♭A♭": "D♭", "F♭♭A♭D♭": "D♭", "A♭D♭F♭♭": "D♭", "A♭F♭♭D♭": "D♭",
  "E♭G♭♭B♭": "E♭", "G♭♭B♭E♭": "E♭", "B♭E♭G♭♭": "E♭",
  "F♭A♭C♭": "F♭", "A♭C♭F♭": "F♭", "C♭F♭A♭": "F♭",
  "G♭B♭D♭": "G♭", "B♭D♭G♭": "G♭", "D♭G♭B♭": "G♭",
  "A♭C♭E♭": "A♭", "C♭E♭A♭": "A♭", "E♭A♭C♭": "A♭",
  "B♭D♭♭F♭♭": "B♭", "D♭♭F♭♭B♭": "B♭", "F♭♭B♭D♭♭": "B♭"
};

// Dicionário precomputado e cache de busca
var dictAcorde = {};
var chordDictBuilt = false;

// ============================================================================
// CONSTRUÇÃO E PRÉ-PROCESSAMENTO DE ACORDES
// ============================================================================

function buildChordDictionary() {
  if (chordDictBuilt) return;

  try {
    dictAcorde = {};
    for (var i = 0; i < 12; i++) {
      // Pré-computação de tríades principais (flats e sharps)
      precomputeTriad(i, "", true);
      precomputeTriad(i, "", false);
      precomputeTriad(i, "m", true);
      precomputeTriad(i, "m", false);
      precomputeTriad(i, "dim", true);
      precomputeTriad(i, "dim", false);
      precomputeTriad(i, "aug", false);
      precomputeTriad(i, "sus4", false);
    }
    chordDictBuilt = true;
  } catch (e) {
    throw new Error("Erro em buildChordDictionary: " + e.message);
  }
}

function precomputeTriad(index, typeIntervals, isFlat) {
  var notes = isFlat ? NOTES_FLATS : NOTES_SHARPS;
  var n1 = notes[index];
  var n2Idx, n3Idx;

  switch (typeIntervals) {
    case "":     n2Idx = (index + 4) % 12; n3Idx = (index + 7) % 12; break; // Maior
    case "m":    n2Idx = (index + 3) % 12; n3Idx = (index + 7) % 12; break; // Menor
    case "dim":    n2Idx = (index + 3) % 12; n3Idx = (index + 6) % 12; break; // Diminuto
    case "aug":    n2Idx = (index + 4) % 12; n3Idx = (index + 8) % 12; break; // Aumentado
    case "sus4": n2Idx = (index + 5) % 12; n3Idx = (index + 7) % 12; break; // Sus4
    default: return;
  }

  var n2 = notes[n2Idx];
  var n3 = notes[n3Idx];

  var s0 = n1 + n2 + n3;
  var s1 = n2 + n3 + n1;
  var s2 = n3 + n1 + n2;
  var sDash = n1 + "-" + n2 + "-" + n3;

  var chordName = n1 + typeIntervals;

  if (!dictAcorde[s0]) dictAcorde[s0] = chordName;
  if (!dictAcorde[s1]) dictAcorde[s1] = chordName;
  if (!dictAcorde[s2]) dictAcorde[s2] = chordName;
  if (!dictAcorde[sDash]) dictAcorde[sDash] = chordName;
}

// ============================================================================
// IDENTIFICAÇÃO E NOMEAÇÃO
// ============================================================================

function nameChord(notes, textElement, isSmall) {
  var sep = "-";
  var names = [];

  for (var i = 0; i < notes.length; i++) {
    var note = notes[i];
    if (!note.visible || typeof note.tpc === "undefined") continue;

    var tpcIndex = note.tpc + 1; // Ajusta offset de -1 para base 0
    var noteName = (tpcIndex >= 0 && tpcIndex < TPC_MAP.length) 
      ? qsTranslate("global", TPC_MAP[tpcIndex]) 
      : qsTr("?");

    names.unshift(noteName);
  }

  if (isSmall && textElement.fontSize) {
    textElement.fontSize *= FONT_SIZE_MINI;
  }

  textElement.text = names.join(sep);
}

function identifyChordSymbol(pitchNames, tipoCifra) {
  var chordMap = (tipoCifra === 1) ? CHORDS_ROMAN : CHORDS_STANDARD;

  // Remove notas duplicadas mantendo ordem
  var parts = pitchNames.split('-');
  var uniqueNotes = [];
  for (var i = 0; i < parts.length; i++) {
    if (uniqueNotes.indexOf(parts[i]) === -1) {
      uniqueNotes.push(parts[i]);
    }
  }

  var keyDirect = uniqueNotes.join('');
  var keyReversed = uniqueNotes.slice().reverse().join('');

  // Busca rápida no dicionário precomputado
  if (dictAcorde[keyDirect]) return dictAcorde[keyDirect];
  if (dictAcorde[keyReversed]) return dictAcorde[keyReversed];

  // Busca no mapeamento secundário estático
  if (chordMap[keyDirect]) return chordMap[keyDirect];
  if (chordMap[keyReversed]) return chordMap[keyReversed];

  return "";
}

// ============================================================================
// FUNÇÃO PRINCIPAL (RUNSHEET)
// ============================================================================

function runsheet(options, curScore, tipoCifra) {
  var cursor = null;
  
  try {
    buildChordDictionary();

    cursor = curScore.newCursor();
    cursor.rewind(1);

    var startStaff, endStaff, endTick;
    var fullScore = false;

    if (!cursor.segment) {
      fullScore = true;
      startStaff = 0;
      endStaff = curScore.nstaves - 1;
    } else {
      startStaff = cursor.staffIdx;
      cursor.rewind(2);
      endTick = (cursor.tick === 0) ? curScore.lastSegment.tick + 1 : cursor.tick;
      endStaff = cursor.staffIdx;
    }

    for (var staff = startStaff; staff <= endStaff; staff++) {
      for (var voice = 0; voice < 4; voice++) {
        cursor.rewind(1);
        cursor.voice = voice;
        cursor.staffIdx = staff;

        if (fullScore) cursor.rewind(0);

        while (cursor.segment && (fullScore || cursor.tick < endTick)) {
          if (cursor.element && cursor.element.type === Element.CHORD) {
            var textHolder = newElement(Element.STAFF_TEXT);
            nameChord(cursor.element.notes, textHolder, false);

            var chordName = textHolder.text ? identifyChordSymbol(textHolder.text, tipoCifra) : "";
            textHolder = null;

            if (chordName) {
             
               // Computadore com memoria acima de 8G pode usar Element.HARMONY no lugar de Element.STAFF_TEXT 
              var harmony = newElement(Element.STAFF_TEXT);
              harmony.text = chordName;
              harmony.placement = (voice === 1 || voice === 3) ? Placement.BELOW : Placement.ABOVE;
              
              cursor.add(harmony);
            }
          }

          if (typeof gc === "function") gc();
          cursor.next();
        }
      }
    }

    return { message: "Sucesso ao gerar acordes" };

  } catch (error) {
    return { message: "Um erro ocorreu: " + error.message };
  } finally {
    cursor = null;
    if (typeof gc === "function") gc();
  }
}