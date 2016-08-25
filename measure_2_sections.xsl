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
                    <xsl:text>measure_2_sections</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO measure to section transformation prototype</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- convert measures into sections -->
    <xsl:template match="mei:measure">
        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy-of select="@xml:id"/>
            <xsl:copy-of select="@n"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- add barlines to layer -->
    <xsl:template match="mei:layer">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="./ancestor::mei:measure/@left">
                <xsl:element name="barLine" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="form">
                        <xsl:value-of select="./ancestor::mei:measure/@left"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="./ancestor::mei:measure/@right">
                <xsl:element name="barLine" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="form">
                        <xsl:value-of select="./ancestor::mei:measure/@right"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
        
    </xsl:template>
    
    <!-- add dir to referenced note -->
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>