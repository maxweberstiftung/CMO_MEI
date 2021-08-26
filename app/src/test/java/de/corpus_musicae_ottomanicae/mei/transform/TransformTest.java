package de.corpus_musicae_ottomanicae.mei.transform;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;


import java.io.IOException;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class TransformTest {

    Document loadXMLResource(String fileName) throws SAXException, IOException, ParserConfigurationException {
        return DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(
            this.getClass().getResourceAsStream(fileName)
        );
    }

    @Test
    void keySignatureAccidentals() throws SAXException, IOException, ParserConfigurationException {
        Document mei = loadXMLResource("accid-ges-test1.mei");
        Transform.transformAccids(mei);

        NodeList notes = mei.getElementsByTagName("note");
        String[] accidGesValues = new String[notes.getLength()];
        String[] accidValues = new String[notes.getLength()];
        for (int i = 0; i < notes.getLength(); i++) {
            Element note = (Element) notes.item(i);
            accidGesValues[i] = note.getAttribute("accid.ges");
            accidValues[i] = note.getAttribute("accid");
        }

        assertArrayEquals(
            new String[]{
                "bs", "ks", "ks", "n", "n", "kmf", "n", "n", "ks", "n", // bar 1
                "ks", "ks" // bar 2
            },
            accidGesValues,
            "accid.ges"
        );

        assertArrayEquals(
            new String[]{
                null, null, null, "n", "n", "kmf", null, null, "ks", "n", // bar 1
                null, null // bar 2
            },
            accidValues,
            "accid.ges"
        );
    }
}
