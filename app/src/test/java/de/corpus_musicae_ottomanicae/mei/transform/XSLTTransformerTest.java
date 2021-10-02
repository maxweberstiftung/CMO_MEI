package de.corpus_musicae_ottomanicae.mei.transform;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import de.corpus_musicae_ottomanicae.Xml;
import de.corpus_musicae_ottomanicae.mei.MeiInputException;
import net.sf.saxon.s9api.SaxonApiException;

class XSLTTransformerTest {
    static final Document dummyDocument;
    static {
        try {
            dummyDocument = Xml.parse("<foo/>");
        } catch (SAXException | IOException | ParserConfigurationException e) {
            throw new RuntimeException();
        }
    }

    @Test
    void testTransform() throws Exception {
        Document xslt = Xml.loadResource(this, "xsl-transform-test.xsl");
        Document input = Xml.loadResource(this, "xsl-transform-test.xml");
        Document output = new XSLTTransformer(xslt, xslt.getBaseURI()).transform(input);
        assertEquals("out", output.getDocumentElement().getTextContent());
    }

    @Test
    void testTransformerException() throws SaxonApiException, SAXException, IOException, ParserConfigurationException {
        assertThrows(SaxonApiException.class, () -> new XSLTTransformer(dummyDocument, dummyDocument.getBaseURI()));
    }

    @Test
    void testMeiInputException() throws SAXException, IOException, SaxonApiException {
        Document xslt = Xml.loadResource(this, "mei-input-exception-test.xsl");
        Transformer transformer = new XSLTTransformer(xslt, xslt.getBaseURI());
        MeiInputException exception = assertThrows(MeiInputException.class, () -> transformer.transform(dummyDocument));
        assertTrue(exception.getMessage().matches(".*test context.+test message.*"));
    }
}