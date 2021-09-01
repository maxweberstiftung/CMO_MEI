package de.corpus_musicae_ottomanicae.mei.transform;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;

import de.corpus_musicae_ottomanicae.XmlLoader;

class XSLTTransformerTest {
    @Test
    void testTransform() throws Exception {
        Document xslt = XmlLoader.loadResource(this, "xsl-transform-test.xsl");
        Document input = XmlLoader.loadResource(this, "xsl-transform-test.xml");
        Document output = new XSLTTransformer(xslt).transform(input);
        assertEquals("out", output.getDocumentElement().getTextContent());
    }
}