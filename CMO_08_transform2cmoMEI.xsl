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
                    <xsl:text>transform2cmoMEI</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>Process transformations for CMO-MEI customization</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- change alignment of division signs from last note of melody staff to following barLine -->
    <xsl:template match="mei:dir[mei:symbol/@type='HampEndCycle' or mei:symbol/@type='HampSubDivision']">
        <!-- get startid of current direction -->
        <xsl:variable name="startid" select="substring(./@startid,2)"/>
        <!-- get ID of first preceding barLine element -->
        <xsl:variable name="preceding_barLine" select="preceding-sibling::mei:barLine[1]/@xml:id"/>
        <!-- get last note of melody staff -->
        <xsl:variable name="end_melody_id" select="if (preceding-sibling::*[(name() = 'note') or (name() = 'rest') or (name() = 'beam')][1]/name() = 'beam') then string(preceding::mei:beam[1]/*[last()]/@xml:id) else string(preceding::*[(name() = 'note') or (name() = 'rest')][1]/@xml:id)"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@* except @startid"/>
            <xsl:choose>
                <!-- if id of last note or rest before the preceding::barLine[1] 
                    is equal to the startid of the current directive,
                    then change the current startid to a uri referencing preceding::barLine[1]
                -->
                <xsl:when test="$startid = $end_melody_id">
                    <xsl:attribute name="startid">
                        <xsl:value-of select="concat('#',$preceding_barLine)"/>
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
    
</xsl:stylesheet>