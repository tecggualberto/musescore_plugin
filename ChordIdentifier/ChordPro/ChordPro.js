/**
 * Gera o texto no formato ChordPro a partir da partitura atual.
 * @returns {string} Texto formatado em ChordPro.
 */
function generateChordProText() {
    if (typeof curScore === "undefined" || !curScore) return "";

    var cursor = curScore.newCursor();
    var hasSelection = cursor.rewind(1); // 1 = Cursor.SELECTION_START

    if (!hasSelection) {
        cursor.rewind(0); // 0 = Cursor.SCORE_START
    }

    var chordPro = hasSelection ? "" : getChordProHeader(curScore, cursor);
    var currentLine = "";
    var pendingChord = "";

    var endTick = null;
    if (hasSelection && curScore.selection && curScore.selection.endTick) {
        endTick = curScore.selection.endTick;
    }

    while (cursor.segment) {
        if (endTick !== null && cursor.tick >= endTick) {
            break;
        }

        var annotations = extractAnnotationsFromSegment(cursor.segment);

        if (annotations.sectionMarkers.length > 0) {
            if (currentLine.trim()) {
                chordPro += currentLine.trim() + "\n";
                currentLine = "";
            }
            if (pendingChord) {
                chordPro += pendingChord + "\n";
                pendingChord = "";
            }

            if (chordPro && !chordPro.endsWith("\n\n")) {
                chordPro += "\n";
            }

            for (var i = 0; i < annotations.sectionMarkers.length; i++) {
                chordPro += "{comment: " + annotations.sectionMarkers[i] + "}\n";
            }
        }

        if (annotations.chords) {
            pendingChord += annotations.chords;
        }

        if (cursor.element && cursor.element.type === Element.CHORD) {
            var lyricData = extractLyricData(cursor.element);

            if (lyricData.text || pendingChord) {
                if (pendingChord) {
                    currentLine += pendingChord;
                    pendingChord = "";
                }

                currentLine += lyricData.text;

                // CORREÇÃO: Só adiciona espaço se REALMENTE for o fim de uma palavra completa
                if (lyricData.isWordEnd && lyricData.text !== "") {
                    currentLine += " ";
                }
            }
        }

        cursor.next();
    }

    if (pendingChord) {
        currentLine += pendingChord;
    }

    chordPro += currentLine;

    return chordPro
        .split("\n")
        .map(function(line) { return line.replace(/[ \t]+/g, " ").trim(); })
        .join("\n")
        .trim();
}

/**
 * Converte o valor numérico da armadura de clave para a nota correspondente.
 */
function getKeyName(keySig) {
    var keys = {
        0: "C",
        1: "G", 2: "D", 3: "A", 4: "E", 5: "B", 6: "F#", 7: "C#",
        "-1": "F", "-2": "Bb", "-3": "Eb", "-4": "Ab", "-5": "Db", "-6": "Gb", "-7": "Cb"
    };
    return keys[keySig] || "";
}

/**
 * Monta as tags de cabeçalho do ChordPro buscando tags alternativas do MuseScore.
 */
function getChordProHeader(score, cursor) {
   
    var title = score.metaTag("workTitle") || score.metaTag("arranger") || score.title || "Sem Título";
    var composer = score.metaTag("composer") || score.metaTag("lyricist")|| score.metaTag("subtitle")|| score.subtitle ||score.composer || "Desconhecido";

    var header = "{title: " + title + "}\n{subtitle: " + composer + "}\n";

    if (cursor && cursor.keySignature !== undefined) {
        var keyName = getKeyName(cursor.keySignature);
        if (keyName) {
            header += "{key: " + keyName + "}\n";
        }
    }

    if (cursor && cursor.timeSignature) {
        var num = cursor.timeSignature.numerator;
        var den = cursor.timeSignature.denominator;
        if (num && den) {
            header += "{time: " + num + "/" + den + "}\n";
        }
    }

    var bpm = "";
    if (cursor && cursor.tempo) {
        bpm = Math.round(cursor.tempo * 60);
    }

    if (cursor && cursor.segment && cursor.segment.annotations) {
        for (var i = 0; i < cursor.segment.annotations.length; i++) {
            var anno = cursor.segment.annotations[i];
            if (anno.type === Element.TEMPO_TEXT && anno.text) {
                var match = anno.text.match(/\d+/);
                if (match) bpm = match[0];
            }
        }
    }

    if (bpm) {
        header += "{tempo: " + bpm + "}\n";
    }

    header += "\n";
    return header;
}

/**
 * Extrai harmonia, marcas de ensaio e textos de seção do segmento.
 */
function extractAnnotationsFromSegment(segment) {
    if (!segment || !segment.annotations) {
        return { chords: "", sectionMarkers: [] };
    }

    var chords = [];
    var sectionMarkers = [];
    var sectionKeywords = ["REFRAO", "INTRO", "INTRODUCAO", "SOLO", "PONTE", "VERSO", "ESTROFE", "FINAL", "CODA"];

    for (var i = 0; i < segment.annotations.length; i++) {
        var annotation = segment.annotations[i];
        var type = annotation.type;
        var text = (annotation.text || "").trim();

        if (type === Element.HARMONY && text) {
            chords.push(text);
        } else if (type === Element.REHEARSAL_MARK && text) {
            sectionMarkers.push("PARTE: " + text);
        } else if ((type === Element.STAFF_TEXT || type === Element.SYSTEM_TEXT) && text) {
            var normalizedText = text.toUpperCase();
            
            var isSection = false;
            for (var j = 0; j < sectionKeywords.length; j++) {
                if (normalizedText.indexOf(sectionKeywords[j]) !== -1) {
                    isSection = true;
                    break;
                }
            }
            
            if (isSection) {
                sectionMarkers.push(text);
            }
        }
    }

    var formattedChords = chords
        .map(function(c) { return c.charAt(0).toUpperCase() + c.slice(1); })
        .join("][");

    return {
        chords: chords.length > 0 ? "[" + formattedChords + "]" : "",
        sectionMarkers: sectionMarkers
    };
}

/**
 * Extrai o texto da letra e valida o encadeamento correto de sílabas.
 */
function extractLyricData(element) {
    var lyrics = element.lyrics;
    if (!lyrics || lyrics.length === 0) {
        return { text: "", isWordEnd: false };
    }

    // Acessa o primeiro índice do array de linhas de letra
    var lyric = lyrics[0]; 
    var text = (lyric.text || "").replace(/~/g, " ");
    
    // Constantes Numéricas Oficiais da API do MuseScore para sílabas:
    // 0 = SINGLE (Palavra de uma sílaba só - ex: "me", "e", "com")
    // 3 = END (Última sílaba de uma palavra - ex: o "do" de "pecado")
    var isWordEnd = (lyric.syllabic === 0 || lyric.syllabic === 3);

    return { text: text, isWordEnd: isWordEnd };
}
