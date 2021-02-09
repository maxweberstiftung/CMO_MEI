# CMO_MEI
Transformation scripts for the Music Edition of _Corpus Musicae Ottomanicae_.
This series of XSLT transformation scripts clean and rectify the MEI output 
of Sibelius.
The use of these XSLT transformation script requires the use of the _CMO_ 
Sibelius house styles and the MEI export made with 
a sibmei version containing the extension API and the CMO sibmei extension.
Otherwise, crucial parts of the Edition can't be processed.

## `checkFile`

This script runs basic integrety tests for the transformation.
* Check for only one vertical bracket per measure to indicate substitution.

Should be run first in the transformation process.

## `clean`

Removes dispensable attributes, like midi-related information and automatically 
created anchored text elements.   
Fixes the export of verse numbers.

## `bracketSpan`

Converts the opening and closing bracket symbols of the Sibelius output into
`<bracketSpan func='hampartsum_group'>`.

## `transformAccid`

Converts the semantically wrong accidentals of the Sibelius output into proper
AEU accidentals.
* Convertes the values of @accid and @accid.ges according to the CMO house styles 
 into AEU accidentals.
* Adds gestural natural accidentals following an explicit natural in a measure.
* Creates proper key accidentals in the staffDef according to the instrument
 descriptions.

## `generateIDs`

Generates (hopefully) unique xml:ids for newly generated elements by combining
the ID of the next ancestor with xml:id with the element name and position of
ancestral elements.
Should be run as last step in the transformation process.
