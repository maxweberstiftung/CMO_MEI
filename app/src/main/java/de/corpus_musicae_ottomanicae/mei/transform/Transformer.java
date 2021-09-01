package de.corpus_musicae_ottomanicae.mei.transform;

import org.w3c.dom.Document;

public interface Transformer {
    /**
     * An implementation may either return the modified input Document or
     * generate a new Document as output.
     */
    public Document transform(Document input) throws Exception;
}
