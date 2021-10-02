package de.corpus_musicae_ottomanicae.mei.transform;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

import javax.swing.JOptionPane;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import de.corpus_musicae_ottomanicae.Xml;
import de.corpus_musicae_ottomanicae.mei.MeiInputException;
import de.corpus_musicae_ottomanicae.mei.transform.Transformer.TransformerException;
import net.sf.saxon.s9api.SaxonApiException;
import picocli.CommandLine;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

public class MeiPostprocessor implements Runnable {
    @Option(names = "--xslt-dir", required = true, description = "Full path to directorry of XSLTs. XSLTs in this directory are processed in alphanumeric order.")
    File xsltDir;

    @Parameters(arity = "1..*", description = "Full paths to MEI files. Files will be overwritten.")
    File[] meis;

    @Override
    public void run() {
        if (!xsltDir.isDirectory()) {
            showError("--xslt-dir must point to a directory, but it points to " + xsltDir.getPath());
            return;
        }

        Map<Path, Exception> errors;
        try {
            errors = transform(meis);
        } catch (TransformerException e) {
            showError("Runtime exception\n\n" + e.getMessage());
            return;
        }
        if (errors.size() > 0) {
            String message = errors.entrySet().stream() //
                    .map(e -> (e.getKey() + "\n" + e.getValue().getMessage()).replace("\n", "\n    ")) //
                    .collect(Collectors.joining("\n\n"));
            showError(message);
        }
    }

    public static void main(String[] args) {
        System.exit(new CommandLine(new MeiPostprocessor()).execute(args));
    }

    /**
     * Transforms all documents in the array and writes them back to their original
     * file name.
     *
     * @return Exceptions that occurred while transforming the documents, keyed by
     *         the document's file path.
     */
    public Map<Path, Exception> transform(File[] files) throws TransformerException {
        TransformerChain transformers = compileTransformers();
        HashMap<Path, Exception> errors = new HashMap<>();
        for (File file : files) {
            try {
                Document source = Xml.parse(new FileInputStream(file));
                Document result = transformers.transform(source);
                Xml.write(result.getDocumentElement(), file);
            } catch (SAXException | IOException | MeiInputException | javax.xml.transform.TransformerException e) {
                errors.put(file.toPath(), e);
            }
        }
        return errors;
    }

    public TransformerChain compileTransformers() throws TransformerException {
        ArrayList<Transformer> transformers = new ArrayList<>();

        transformers.add(new AccidentalTransformer());

        File[] xslts = xsltDir.listFiles((dir, name) -> name.endsWith(".xsl"));
        // Make processing order reliable by sorting alphabetically
        Arrays.sort(xslts, Comparator.comparing(File::getName, String.CASE_INSENSITIVE_ORDER));

        for (File xslt : xslts) {
            try {
                Document xsltDoc = Xml.parse(new FileInputStream(xslt));
                transformers.add(new XSLTTransformer(xsltDoc, xslt.toURI().toString()));
            } catch (SaxonApiException | SAXException | IOException e) {
                throw new TransformerException(e);
            }
        }

        return new TransformerChain(transformers);
    }

    static void showError(String message) {
        System.err.println(message);
        JOptionPane.showMessageDialog(null, message, "Error Processing Files", JOptionPane.WARNING_MESSAGE);
        System.exit(1);
    }
}
