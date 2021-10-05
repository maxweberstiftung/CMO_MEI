# CMO Postprocessing tools
Transformation tools for the Music Edition of _Corpus Musicae Ottomanicae_.  Takes output from [cmo_sibmei](https://github.com/notengrafik/cmo_sibmei/) as input and transforms the input conventions used by CMO to more semantic MEI. The input conventions in Sibelius e.g. use a house style that includes graphically faked key signatures and accidentals that result in the Sibelius data and the MEI output being initially semantically wrong.  Therefore, postprocessing is crucial.

[Releases of the CMO Sibelius Export plugin](https://github.com/notengrafik/cmo_sibmei/releases) package this tool.  This plugin also automatically postprocesses the MEI data it exports from Sibelius.

## Java tool

The Java tool (in subdirectory `app`) steers multiple transformation steps:

* transforming common western accidentals to Arel-Ezgi-Uzdilek (AEU) accidentals
* running an number of XSLTs (see below)
* a final RNG schema validation

### Compilation

This will create a jar file in `app/build/libs/CmoMeiPostprocessor.jar`:

```
cd app
../gradlew fatJar
```

### Running

Regular users should not have to run this tool directly as it is triggered automatically by the CMO Sibelius export.

On the command line, the compiled jar can be run as follows:

```
java -jar ./app/build/libs/CmoMeiPostprocessor.jar --xslt-dir ./transformation --schema /path/to/cmo-schema.rng /path/to/mei-file.mei
```

The `--schema` option is optional, `--xslt-dir` is required.

### Running tests

```
cd app
../gradlew test --info
```

## XSLTs

This series of XSLT transformation scripts clean and rectify the MEI output
of Sibelius.

### `checkFile`

This script runs basic integrity tests for the transformation.
* Check for only one vertical bracket per measure to indicate substitution.

Should be run first in the transformation process.

### `clean`

Removes dispensable attributes, like midi-related information and automatically 
created anchored text elements.   
Fixes the export of verse numbers.

### `bracketSpan`

Converts the opening and closing bracket symbols of the Sibelius output into
`<bracketSpan func='hampartsum_group'>`.

### `generateIDs`

Generates (hopefully) unique xml:ids for newly generated elements by combining
the ID of the next ancestor with xml:id with the element name and position of
ancestral elements.
Should be run as last step in the transformation process.