package de.corpus_musicae_ottomanicae;

import java.io.IOException;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class Xml {
    /**
     * Function for retrieving resources that are stored
     *
     * @param object The class of this object will be used to determine the resource
     *               path.
     */
    public static Document loadResource(Object object, String fileName)
            throws SAXException, IOException, ParserConfigurationException {
        return parse(new InputSource(object.getClass().getResourceAsStream(fileName)));
    }

    public static Document parse(String xmlString) throws SAXException, IOException, ParserConfigurationException {
        return parse(new InputSource(new StringReader(xmlString)));
    }

    public static Document parse(InputSource input) throws SAXException, IOException, ParserConfigurationException {
        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        builderFactory.setNamespaceAware(true);
        return builderFactory.newDocumentBuilder().parse(input);
    }
}
