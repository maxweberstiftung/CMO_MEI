package de.corpus_musicae_ottomanicae.mei.transform;

import de.corpus_musicae_ottomanicae.mei.*;
import de.corpus_musicae_ottomanicae.mei.Constants.AEUAccidental;
import de.corpus_musicae_ottomanicae.mei.Constants.CWMNAccidental;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import java.util.HashMap;
import java.util.Map;

public class AccidentalTransformer implements Transformer {

    private static final Map<CWMNAccidental, AEUAccidental> cwmn2aeuMap;

    static {
        HashMap<CWMNAccidental, AEUAccidental> map = new HashMap<>();
        // Bakiye sharp
        map.put(CWMNAccidental.s, AEUAccidental.bs);
        // Küçük mücenneb (flat)
        map.put(CWMNAccidental.f, AEUAccidental.kmf);
        // Büyük mücenneb (flat)
        map.put(CWMNAccidental.ff, AEUAccidental.bmf);
        // Büyük mücenneb (sharp)
        map.put(CWMNAccidental.x, AEUAccidental.bms);
        // Bakiye (flat)
        map.put(CWMNAccidental.fd, AEUAccidental.bf);
        // Koma (flat)
        map.put(CWMNAccidental.fu, AEUAccidental.kf);
        // Küçük mücenneb (sharp)
        map.put(CWMNAccidental.su, AEUAccidental.kms);
        // Koma (sharp)
        map.put(CWMNAccidental.sd, AEUAccidental.ks);
        // n is always n, if it's accig.ges or a real accid, must be determined by @func
        map.put(CWMNAccidental.n, AEUAccidental.n);
        cwmn2aeuMap = map;
    }

    private AEUKeySignature keySig;

    @Override
    public Document transform(Document mei) throws MeiInputException {
        Element keySigLabel = XPath.evaluateToElement(mei, "(//mei:staffDef[@n='1'])[1]/mei:label");
        if (keySigLabel == null) {
            throw new IllegalArgumentException("Expected a single label element on staff 1");
        }
        keySig = AEUKeySignature.parseFromCMOInstrumentLabel(keySigLabel.getTextContent());

        addKeySignature((Element) keySigLabel.getParentNode());

        for (Element staff : XPath.evaluateToElements(mei, "//mei:staff[@n='1']")) {
            transformAccidentals(staff);
        }

        return mei;
    }

    private void addKeySignature(Element staffDef) {
        // Remove any pre-existing key signature
        for (Element keySig : XPath.evaluateToElements(staffDef, "./mei:keySig")) {
            keySig.getParentNode().removeChild(keySig);
        }
        staffDef.appendChild(keySig.toMei(staffDef.getOwnerDocument()));
    }

    private void transformAccidentals(Element staff) throws MeiInputException {
        NodeList layers = staff.getElementsByTagNameNS(Constants.MEI_NS, "layer");
        if (layers.getLength() > 1) {
            throw new IllegalArgumentException(
                    "There must not be more than on voice in division " + Util.contextDivisionNumber(staff));
        }
        Element layer = (Element) layers.item(0);
        if (layer.getElementsByTagNameNS(Constants.MEI_NS, "chord").getLength() > 0) {
            throw new IllegalArgumentException(
                    "Music must not contain chords in division " + Util.contextDivisionNumber(staff));
        }
        Map<Stammton, AEUAccidental> accidState = new HashMap<>();
        for (Element note : XPath.evaluateToElements(layer, "//mei:note")) {
            // Ignore any existing @accid.ges completely as the accidental
            // semantics from Sibelius are irrelevant. Only the visual
            // appearance has relevance to us.
            note.removeAttribute("accid.ges");

            Stammton stammton = new Stammton(note);
            String oldAccidString = Util.getAttributeOrDefault(note, "accid", null);
            CWMNAccidental oldAccid;
            try {
                oldAccid = oldAccidString == null ? null : CWMNAccidental.valueOf(oldAccidString);
            } catch (IllegalArgumentException e) {
                throw new MeiInputException(note, "@accid=\"" + oldAccidString + "\" is not recognized");
            }

            if (oldAccid != null) {
                AEUAccidental newAccid = cwmn2aeuMap.get(oldAccid);
                accidState.put(stammton, newAccid);
                note.setAttribute("accid", newAccid.toString());
            } else {
                AEUAccidental precedingAccid = accidState.get(stammton);
                AEUAccidental accidGes = precedingAccid != null ? precedingAccid : keySig.get(stammton.pname);
                if (accidGes != null) {
                    note.setAttribute("accid.ges", accidGes.toString());
                }
            }
        }
    }
}
