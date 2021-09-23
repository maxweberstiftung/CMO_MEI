package de.corpus_musicae_ottomanicae;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
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
     * Function for retrieving resources that are stored
     *
     * @param object The class of this object will be used to determine the resource
     *               path. Can be an instance or a Class.
     */
    public static Document loadResource(Object object, String fileName)
            throws SAXException, IOException, ParserConfigurationException {
        Class<?> klass;
        if (object instanceof Class) {
            klass = (Class<?>) object;
        } else {
            klass = object.getClass();
        }
        return parse(new InputStreamReader(klass.getResourceAsStream(fileName)));
    }

    public static Document parse(String xmlString) throws SAXException, IOException, ParserConfigurationException {
        return parse(new InputSource(new StringReader(xmlString)));
    }

    public static Document parse(InputSource input) throws SAXException, IOException, ParserConfigurationException {
        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        builderFactory.setNamespaceAware(true);
        return builderFactory.newDocumentBuilder().parse(input);
    }

    public static String serialize(Node node) {
        StringWriter stringWriter = new StringWriter();
        try {
            TransformerFactory.newInstance().newTransformer().transform(new DOMSource(node),
                    new StreamResult(stringWriter));
        } catch (TransformerException | TransformerFactoryConfigurationError e) {
            // Transformer configuration is expected to be O.K. and StringWriter
            // should not be prone to errors, so handle this as unchecked
            // exception.
            throw new RuntimeException(e);
        }
        return stringWriter.toString();
    }
}
