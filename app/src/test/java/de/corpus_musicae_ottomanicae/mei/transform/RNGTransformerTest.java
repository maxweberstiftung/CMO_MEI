package de.corpus_musicae_ottomanicae.mei.transform;

import static org.junit.jupiter.api.Assertions.assertThrows;

import java.io.StringReader;

import org.junit.jupiter.api.Test;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import de.corpus_musicae_ottomanicae.Xml;
import de.corpus_musicae_ottomanicae.mei.MeiInputException;

class RNGTransformerTest {
    static final String schema = String.join("\n", //
            "<grammar xmlns='http://relaxng.org/ns/structure/1.0'>", //
            "    <start>", //
            "        <element name='foo'>", //
            "            <empty/>", //
            "        </element>", //
            "    </start>", //
            "</grammar>" //
    );

    @Test
    void validDocument() throws Exception {
        Document validDocument = Xml.parse("<foo/>");
        RNGTransformer transformer = new RNGTransformer(new InputSource(new StringReader(schema)));
        transformer.transform(validDocument);
    }

    @Test
    void invalidDocument() throws Exception {
        Document invalidDocument = Xml.parse("<bar/>");
        RNGTransformer transformer = new RNGTransformer(new InputSource(new StringReader(schema)));
        assertThrows(MeiInputException.class, () -> transformer.transform(invalidDocument));
    }
}