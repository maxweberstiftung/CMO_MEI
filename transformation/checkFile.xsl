<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:xsldoc="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs math"
    version="3.0">
    <!-- copy every node in file -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsldoc:doc>
        <xsldoc:desc>Contains sanity checks for sibmei output.</xsldoc:desc>
    </xsldoc:doc>
    
    <xsldoc:doc>
        <xsldoc:desc>Checks if there is only one vertical bracket per measure.</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="/">
        <xsl:if test="//mei:measure[count(mei:line[starts-with(@type,'bracket vertical')]) > 1]">
            <xsl:variable name="wrongMeasure" select="//mei:measure[count(mei:line[starts-with(@type,'bracket vertical')]) > 1]"/>
            <xsl:value-of select="error(QName('http://www.corpus-musicae-ottomanicae.de/err', 'cmo:error'),concat('There is more than one vertical bracket line in measure ', $wrongMeasure/@n))"/>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>