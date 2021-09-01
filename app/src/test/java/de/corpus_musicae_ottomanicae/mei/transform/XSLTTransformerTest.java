package de.corpus_musicae_ottomanicae.mei.transform;

import de.corpus_musicae_ottomanicae.XmlLoader;
import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;

import static org.junit.jupiter.api.Assertions.assertEquals;

class XSLTTransformerTest {
    @Test
    void testTransform() throws IOException, ParserConfigurationException, SAXException {
        Document xslt = XmlLoader.loadResource(this, "xsl-transform-test.xsl");
        Document input = XmlLoader.loadResource(this, "xsl-transform-test.xml");
        Document output = new XSLTTransformer(xslt).transform(input);
        assertEquals("out", output.getDocumentElement().getTextContent());
    }
}