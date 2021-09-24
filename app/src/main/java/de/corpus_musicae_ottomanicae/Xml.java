package de.corpus_musicae_ottomanicae;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PushbackInputStream;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.nio.file.Path;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Result;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class Xml {
    /**
     * Function for retrieving resources that are stored in the "classpath folder"
     * corresponding to the object argument.
     *
     * @param object The class of this object will be used to determine the resource
     *               path. Can be an instance or a Class.
     */
    public static Document loadResource(Object object, String fileName) throws SAXException, IOException {
        Class<?> klass;
        if (object instanceof Class) {
            klass = (Class<?>) object;
        } else {
            klass = object.getClass();
        }
        return parse(klass.getResourceAsStream(fileName));
    }

    public static Document parse(String xmlString) throws SAXException, IOException, ParserConfigurationException {
        return parse(new StringReader(xmlString));
    }

    /**
     * Detects the encoding (UTF-8, UTF-16LE, UTF-16BE) and parses the document.
     */
    public static Document parse(InputStream stream)
            throws FileNotFoundException, UnsupportedEncodingException, SAXException, IOException {
        PushbackInputStream pushbackStream = new PushbackInputStream(stream, 2);
        String charsetName = guessEncoding(pushbackStream);
        return parse(new InputStreamReader(pushbackStream, charsetName));
    }

    public static Document parse(Reader input) throws SAXException, IOException {
        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        builderFactory.setNamespaceAware(true);
        try {
            return builderFactory.newDocumentBuilder().parse(new InputSource(input));
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e); // should be unreachable
        }
    }

    static void writeToResult(Node node, Result result) throws TransformerException {
        try {
            TransformerFactory.newInstance().newTransformer().transform(new DOMSource(node), result);
        } catch (TransformerFactoryConfigurationError e) {
            // Should be unreachable as transformer configuration is unchanged
            throw new RuntimeException(e);
        }
    }

    public static String serialize(Node node) {
        var stringWriter = new StringWriter();
        try {
            writeToResult(node, new StreamResult(stringWriter));
        } catch (TransformerException e) {
            // Should be unreachable
            throw new RuntimeException(e);
        }
        return stringWriter.toString();
    }

    public static void write(Node node, Path path) throws FileNotFoundException, TransformerException {
        writeToResult(node, new StreamResult(new FileOutputStream(path.toFile())));
    }

    /**
     * Consumes any existent BOM and returns an encoding string. Defaults to UTF-8,
     * if no other encoding was plausible.
     *
     * @param stream PushbackInputStream with pushback buffer size of at least 2.
     */
    static String guessEncoding(PushbackInputStream stream) throws IOException {
        byte[] bom = new byte[2];
        if (stream.read(bom) < 2) {
            throw new IOException("File is too short");
        }
        int bomValue = Byte.toUnsignedInt(bom[0]) * 256 + Byte.toUnsignedInt(bom[1]);
        switch (bomValue) {
            case 0xFFFE:
                return "UTF-16LE";
            case 0xFEFF:
                return "UTF-16BE";
            case 0xEFBB:
                // UTF-8 BOM is EFBBBF
                if (stream.read() != 0xBF) {
                    throw new IOException("Unexpected leading bytes in file");
                }
                return "UTF-8";
        }

        // File has no (recognized) BOM.
        // As we're working with XML, the first character must be ASCII (either
        // whitespace or "<"), so in UTF-16BE the first byte will be 0 and in
        // UTF-16LE, the second byte will be 0.
        stream.unread(bom);
        if (bom[0] == 0) {
            return "UTF-16BE";
        } else if (bom[1] == 0) {
            return "UTF-16LE";
        } else {
            // Default to UTF-8
            return "UTF-8";
        }
    }
}
