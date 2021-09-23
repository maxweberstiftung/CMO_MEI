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
        // Map the accidentals as they are logically input in Sibelius to the
        // actually intended AEU accidentals
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
            Stammton stammton = new Stammton(note);
            CWMNAccidental oldAccid = getAccid(note, "accid");

            // Ignore any existing @accid.ges completely as the accidental
            // semantics from Sibelius are irrelevant. Only the visual
            // appearance has relevance to us.
            setAccid(note, "accid.ges", null);
            for (Element element : XPath.evaluateToElements(note, "descendant-or-self::*[@accid.ges]")) {
                if (element.getTagName().equals("accid")) {
                    element.getParentNode().removeChild(element);
                } else {
                    element.removeAttribute("accid.ges");
                }
            }

            if (oldAccid != null) {
                AEUAccidental newAccid = cwmn2aeuMap.get(oldAccid);
                if (newAccid == null) {
                    throw new MeiInputException(note,
                            "Could not map CWMN accidntal " + oldAccid.toString() + " to an AEU accidental");
                }
                accidState.put(stammton, newAccid);
                setAccid(note, "accid", newAccid);
            } else {
                AEUAccidental precedingAccid = accidState.get(stammton);
                AEUAccidental accidGes = precedingAccid != null ? precedingAccid : keySig.get(stammton.pname);
                setAccid(note, "accid.ges", accidGes == AEUAccidental.n ? null : accidGes);
            }
        }
    }

    /**
     * Looks for an accid attribute on the note or an <accid> child. Returns null if
     * no such attribute was found.
     */
    static CWMNAccidental getAccid(Element note, String attribute) throws MeiInputException {
        Element accidElement = getAccidElement(note, false);
        String accid = accidElement == null ? "" : accidElement.getAttribute(attribute);
        String noteAccid = note.getAttribute(attribute);

        if (!noteAccid.isEmpty() && !noteAccid.equals(accid)) {
            if (accid.isEmpty()) {
                accid = noteAccid;
            } else {
                throw new MeiInputException(note, "note/@" + attribute + "='" + noteAccid + "' contradicts accid/@"
                        + attribute + "='" + accid + "'");
            }
        }

        try {
            return accid.isEmpty() ? null : CWMNAccidental.valueOf(accid);
        } catch (IllegalArgumentException e) {
            throw new MeiInputException(note,
                    "@" + attribute + "=\"" + accid + "\" is not recognized as CWMN accidental");
        }
    }

    /**
     * Sets or removes @accid of an <accid> child of the note. Normalizes accid
     * attributes, i.e. only keeps either @accid or @accid.ges and moves them from
     * the <note> to the <accid> element.
     *
     * @param accid If null, the attribute will be removed. If this leaves an empty
     *              <accid> element, that will be removed, too.
     */
    static void setAccid(Element note, String attribute, AEUAccidental accid) throws MeiInputException {
        String otherAttribute = attribute.equals("accid") ? "accid.ges" : "accid";
        note.removeAttribute(attribute);
        String otherAttributeValue = note.getAttribute(otherAttribute);
        note.removeAttribute(otherAttribute);

        Element accidElement = getAccidElement(note, accid != null);
        if (accid != null) {
            // Add accid
            accidElement.removeAttribute(otherAttribute);
            accidElement.setAttribute(attribute, accid.toString());
        } else if (accidElement != null) {
            // Remove @accid*
            if (accidElement.hasAttribute(otherAttribute)) {
                accidElement.removeAttribute(attribute);
            } else if (otherAttributeValue.isEmpty()) {
                // Don't leave an empty <accid> element
                note.removeChild(accidElement);
            } else {
                // Normalize remaining @accid* by moving it from <note> to <accid>
                accidElement.setAttribute(otherAttribute, otherAttributeValue);
            }
        }
    }

    static Element getAccidElement(Element note, boolean createIfNotPresent) throws MeiInputException {
        NodeList accidElements = note.getElementsByTagNameNS(Constants.MEI_NS, "accid");
        switch (accidElements.getLength()) {
            case 0:
                if (!createIfNotPresent) {
                    return null;
                }
                Element accidElement = note.getOwnerDocument().createElementNS(Constants.MEI_NS, "accid");
                return (Element) note.appendChild(accidElement);
            case 1:
                return (Element) accidElements.item(0);
            default:
                throw new MeiInputException(note, "Notes must not have more than one <accid> child");
        }
    }
}
