package de.corpus_musicae_ottomanicae.mei;

import de.corpus_musicae_ottomanicae.mei.Constants.PName;
import org.w3c.dom.Element;

/**
 * This class implements the "white keys" in a way they can be used e.g. as keys
 * of a Map.
 */
public class Stammton {
    public int octave;
    public PName pname;

    Stammton(PName pname, int octave) {
        this.pname = pname;
        this.octave = octave;
    }

    public Stammton(Element note) throws MeiInputException {
        if (!note.getTagName().equals("note") || !note.getNamespaceURI().equals(Constants.MEI_NS)) {
            throw new IllegalArgumentException("Argument must be a note from the MEI namespace");
        }
        try {
            this.pname = PName.valueOf(note.getAttribute("pname"));
            this.octave = Integer.parseInt(note.getAttribute("oct"));
        } catch (IllegalArgumentException e) {
            throw new MeiInputException(note, "Note needs both @pname and @oct attributes");
        }
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
