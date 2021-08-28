package de.corpus_musicae_ottomanicae.mei.transform;

import java.util.Collections;
import java.util.Iterator;

import javax.swing.JOptionPane;
import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPathNodes;

import com.google.common.collect.HashBiMap;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

public class MeiPostprocessor {

    public static void main(String[] args) {
        if (args.length == 0) {
            showError("No files given");
            return;
        }
    }

    public static final String MEI_NS = "http://www.music-encoding.org/ns/mei";
    public static final String XLINK_NS = "http://www.w3.org/1999/xlink";

    static final XPath xPath;

    private static int j;
    static {
        HashBiMap<String, String> namespaceByPrefix = HashBiMap.create();
        namespaceByPrefix.put("mei", MEI_NS);
        namespaceByPrefix.put("xlink", XLINK_NS);

        XPath xp = XPathFactory.newInstance().newXPath();

        xp.setNamespaceContext(new NamespaceContext() {
            @Override
            public String getNamespaceURI(String prefix) {
                return namespaceByPrefix.get(prefix);
            }

            @Override
            public String getPrefix(String namespaceUri) {
                Iterator<String> prefixes = getPrefixes(namespaceUri);
                return prefixes.hasNext() ? prefixes.next() : null;
            }

            @Override
            public Iterator<String> getPrefixes(String namespaceUri) {
                String prefix = namespaceByPrefix.inverse().get(namespaceUri);
                // TODO: Handle null prefix
                return Collections.singletonList(prefix).iterator();
            }
        });

        xPath = xp;
    }

    /**
     * Convenience method for evaluating XPath expressions that return elements. May
     * return null if the XPath expression is flawed.
     */
    static Element[] getElements(Element element, String xpath) {
        XPathNodes result;
        try {
            result = (XPathNodes) xPath.evaluateExpression(xpath, element, XPathNodes.class);
        } catch (XPathExpressionException e) {
            return null;
        }
        Element[] elements = new Element[result.size()];
        int i = 0;
        for (Node node : result) {
            elements[i] = (Element) node;
            i += 1;
        }
        return elements;
    }

    static Element[] getElements(Document document, String xpath) {
        return getElements(document.getDocumentElement(), xpath);
    }

    /**
     * If the XPath resolves to precisely one element, returns that element,
     * otherwise null.
     */
    static Element getElement(Element element, String xpath) {
        Element[] elements = getElements(element, xpath);
        System.err.println(elements.length);
        return elements.length == 1 ? elements[0] : null;
    }

    static Element getElement(Document document, String xpath) {
        return getElement(document.getDocumentElement(), xpath);
    }

    public static void showError(String message) {
        JOptionPane.showMessageDialog(null, message, "Error Processing Files", JOptionPane.WARNING_MESSAGE);
    }

    public static void transformAccids(Document mei) {
        // TODO: Implement this
    }
}
