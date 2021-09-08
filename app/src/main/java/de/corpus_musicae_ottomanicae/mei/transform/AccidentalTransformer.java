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
        for (Element note : XPath.evaluateToElements(layer, ".//mei:note")) {
            // Ignore any existing @accid.ges completely as the accidental
            // semantics from Sibelius are irrelevant. Only the visual
            // appearance has relevance to us.
            for (Element element : XPath.evaluateToElements(note, "descendant-or-self::*[@accid.ges]")) {
                element.removeAttribute("accid.ges");
            }

            Stammton stammton = new Stammton(note);
            CWMNAccidental oldAccid = getAccid(note);

            if (oldAccid != null) {
                AEUAccidental newAccid = cwmn2aeuMap.get(oldAccid);
                if (newAccid == null) {
                    throw new MeiInputException(note,
                            "Could not map CWMN accidntal " + oldAccid.toString() + " to an AEU accidental");
                }
                accidState.put(stammton, newAccid);
                setAccid(note, newAccid);
            } else {
                AEUAccidental precedingAccid = accidState.get(stammton);
                AEUAccidental accidGes = precedingAccid != null ? precedingAccid : keySig.get(stammton.pname);
                if (accidGes != null) {
                    note.setAttribute("accid.ges", accidGes.toString());
                }
            }
        }
    }

    /**
     * Looks for an accid attribute on the note or an <accid> child. Returns null if
     * no such attribute was found.
     */
    CWMNAccidental getAccid(Element note) throws MeiInputException {
        String accid = null;
        for (Element element : XPath.evaluateToElements(note, "descendant-or-self::*[@accid]")) {
            String foundAccid = element.getAttribute("accid");
            if (accid == null) {
                accid = foundAccid;
            } else if (foundAccid != accid) {
                throw new MeiInputException(note, "@accid='" + foundAccid + "' contradicts @accid='" + accid + "'");
            }
        }
        try {
            return accid == null ? null : CWMNAccidental.valueOf(accid);
        } catch (IllegalArgumentException e) {
            throw new MeiInputException(note, "@accid=\"" + accid + "\" is not recognized as CWMN accidental");
        }
    }

    /**
     * Creates an <accid> element (if not already present) and sets @accid on it.
     * Removes any @accid from the note itself.
     */
    void setAccid(Element note, AEUAccidental accid) throws MeiInputException {
        note.removeAttribute("accid");
        NodeList accidElements = note.getElementsByTagNameNS(Constants.MEI_NS, "accid");
        Element accidElement;
        switch (accidElements.getLength()) {
            case 0:
                accidElement = note.getOwnerDocument().createElementNS(Constants.MEI_NS, "accid");
                note.appendChild(accidElement);
                break;
            case 1:
                accidElement = (Element) accidElements.item(0);
                break;
            default:
                throw new MeiInputException(note, "Notes must not have more than one <accid> child");
        }

        accidElement.setAttribute("accid", accid.toString());
    }
}
