package de.corpus_musicae_ottomanicae.mei.transform;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.dom.DOMSource;

import org.w3c.dom.Document;

import net.sf.saxon.s9api.DOMDestination;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Xslt30Transformer;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;

public class XSLTTransformer implements Transformer {

    private final Xslt30Transformer transformer;
    private static final Processor processor = new Processor(false);
    private static final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

    public XSLTTransformer(Document xslt) throws SaxonApiException {
        XsltCompiler xsltCompiler = processor.newXsltCompiler();
        XsltExecutable executable = xsltCompiler.compile(
                new DOMSource(xslt.getDocumentElement()));
        transformer = executable.load30();
    }

    @Override
    public Document transform(Document input) throws Exception {
        Document output = factory.newDocumentBuilder().newDocument();
        transformer.transform(new DOMSource(input), new DOMDestination(output));
        return output;
    }
}
