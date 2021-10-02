package de.corpus_musicae_ottomanicae.mei.transform;

import de.corpus_musicae_ottomanicae.mei.MeiInputException;
import net.sf.saxon.s9api.*;
import org.w3c.dom.Document;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.SourceLocator;
import javax.xml.transform.dom.DOMSource;
import java.util.ArrayList;
import java.util.Iterator;

public class XSLTTransformer implements Transformer {
    static final QName meiInputErrorCode = new QName("MeiInputError");

    static class ExceptionListener implements MessageListener2 {
        public Exception exception = null;

        @Override
        public void message(XdmNode content, QName errorCode, boolean terminate, SourceLocator locator) {
            if (!terminate) {
                // QUESTION: Should this go to stderr?
                System.out.println(content.toString());
                return;
            } else if (errorCode.equals(meiInputErrorCode)) {
                try {
                    exception = messageToMeiInputError(content);
                } catch (TransformerException e) {
                    exception = e;
                }
            } else {
                exception = new TransformerException(content.getStringValue());
            }
        }

        MeiInputException messageToMeiInputError(XdmNode message) throws TransformerException {
            ArrayList<String> exceptionComponents = new ArrayList<>();
            for (String localName : new String[] { "context", "message" }) {
                Iterator<XdmNode> childIterator = message.children(localName).iterator();

                if (!childIterator.hasNext()) {
                    throw new TransformerException("Terminating XSLT message must have a " + localName + " element");
                }
                exceptionComponents.add(childIterator.next().getStringValue());
                if (childIterator.hasNext()) {
                    throw new TransformerException(
                            "Terminating XSLT message must not have multiple " + localName + " elements");
                }
            }
            return new MeiInputException(exceptionComponents.get(0), exceptionComponents.get(1));
        }
    }

    private final XsltExecutable xsltExecutable;
    private static final Processor processor = new Processor(false);
    private static final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

    ExceptionListener exceptionListener = new ExceptionListener();

    public XSLTTransformer(Document xslt, String baseUri) throws SaxonApiException {
        XsltCompiler xsltCompiler = processor.newXsltCompiler();
        DOMSource source = new DOMSource(xslt.getDocumentElement());
        source.setSystemId(baseUri);
        xsltExecutable = xsltCompiler.compile(source);
    }

    @Override
    public Document transform(Document input) throws TransformerException, MeiInputException {
        ExceptionListener exceptionListener = new ExceptionListener();
        Xslt30Transformer transformer = xsltExecutable.load30();
        transformer.setMessageListener(exceptionListener);

        Document output;
        try {
            output = factory.newDocumentBuilder().newDocument();
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e); // should be unreachable
        }

        try {
            transformer.transform(new DOMSource(input), new DOMDestination(output));
        } catch (SaxonApiException e) {
            if (exceptionListener.exception == null) {
                throw new TransformerException(e);
            } else if (exceptionListener.exception instanceof TransformerException) {
                throw (TransformerException) exceptionListener.exception;
            } else if (exceptionListener.exception instanceof MeiInputException) {
                throw (MeiInputException) exceptionListener.exception;
            } else {
                throw new RuntimeException(exceptionListener.exception); // unreachable
            }
        }

        return output;
    }
}
