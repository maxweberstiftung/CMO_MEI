package de.corpus_musicae_ottomanicae.mei;

import de.corpus_musicae_ottomanicae.XmlLoader;
import de.corpus_musicae_ottomanicae.mei.Constants.AEUAccidental;
import de.corpus_musicae_ottomanicae.mei.Constants.PName;
import org.junit.jupiter.api.Test;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.diff.Diff;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.IOException;
import java.io.StringWriter;

import static org.junit.jupiter.api.Assertions.assertEquals;

class AEUKeySignatureTest {
    @Test
    public void TestCMOLabelN() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("N");
        assertEquals(new AEUKeySignature(), keySig);
    }

    @Test
    public void TestEmptyCMOLabel() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("");
        assertEquals(new AEUKeySignature(), keySig);
    }

    @Test
    public void TestCMOLabel4b8K() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("4b 8K");
        AEUKeySignature expectedKeySig = new AEUKeySignature();
        expectedKeySig.add(PName.b, AEUAccidental.bf, 4, 4);
        expectedKeySig.add(PName.f, AEUAccidental.ks, 5, 8);
        assertEquals(expectedKeySig, keySig);
    }

    @Test
    public void TestCMOLabel4b() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("4b");
        AEUKeySignature expectedKeySig = new AEUKeySignature();
        expectedKeySig.add(PName.b, AEUAccidental.bf, 4, 4);
        assertEquals(expectedKeySig, keySig);
    }

    @Test
    public void TestCMOLabel4k8B5B7B3B() {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("4k 8B 5B 7B 3B");
        AEUKeySignature expectedKeySig = new AEUKeySignature();
        expectedKeySig.add(PName.b, AEUAccidental.kf, 4, 4);
        expectedKeySig.add(PName.f, AEUAccidental.bs, 5, 8);
        expectedKeySig.add(PName.c, AEUAccidental.bs, 5, 5);
        expectedKeySig.add(PName.e, AEUAccidental.bs, 5, 7);
        expectedKeySig.add(PName.a, AEUAccidental.bs, 4, 3);
        assertEquals(expectedKeySig, keySig);
    }

    @Test
    public void TestToMei() throws IOException, ParserConfigurationException, SAXException, TransformerException {
        AEUKeySignature keySig = AEUKeySignature.parseFromCMOInstrumentLabel("4b 8K");
        Element expected = XmlLoader.parse(String.join("", //
                "<keySig xmlns='" + Constants.MEI_NS + "'>", //
                "<keyAccid pname='b' accid='bf' oct='4' loc='4'/>", //
                "<keyAccid pname='f' accid='ks' oct='5' loc='8'/>", //
                "</keySig>" //
        )).getDocumentElement();
        StringWriter sw = new StringWriter();
        TransformerFactory.newInstance().newTransformer()
                .transform(new DOMSource(keySig.toMei(expected.getOwnerDocument())), new StreamResult(sw));

        Diff xmlDiff = DiffBuilder //
                .compare(expected) //
                .withTest(keySig.toMei(expected.getOwnerDocument())) //
                .ignoreWhitespace() //
                .build();
        assert !xmlDiff.hasDifferences();
    }
}