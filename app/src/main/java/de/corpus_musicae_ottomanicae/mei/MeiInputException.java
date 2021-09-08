package de.corpus_musicae_ottomanicae.mei;

import org.w3c.dom.Element;

public class MeiInputException extends Exception {
    public MeiInputException(Element context, String message) {
        // As super() needs to be the first thing we call in the constructor,
        // squeeze all the message construction into one line
        super(contextInfo(context) + ": " + message);
    }

    private static String contextInfo(Element context) {
        String info = "";

        info += "Division " + Util.contextDivisionNumber(context) + ", ";
        info += context.getTagName() + "element";
        if (context.hasAttribute("xml:id")) {
            info += " " + context.getAttribute("xml:id");
        }

        return info;
    }
}
