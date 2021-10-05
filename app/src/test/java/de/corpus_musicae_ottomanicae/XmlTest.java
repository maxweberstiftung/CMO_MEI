package de.corpus_musicae_ottomanicae;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class XmlTest {
    @Test
    public void testUtf16WithBom() throws IOException, SAXException, ParserConfigurationException {
        Document doc = Xml.loadResource(Xml.class, "utf16WithBom.xml");
        assertEquals("test", doc.getDocumentElement().getTextContent());
    }
}
