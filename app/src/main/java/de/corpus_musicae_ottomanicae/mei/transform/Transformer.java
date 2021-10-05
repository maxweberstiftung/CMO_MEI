package de.corpus_musicae_ottomanicae.mei.transform;

import org.w3c.dom.Document;

import de.corpus_musicae_ottomanicae.mei.MeiInputException;

public interface Transformer {
    /**
     * @return The (modified) input Document, or a newly generated output Document
     * @throws MeiInputException    Signals a problem with the MEI input Document,
     *                              e.g. if the document structure is not as
     *                              expected
     * @throws TransformerException Signals a problem with the transformation
     *                              implementation, especially of XSLT code called
     *                              by XSLTTransformers
     */
    Document transform(Document input) throws MeiInputException, TransformerException;

    public class TransformerException extends Exception {
        TransformerException(Exception e) {
            super(e);
        }

        TransformerException(String message) {
            super(message);
        }
    }
}
