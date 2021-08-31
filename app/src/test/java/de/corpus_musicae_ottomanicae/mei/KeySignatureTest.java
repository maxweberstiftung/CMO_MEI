package de.corpus_musicae_ottomanicae.mei;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class KeySignatureTest {
    @Test
    public void TestCMOLabelParserN() {
        KeySignature keySig = KeySignature.parseFromCMOInstrumentLabel("N");
        assertEquals(new KeySignature(), keySig, "Key signature with no accidentals");
    }
}