package de.corpus_musicae_ottomanicae.mei;

import org.w3c.dom.Element;

public class Util {
    public static String contextDivisionNumber(Element element) {
        Element measure = XPath.evaluateToElement(element, "ancestor-or-self::mei:measure[1]");
        if (measure == null) {
            throw new IllegalArgumentException("Descendant of measure expected");
        }
        for (String attribute : new String[] { "label", "n" }) {
            if (measure.hasAttribute(attribute)) {
                String value = measure.getAttribute(attribute);
                return value.isEmpty() ? "[empty " + attribute + " attribute]" : value;
            }
        }
        return "[without division number]";
    }

    public static String getAttributeOrDefault(Element element, String attribute, String defaultValue) {
        return element.hasAttribute(attribute) ? element.getAttribute(attribute) : defaultValue;
    }
}
