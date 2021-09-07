package de.corpus_musicae_ottomanicae.mei;

import com.google.common.collect.HashBiMap;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPathNodes;
import java.util.Collections;
import java.util.Iterator;

public class XPath {
    static final javax.xml.xpath.XPath xPath;

    static {
        HashBiMap<String, String> namespaceByPrefix = HashBiMap.create();
        namespaceByPrefix.put("mei", Constants.MEI_NS);
        namespaceByPrefix.put("xlink", Constants.XLINK_NS);

        javax.xml.xpath.XPath xp = XPathFactory.newInstance().newXPath();

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
                return prefix == null ? Collections.emptyIterator() : Collections.singletonList(prefix).iterator();
            }
        });

        xPath = xp;
    }

    /**
     * Convenience method for evaluating XPath expressions that return elements. May
     * return null if the XPath expression is flawed. May throw an error when the
     * XPath does not evaluate to Elements.
     *
     * The XPath expression may use the prefixes "mei" and "xlink".
     */
    public static Element[] evaluateToElements(Element element, String xpath) {
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

    public static Element[] evaluateToElements(Document doc, String xpath) {
        return evaluateToElements(doc.getDocumentElement(), xpath);
    }

    /**
     * @return An Element if the XPath could be resolved to a single Element, null
     *         if it resolved to multiple Elements or no Element at all.
     */
    public static Element evaluateToElement(Element element, String xpath) {
        Element[] result = evaluateToElements(element, xpath);
        return result.length == 1 ? result[0] : null;
    }

    public static Element evaluateToElement(Document doc, String xpath) {
        return evaluateToElement(doc.getDocumentElement(), xpath);
    }
}