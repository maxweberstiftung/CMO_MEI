package de.corpus_musicae_ottomanicae.mei.transform;

import java.util.List;

import org.w3c.dom.Document;

/**
 * A collection of multiple transformers which are performed in order
 */
public class TransformerChain implements Transformer {
    
    private final List<Transformer> transforms;

    public TransformerChain(List<Transformer> transforms) {
        this.transforms = transforms;
    }

    @Override
    public Document transform(Document input) throws Exception {
        for (Transformer transform : transforms) {
            input = transform.transform(input);
        }
        return input;
    }

}
