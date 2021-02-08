<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xsldoc="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs math"
    version="3.0">
    <!-- copy every node in file -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            Add xml:ids to each newly generated element.
            Should be started as last script in transformation.
        </desc>
    </doc>    
    
    <xsldoc:doc>
        <xsldoc:desc>
            Add xml:ids to each newly generated element.
            ID value comprises of the first ancestral id and a list of elements without ids
            containing node names and number of preceding siblings + 1.
        </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="*[not(@xml:id)]">
        <xsl:variable name="ancestorID" select="ancestor::node()[@xml:id][1]/@xml:id"/>
        <xsl:variable name="acestorSelfTillID">
            <xsl:for-each select="ancestor-or-self::*[not(@xml:id)]">
                <xsl:value-of select="concat('-', ./node-name(), count(preceding-sibling::*)+1)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat($ancestorID, $acestorSelfTillID)"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>