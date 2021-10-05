package de.corpus_musicae_ottomanicae.mei;

import org.w3c.dom.Element;

/**
 * Is thrown when the MEI input data is of a form that can not be processed,
 * e.g. when elements that an operation relies on are missing or when attributes
 * have unexpected values.
 */
public class MeiInputException extends Exception {
    public MeiInputException(Element context, String message) {
        this(contextInfo(context), message);
    }

    /**
     * This constructor should only be used if no context element can be determined,
     * especially when processing XSLTs where the terminating message will have to
     * message the context in a textual way instead of handing on the element.
     */
    public MeiInputException(String context, String message) {
        super(context + ": " + message);
    }

    private static String contextInfo(Element context) {
        String info = "";

        String divisionNumber = Util.contextDivisionNumber(context);
        if (divisionNumber != null) {
            info += "Division " + divisionNumber + ", ";
        }
        info += context.getTagName() + " element";
        if (context.hasAttribute("xml:id")) {
            info += " " + context.getAttribute("xml:id");
        }

        return info;
    }
}
