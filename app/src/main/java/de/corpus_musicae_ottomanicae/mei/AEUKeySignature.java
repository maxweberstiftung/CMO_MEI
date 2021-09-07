package de.corpus_musicae_ottomanicae.mei;

import de.corpus_musicae_ottomanicae.mei.Constants.AEUAccidental;
import de.corpus_musicae_ottomanicae.mei.Constants.PName;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import java.util.HashMap;


public class AEUKeySignature {
    /**
     * Modelled after the <keyAccid> element
     */
    public static class KeyAccid {
        AEUAccidental accid;
        Integer oct;
        Integer loc;

        KeyAccid(AEUAccidental accid, int oct, int loc) {
            this.accid = accid;
            this.oct = oct;
            this.loc = loc;
        }

        @Override
        public boolean equals(Object otherObject) {
            if (!(otherObject instanceof KeyAccid)) {
                return false;
            }
            KeyAccid other = (KeyAccid) otherObject;
            return accid == other.accid && oct.equals(other.oct) && loc.equals(other.loc);
        }
    }

    private final HashMap<PName, KeyAccid> keyAccidentals = new HashMap<>();

    AEUKeySignature() {
    }

    public AEUAccidental get(PName pname) {
        if (keyAccidentals.containsKey(pname)) {
            return keyAccidentals.get(pname).accid;
        } else {
            return AEUAccidental.n;
        }
    }

    @Override
    public boolean equals(Object otherObject) {
        if (!(otherObject instanceof AEUKeySignature)) {
            return false;
        }
        return ((AEUKeySignature) otherObject).keyAccidentals.equals(keyAccidentals);
    }

    public KeyAccid add(PName pname, KeyAccid accid) {
        return keyAccidentals.put(pname, accid);
    }

    public KeyAccid add(PName pname, AEUAccidental accid, int oct, int loc) {
        return add(pname, new KeyAccid(accid, oct, loc));
    }

    public static HashMap<Character, AEUAccidental> staffLabelAccidCodes;

    static {
        HashMap<Character, AEUAccidental> codes = new HashMap<>();
        // Bakiye flat
        codes.put('b', AEUAccidental.bf);
        // Küçük mücenneb flat
        codes.put('m', AEUAccidental.kmf);
        // Koma flat
        codes.put('k', AEUAccidental.kf);
        // Bakiye sharp
        codes.put('B', AEUAccidental.bs);
        // Küçük mücenneb sharp
        codes.put('M', AEUAccidental.kms);
        // Koma sharp
        codes.put('K', AEUAccidental.ks);
        // Büyük mücenneb flat
        codes.put('f', AEUAccidental.bmf);
        // Büyük mücenneb sharp
        codes.put('S', AEUAccidental.bms);

        staffLabelAccidCodes = codes;
    }

    private static final PName[] pnameByTrebleLoc = { PName.e, PName.f, PName.g, PName.a, PName.b, PName.c, PName.d };

    /**
     * Because Sibelius can not represent key signatures with arbitrary accidental
     * arrangements and AEU accidentals, CMO editors encode the key signature in the
     * instrument label. If the label is "N" or empty, we do not have a "neutral"
     * key signature. Otherwise, the label must consist of space separated codes
     * consisting of two characters each, the first being a digit representing the
     * intended MEI @loc attribute (for treble clef). The second character is mapped
     * to the MEI @accid attribute (see the staffLabelAccidCodes Map).
     */
    public static AEUKeySignature parseFromCMOInstrumentLabel(String label) throws IllegalArgumentException {
        AEUKeySignature keySig = new AEUKeySignature();

        switch (label.trim()) {
            case "N":
            case "":
                return keySig;
        }

        String[] labelComponents = label.trim().split("\\s+");

        for (String labelComponent : labelComponents) {
            if (labelComponent.length() != 2) {
                throw new IllegalArgumentException(
                        "Key signature codes in staff labels must be two characters long. Found component "
                                + labelComponent);
            }

            String locCode = labelComponent.substring(0, 1);
            int loc;
            try {
                loc = Integer.parseInt(locCode);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(
                        "The first character of key signature codes in staff labels must be a digit. Found component "
                                + labelComponent);
            }

            Character accidCode = labelComponent.charAt(1);
            AEUAccidental accid = staffLabelAccidCodes.get(accidCode);
            if (accid == null) {
                throw new IllegalArgumentException(
                        "Unknown accidental code in staff label. Found component " + labelComponent);
            }

            // We assume treble clef

            // c4 is 2 steps below loc 0, hence +2, and +4 for octave 4
            int octave = (loc + 2) / 7 + 4;
            PName pname = pnameByTrebleLoc[Math.floorMod(loc, 7)];

            keySig.add(pname, accid, octave, loc);
        }

        return keySig;
    }

    Element toMei(Document mei) {
        Element keySig = mei.createElementNS(Constants.MEI_NS, "keySig");
        for (PName pname : keyAccidentals.keySet()) {
            KeyAccid accid = keyAccidentals.get(pname);
            Element keyAccid = mei.createElementNS(Constants.MEI_NS, "keyAccid");
            keySig.appendChild(keyAccid);
            keyAccid.setAttribute("pname", pname.toString());
            keyAccid.setAttribute("loc", accid.loc.toString());
            keyAccid.setAttribute("accid", accid.accid.toString());
            keyAccid.setAttribute("oct", accid.oct.toString());
        }
        return keySig;
    }
}
