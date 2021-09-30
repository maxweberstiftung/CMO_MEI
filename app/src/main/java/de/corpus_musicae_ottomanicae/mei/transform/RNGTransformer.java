package de.corpus_musicae_ottomanicae.mei.transform;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.thaiopensource.relaxng.SchemaFactory;
import com.thaiopensource.util.PropertyMapBuilder;
import com.thaiopensource.validate.IncorrectSchemaException;
import com.thaiopensource.validate.Schema;
import com.thaiopensource.validate.ValidateProperty;

import org.w3c.dom.Document;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import de.corpus_musicae_ottomanicae.mei.MeiInputException;

public class RNGTransformer implements Transformer {
    class RNGErrorHandler implements ErrorHandler {
        List<String> errors;

        RNGErrorHandler(List<String> errors) {
            this.errors = errors;
        }

        @Override
        public void error(SAXParseException error) {
            errors.add(error.getMessage());
        }

        @Override
        public void fatalError(SAXParseException error) {
            error(error);
        }

        @Override
        public void warning(SAXParseException error) {
            error(error);
        }
    }

    Schema schema;

    RNGTransformer(InputSource rng) throws IOException, SAXException, IncorrectSchemaException {
        schema = new SchemaFactory().createSchema(rng);
    }

    @Override
    public Document transform(Document doc) throws MeiInputException, TransformerException {
        PropertyMapBuilder builder = new PropertyMapBuilder();
        ArrayList<String> errors = new ArrayList<>();
        builder.put(ValidateProperty.ERROR_HANDLER, new RNGErrorHandler(errors));
        schema.createValidator(builder.toPropertyMap());
        if (errors.size() > 0) {
            throw new MeiInputException("", String.join("\n", errors));
        }
        return doc;
    }

}
