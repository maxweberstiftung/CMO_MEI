package de.corpus_musicae_ottomanicae.mei;

import de.corpus_musicae_ottomanicae.mei.Constants.AEUAccidental;
import de.corpus_musicae_ottomanicae.mei.Constants.PName;

import java.util.HashMap;


public class KeySignature {
    private HashMap<PName, AEUAccidental> accidentals = new HashMap();

    KeySignature() {}

    KeySignature(PName[] pnames, Constants.AEUAccidental[] accids) {
        if (pnames.length != accids.length) {
            throw new IllegalArgumentException("number of pnames and accids must match");
        }
        for (int i = 0; i < pnames.length; i++) {
            if (accidentals.containsKey(pnames[i])) {
                throw new IllegalArgumentException("Duplicate entry for " + pnames[i]);
            }
            accidentals.put(pnames[i], accids[i]);
        }
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof KeySignature)) {
            return false;
        }
        KeySignature otherKeySig = (KeySignature) other;
        return accidentals.equals(otherKeySig.accidentals);
    }

    public AEUAccidental get(PName pname) {
        return accidentals.getOrDefault(pname, AEUAccidental.n);
    }

    public AEUAccidental put(PName pname, AEUAccidental accid) {
        return accidentals.put(pname, accid);
    }

    public static KeySignature parseFromCMOInstrumentLabel(String label) {
        KeySignature keySig = new KeySignature();

        return keySig;
    }
}
