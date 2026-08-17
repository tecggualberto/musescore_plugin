// ============================================================================
// CONSTANTES E CONFIGURAÇÕES
// ============================================================================
var NOTES_SHARPS = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
var NOTES_FLATS  = ['C', 'D♭', 'D', 'E♭', 'E', 'F', 'G♭', 'G', 'A♭', 'A', 'B♭', 'B'];

var NOTES_ROMAN_SHARPS = ['I', 'I#', 'II', 'II#', 'III', 'IV', 'IV#', 'V', 'V#', 'VI', 'VI#', 'VII'];
var NOTES_ROMAN_FLATS  = ['i', 'i♭', 'ii', 'ii♭', 'iii', 'iv', 'v♭', 'v', 'vi♭', 'vi', 'vii♭', 'vii'];



// Mapeamento TPC (Tonal Pitch Class) de -1 a 33
var TPC_MAP = [
  'F♭♭', 'C♭♭', 'G♭♭', 'D♭♭', 'A♭♭', 'E♭♭', 'B♭♭', // -1 a 5 (índices 0-6)
  'F♭',  'C♭',  'G♭',  'D♭',  'A♭',  'E♭',  'B♭',  // 6 a 12 (índices 7-13)
  'F',   'C',   'G',   'D',   'A',   'E',   'B',   // 13 a 19 (índices 14-20)
  'F♯',  'C♯',  'G♯',  'D♯',  'A♯',  'E♯',  'B♯',  // 20 a 26 (índices 21-27)
  'F♯♯', 'C♯♯', 'G♯♯', 'D♯♯', 'A♯♯', 'E♯♯', 'B♯♯'  // 27 a 33 (índices 28-34)
];

// Mapas estáticos de acordes reserva
// ============================================================================
// MAPA ESTÁTICO DE CIFRAS ROMANAS (COM SUS2 E SUS4)
// ============================================================================
var CHORDS_ROMAN = {
  // Tríades Maiores
  "CEG": "I", "EGC": "I", "GCE": "I",
  "FAC": "IV", "ACF": "IV", "CFA": "IV",
  "GBD": "V", "BDG": "V", "DGB": "V",
  "D#F##A#": "II#", "F##A#D#": "II#", "A#D#F##": "II#",

  // Tríades Menores
  "DFA": "ii", "FAD": "ii", "ADF": "ii",
  "EGB": "iii", "GBE": "iii", "BEG": "iii",
  "ACE": "vi", "CEA": "vi", "EAC": "vi",

  // Acordes Suspensos (sus2 / sus4)
  "CDG": "Isus2", "DGC": "Isus2", "GCD": "Isus2",
  "GAD": "Vsus2", "ADG": "Vsus2", "DGA": "Vsus2",
  "CFG": "Isus4", "FGC": "Isus4", "GCF": "Isus4",
  "GCD": "Vsus4", "DGC": "Vsus4", "CDG": "Vsus4",

  // Tríades Diminutas
  "BDF": "viidim", "DFB": "viidim", "FBD": "viidim",
  "BE♭♭F": "viidim", "E♭♭FB": "viidim", "FBE♭♭": "viidim",
  "C#EG": "iidim", "EGC#": "iidim", "GCE#": "iidim",

  // Acordes de Sétima
  "GBDF": "V7", "BDFG": "V7", "DFGB": "V7", "FGBD": "V7",
  "CEGB": "Imaj7", "EGBC": "Imaj7", "GBCE": "Imaj7", "BCEG": "Imaj7",
  "DFAC": "ii7", "FACD": "ii7", "ACDF": "ii7", "CDFA": "ii7",
  "BDFA": "viiø7", "DFAB": "viiø7", "FABD": "viiø7", "ABDF": "viiø7"
};

