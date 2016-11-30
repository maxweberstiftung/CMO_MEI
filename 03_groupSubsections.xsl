<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:copy-of select="*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>group_subsections</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO group subsections transformation prototype</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- put Hanes into sections and mark measures according to squared bracket lines and division signs -->
    <xsl:template match="mei:measure[mei:anchoredText/@label='Subsection']">
        <!-- keep self as variable for comparing -->
        <xsl:variable name="start_measure" select="."/>
        <!-- get start measure of following section -->
        <xsl:variable name="next_start" select="$start_measure/following-sibling::mei:measure[mei:anchoredText/@label='Section'][1]/@xml:id"/>
        
        <!-- generate section and put self in it -->
        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="id" namespace="http://www.w3.org/XML/1998/namespace">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <!-- Set Section text as label -->
            <xsl:attribute name="label">
                <xsl:value-of select="mei:anchoredText[@label='Subsection']"/>
            </xsl:attribute>
            <xsl:copy>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
            <!-- add following measures between the next start of a section to the active section -->
            <xsl:for-each select="./following-sibling::mei:measure[not(mei:anchoredText/@label='Subsection')][preceding-sibling::mei:measure[mei:anchoredText/@label='Subsection'][1] = $start_measure]">
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="mei:measure[not(mei:anchoredText/@label='Subsection') and preceding-sibling::mei:measure[mei:anchoredText/@label='Subsection']]"/>
    <xsl:template match="mei:anchoredText[@label='Subsection']"/>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>