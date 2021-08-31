package de.corpus_musicae_ottomanicae.mei;

import de.corpus_musicae_ottomanicae.mei.Constants.AEUAccidental;
import de.corpus_musicae_ottomanicae.mei.Constants.PName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class AEUKeySignatureTest {
    @Test
    public void TestCMOLabelN() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("N");
        assertEquals(new AEUKeySignature(), keySig);
    }

    @Test
    public void TestEmptyCMOLabel() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("");
        assertEquals(new AEUKeySignature(), keySig);
    }

    @Test
    public void TestCMOLabel4b8K() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("4b 8K");
        AEUKeySignature expectedKeySig = new AEUKeySignature();
        expectedKeySig.add(PName.b, AEUAccidental.bf, 4, 4);
        expectedKeySig.add(PName.f, AEUAccidental.ks, 5, 8);
        assertEquals(expectedKeySig, keySig);
    }

    @Test
    public void TestCMOLabel4b() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("4b");
        AEUKeySignature expectedKeySig = new AEUKeySignature();
        expectedKeySig.add(PName.b, AEUAccidental.bf, 4, 4);
        assertEquals(expectedKeySig, keySig);
    }

    @Test
    public void TestCMOLabel4k8B5B7B3B() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("4k 8B 5B 7B 3B");
        AEUKeySignature expectedKeySig = new AEUKeySignature();
        expectedKeySig.add(PName.b, AEUAccidental.kf, 4, 4);
        expectedKeySig.add(PName.f, AEUAccidental.bs, 5, 8);
        expectedKeySig.add(PName.c, AEUAccidental.bs, 5, 5);
        expectedKeySig.add(PName.e, AEUAccidental.bs, 5, 7);
        expectedKeySig.add(PName.a, AEUAccidental.bs, 4, 3);
        assertEquals(expectedKeySig, keySig);
    }
}