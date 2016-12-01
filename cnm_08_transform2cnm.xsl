<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- add schema to file -->
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            <xsl:attribute name="href">
                <xsl:value-of select="'https://raw.githubusercontent.com/music-encoding/music-encoding/v3.0.0/schemata/mei-CMN.rng'"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="'application/xml'"/>
            </xsl:attribute>
            <xsl:attribute name="schematypens">
                <xsl:value-of select="'http://relaxng.org/ns/structure/1.0'"/>
            </xsl:attribute>
        </xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">
            <xsl:attribute name="href">
                <xsl:value-of select="'https://raw.githubusercontent.com/music-encoding/music-encoding/v3.0.0/schemata/mei-CMN.rng'"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="'application/xml'"/>
            </xsl:attribute>
            <xsl:attribute name="schematypens">
                <xsl:value-of select="'http://purl.oclc.org/dsdl/schematron'"/>
            </xsl:attribute>
        </xsl:processing-instruction>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:copy-of select="*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>cmo:transform2cnm</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO transform Output to cnm</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- cleaning keyAccidentals -->
    <!-- remove @accid -->
    
    <!-- cleaning accidentals -->
    <!-- remove accid -->
    <!-- in case of @accid.ges, remove it and add @corresp with ref to preceeding accid -->
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>