// ============================================================================
// MAPA ESTÁTICO DE CIFRAS PADRÃO (COM SUS2 E SUS4)
// ============================================================================
var CHORDS_STANDARD = {
  // --- TRÍADES MAIORES ---
  "CEG": "C", "EGC": "C", "GCE": "C",
  "DF#A": "D", "F#AD": "D", "ADF#": "D",
  "EGB#": "E", "GB#E": "E", "B#EG": "E",
  "FAC": "F", "ACF": "F", "CFA": "F",
  "F#A#C#": "F#", "A#C#F#": "F#", "C#F#A#": "F#",
  "GBD": "G", "BDG": "G", "DGB": "G",
  "AbCEb": "Ab", "CEbAb": "Ab", "EbAbC": "Ab",
    "AC#E": "A", "C#EA": "A", "EAC#": "A",
  "BbDF": "Bb", "DFBb": "Bb", "FBbD": "Bb",
  "BD#F#": "B", "D#F#B": "B", "F#BD#": "B",

  // --- ACORDES SUSPENDIDOS (SUS2) ---
  "CDG": "Csus2", "DGC": "Csus2", "GCD": "Csus2",
  "DEA": "Dsus2", "EAD": "Dsus2", "ADE": "Dsus2",
  "EF#B": "Esus2", "F#BE": "Esus2", "BEF#": "Esus2",
  "FGC": "Fsus2", "GCF": "Fsus2", "CFG": "Fsus2",
  "GAD": "Gsus2", "ADG": "Gsus2", "DGA": "Gsus2",
  "ABE": "Asus2", "BEA": "Asus2", "EAB": "Asus2",
  "BC#F#": "Bsus2", "C#F#B": "Bsus2", "F#BC#": "Bsus2",

  // --- ACORDES SUSPENDIDOS (SUS4) ---
  "CFG": "Csus4", "FGC": "Csus4", "GCF": "Csus4",
  "DGA": "Dsus4", "GAD": "Dsus4", "ADG": "Dsus4",
  "EAB": "Esus4", "ABE": "Esus4", "BEA": "Esus4",
  "FBbC": "Fsus4", "BbCF": "Fsus4", "CFBb": "Fsus4",
  "FB♭C": "Fsus4", "B♭CF": "Fsus4", "CFB♭": "Fsus4",
  "GCD": "Gsus4", "CDG": "Gsus4", "DGC": "Gsus4",
  "ADE": "Asus4", "DEA": "Asus4", "EAD": "Asus4",
  "BEF#": "Bsus4", "EF#B": "Bsus4", "F#BE": "Bsus4",

  // --- TRÍADES ENARMÔNICAS E DUPLO-ACIDENTES ---
  "A#F##D#": "D#", "F##D#A#": "D#", "D#A#F##": "D#",
  "E#G##B#": "E#", "G##B#E#": "E#", "B#E#G##": "E#",
  "B#D##F##": "B#", "D##F##B#": "B#", "F##B#D##": "B#",
  "D♭F♭♭A♭": "D♭", "F♭♭A♭D♭": "D♭", "A♭D♭F♭♭": "D♭", "A♭F♭♭D♭": "D♭",
  "E♭G♭♭B♭": "E♭", "G♭♭B♭E♭": "E♭", "B♭E♭G♭♭": "E♭",
  "F♭A♭C♭": "F♭", "A♭C♭F♭": "F♭", "C♭F♭A♭": "F♭",
  "G♭B♭D♭": "G♭", "B♭D♭G♭": "G♭", "D♭G♭B♭": "G♭",
  "A♭C♭E♭": "A♭m", "C♭E♭A♭": "A♭m", "E♭A♭C♭": "A♭m",
  "B♭D♭♭F♭♭": "B♭dim", "D♭♭F♭♭B♭": "B♭dim", "F♭♭B♭D♭♭": "B♭dim",

  // --- TRÍADES MENORES ---
  "CE♭G": "Cm", "E♭GC": "Cm", "GCE♭": "Cm", "GCEb": "Cm",
  "DFA": "Dm", "FAD": "Dm", "ADF": "Dm",
  "EGB": "Em", "GBE": "Em", "BEG": "Em",
  "FAbC": "Fm", "AbCF": "Fm", "CFAb": "Fm",
  "F#AC#": "F#m", "AC#F#": "F#m", "C#F#A": "F#m",
  "GB♭D": "Gm", "B♭DG": "Gm", "DGB♭": "Gm", "GBbD": "Gm",
  "ACE": "Am", "CEA": "Am", "EAC": "Am",
  "BDF#": "Bm", "DF#B": "Bm", "F#BD": "Bm",
  "BE♭♭F": "Bm", "E♭♭FB": "Bm", "FBE♭♭": "Bm",

  // --- TRÍADES DIMINUTAS ---
  "BDF": "Bdim", "DFB": "Bdim", "FBD": "Bdim",
  "C#EG": "C#dim", "EGC#": "C#dim", "GCE#": "C#dim",
  "D#F#A": "D#dim", "F#AD#": "D#dim", "AD#F#": "D#dim",
  "E#G#B": "E#dim", "G#BE#": "E#dim", "BE#G#": "E#dim",

  // --- ACORDES DE SÉTIMA (DOMINANTES E MAIORES) ---
  "CEGB": "Cmaj7", "EGBC": "Cmaj7", "GBCE": "Cmaj7", "BCEG": "Cmaj7",
  "CEGBb": "C7", "EGBbC": "C7", "GBbCE": "C7", "BbCEG": "C7",
  "FACE": "Fmaj7", "ACEF": "Fmaj7", "CEFA": "Fmaj7", "EFAC": "Fmaj7",
  "GBDF": "G7", "BDFG": "G7", "DFGB": "G7", "FGBD": "G7",
   "GBDF#": "Gmaj7", "BDF#G": "Gmaj7", "DF#GB": "Gmaj7", "F#GBD": "Gmaj7",
  "AC#EG": "A7", "C#EGA": "A7", "EGAC#": "A7", "GAC#E": "A7",
  "AC#EG#": "Amaj7", "C#EG#A": "Amaj7", "EG#AC#": "Amaj7", "G#AC#E": "Amaj7",
  "BD#F#A": "B7", "D#F#AB": "B7", "F#ABD#": "B7", "ABDF#": "B7"
};
// Dicionário precomputado e cache de busca
var dictAcorde = {};
var chordDictBuilt = true;

// ============================================================================
// CONSTRUÇÃO E PRÉ-PROCESSAMENTO DE ACORDES
// ============================================================================

function buildChordDictionary() {
 
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
  var chordMap = (tipoCifra) ? CHORDS_ROMAN:CHORDS_STANDARD;

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
  // if (dictAcorde[keyDirect]) return dictAcorde[keyDirect];
  // if (dictAcorde[keyReversed]) return dictAcorde[keyReversed];

  // Busca no mapeamento secundário estático
  if (chordMap[keyDirect]) return chordMap[keyDirect];
  if (chordMap[keyReversed]) return chordMap[keyReversed];

  return "";
}

// ============================================================================
// FUNÇÃO PRINCIPAL (RUNSHEET)
// ============================================================================

function runsheet(options, curScore,  tipoCifra ) {
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
