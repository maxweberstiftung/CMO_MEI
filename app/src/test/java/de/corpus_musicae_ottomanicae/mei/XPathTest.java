package de.corpus_musicae_ottomanicae.mei;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;

import de.corpus_musicae_ottomanicae.Xml;

public class XPathTest {
    @Test
    public void testEvaluateToElements() throws SAXException, IOException, ParserConfigurationException {
        Document mei;
        Element[] elements;

        mei = Xml.parse("<mei xmlns='http://www.music-encoding.org/ns/mei'><foo/><foo/></mei>");

        elements = XPath.evaluateToElements(mei, "//mei:mei/mei:foo");
        assertEquals(2, elements.length);

        elements = XPath.evaluateToElements(mei, "//mei/foo");
        assertEquals(0, elements.length);
    }

    @Test
    public void testEvaluateToElementsNoNamespace() throws SAXException, IOException, ParserConfigurationException {
        Document mei;
        Element[] elements;

        mei = Xml.parse("<mei><foo/><foo/></mei>");

        elements = XPath.evaluateToElements(mei, "//mei:mei/mei:foo");
        assertEquals(0, elements.length);

        elements = XPath.evaluateToElements(mei, "//mei/foo");
        assertEquals(2, elements.length);
    }
}
