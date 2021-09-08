package de.corpus_musicae_ottomanicae.mei;

import com.google.common.collect.HashBiMap;
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

    private static XPathNodes evaluate(Node context, String xpath) {
        try {
            return xPath.evaluateExpression(xpath, context, XPathNodes.class);
        } catch (XPathExpressionException e) {
            throw new IllegalArgumentException(e);
        }
    }

    /**
     * Convenience method for evaluating XPath expressions that return elements.
     * Will throw errors when the XPath expression is flawed because of syntax or
     * because it does not evaluate to elements.
     *
     * The XPath expression may use the prefixes "mei" and "xlink".
     */
    public static Element[] evaluateToElements(Node context, String xpath) {
        XPathNodes result = evaluate(context, xpath);
        Element[] elements = new Element[result.size()];
        int i = 0;
        for (Node node : result) {
            elements[i] = (Element) node;
            i += 1;
        }
        return elements;
    }

    /**
     * @return An Element if the XPath could be resolved to a single Element, null
     *         if it resolved to multiple Elements or no Element at all.
     */
    public static Element evaluateToElement(Node context, String xpath) {
        Element[] result = evaluateToElements(context, xpath);
        return result.length == 1 ? result[0] : null;
    }

    public static String[] evaluateToStrings(Node context, String xpath) {
        XPathNodes result = evaluate(context, xpath);
        String[] strings = new String[result.size()];
        int i = 0;
        for (Node node : result) {
            strings[i] = node.getTextContent();
            i += 1;
        }
        return strings;
    }

    public static String evaluateToString(Node context, String xpath) {
        Element result = evaluateToElement(context, xpath);
        return result == null ? null : result.getTextContent();
    }
}