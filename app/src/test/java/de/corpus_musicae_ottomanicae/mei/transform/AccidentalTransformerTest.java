package de.corpus_musicae_ottomanicae.mei.transform;

import de.corpus_musicae_ottomanicae.Xml;
import de.corpus_musicae_ottomanicae.mei.Constants;
import de.corpus_musicae_ottomanicae.mei.MeiInputException;
import de.corpus_musicae_ottomanicae.mei.XPath;

import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;

class AccidentalTransformerTest {
    @Test
    void noteAccidentals() throws SAXException, IOException, ParserConfigurationException, MeiInputException {
        Document mei = Xml.loadResource(this, "accid-ges-test1.mei");
        mei = new AccidentalTransformer().transform(mei);

        NodeList notes = mei.getElementsByTagNameNS(Constants.MEI_NS, "note");
        String[] accidGesValues = new String[notes.getLength()];
        String[] accidValues = new String[notes.getLength()];
        for (int i = 0; i < notes.getLength(); i++) {
            Element note = (Element) notes.item(i);
            accidValues[i] = XPath.evaluateToString(note, "mei:accid/@accid");
            accidGesValues[i] = XPath.evaluateToString(note, "mei:accid/@accid.ges");
        }

        assertArrayEquals(new String[] {
                // bar 1
                null, null, null, "n", "n", "kmf", null, null, "bs", "n", null,
                // bar 2
                null, null //
        }, accidValues, "accid");

        assertArrayEquals(new String[] {
                // bar 1
                "bs", "ks", "ks", null, null, null, null, null, null, null, "kmf",
                // bar 2
                "bs", "ks" //
        }, accidGesValues, "accid.ges");
    }
}