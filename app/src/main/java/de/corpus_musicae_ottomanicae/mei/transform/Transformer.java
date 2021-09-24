package de.corpus_musicae_ottomanicae.mei.transform;

import org.w3c.dom.Document;

import de.corpus_musicae_ottomanicae.mei.MeiInputException;

public interface Transformer {
    /**
     * An implementation may either return the modified input Document or generate a
     * new Document as output.
     */
    Document transform(Document input) throws MeiInputException, TransformerException;

    public class TransformerException extends Exception {
        TransformerException(Exception e) {
            super(e);
        }
    }
}
