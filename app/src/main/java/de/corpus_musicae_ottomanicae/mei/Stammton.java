package de.corpus_musicae_ottomanicae.mei;

import de.corpus_musicae_ottomanicae.mei.Constants.AEUAccidental;
import de.corpus_musicae_ottomanicae.mei.Constants.PName;

/**
 * This class implements the "white keys" in a way they can be used e.g. as
 * keys of a Map.
 */
public class Stammton {
    public int octave;
    public PName pname;

    Stammton(PName pname, int octave) {
        this.pname = pname;
        this.octave = octave;
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof Stammton)) {
            return false;
        }
        Stammton otherStammton = (Stammton) other;
        return otherStammton.octave == octave && otherStammton.pname == pname;
    }

    @Override
    public final int hashCode() {
        return octave * PName.values().length + pname.ordinal();
    }
}
