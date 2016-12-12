<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="mei:note mei:beam mei:rest mei:chord mei:symbol mei:verse mei:syl mei:accid mei:symbol mei:dir mei:supplied mei:anchoredText"/>
    
    <!-- add schema to file -->
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            <xsl:text>href="https://raw.githubusercontent.com/music-encoding/music-encoding/v3.0.0/schemata/mei-CMN.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
        </xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">
            <xsl:text>href="https://raw.githubusercontent.com/music-encoding/music-encoding/v3.0.0/schemata/mei-CMN.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>>
        </xsl:processing-instruction>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:copy-of select="*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>cmo_transform2cnm</xsl:text>
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
    
    <!-- delete Usûl name -->
    <xsl:template match="mei:anchoredText[@label='Usûl name']"/>
    
    <!-- cleaning keyAccidentals -->
    <!-- remove @accid -->
    <xsl:template match="mei:keyAccid">
        <xsl:copy>
            <xsl:apply-templates select="@* except @accid"/>
            <xsl:if test="@accid = 'n'">
                <xsl:apply-templates select="@accid"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- cleaning accidentals -->
    <!-- remove accid -->
    <xsl:template match="mei:accid[@accid]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @accid"/>
            <xsl:if test="@accid = 'n'">
                <xsl:apply-templates select="@accid"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- in case of @accid.ges, remove it and add @corresp with ref to preceeding accid -->
    <xsl:template match="mei:accid[@accid.ges]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @accid.ges"/>
            <xsl:choose>
                <xsl:when test="@accid.ges = 'n'">
                    <xsl:apply-templates select="@accid.ges"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="accid" select="string(./@accid.ges)"/>
                    <xsl:variable name="parentNote" select="parent::mei:note"/>
                    <xsl:variable name="precedingAccid" select="ancestor::mei:layer//mei:note[@pname = $parentNote/@pname and @oct = $parentNote/@oct]/mei:accid[@accid = $accid and not(@func='caution')]"/>
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="concat('#',$precedingAccid/@xml:id)"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- link division signs to end of measure -->
    <xsl:template match="mei:dir[mei:symbol/@type='End_cycle' or mei:symbol/@type='Division']">
        <!-- get startid of current direction -->
        <xsl:variable name="startid" select="substring(./@startid,2)"/>
        <!-- get last note of melody staff -->
        <xsl:variable name="end_melody_id" select="if (preceding-sibling::*[(name() = 'note') or (name() = 'rest') or (name() = 'beam')][ancestor::mei:staff/@n='1'][1]/name() = 'beam') then string(preceding::mei:beam[ancestor::mei:staff/@n='1'][1]/*[last()]/@xml:id) else string(preceding::*[(name() = 'note') or (name() = 'rest')][ancestor::mei:staff/@n='1'][1]/@xml:id)"/>
        <!-- get last numerator of time signatur -->
        <xsl:variable name="currentMeterCount" select="preceding::mei:scoreDef[1]/@meter.count"/>
        <xsl:copy>
            <xsl:apply-templates select="@* except @startid"/>
            <xsl:choose>
                <!-- if id of last note or rest in the layer 
                    is equal to the startid of the current directive,
                    then change the current reference to a tstamp referring to the end of the measure
                -->
                <xsl:when test="$startid = $end_melody_id">
                    <xsl:attribute name="tstamp">
                        <xsl:value-of select="$currentMeterCount+1"/>
                    </xsl:attribute>
                </xsl:when>
                <!-- else: process @startid as it is -->
                <xsl:otherwise>
                    <xsl:apply-templates select="@startid"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- process child elements -->
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- delete wholeNote symbol because in cnm we use the semantically correct tied half notes -->
    <xsl:template match="mei:dir[mei:symbol/@type='wholeNote']"/>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>