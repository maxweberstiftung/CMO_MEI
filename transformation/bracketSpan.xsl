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
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            Converts opening and closing bracket symbols into bracketSpans for Hampartsum groups.
            Corrects positioning of bracketSpan start in case of leading grace notes
        </desc>
    </doc>
    
    
    <!-- Variables for hampartsum groups -->
    <xsl:variable name="group_start" select="'U+E201'"/>
    <xsl:variable name="group_end" select="'U+E203'"/>
    
    <xsldoc:doc>
        <xsldoc:desc>
            Searches for the beginning bracket and creates the bracketSpan element.
            The attributes from the first following closing bracket will be loaded 
        </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:dir[mei:symbol/@glyph.num=$group_start]">
        <xsl:variable name="followingEnd" select="following-sibling::mei:dir[mei:symbol/@glyph.num=$group_end][1]"/>
        
        <xsl:element name="bracketSpan" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="xml:id" select="@xml:id"/>
            <xsl:attribute name="func" select="'hampartsum_group'"/>
            <xsl:attribute name="startid" select="@startid"/>
            <xsl:attribute name="tstamp" select="@tstamp"/>
            <xsl:if test="@vo">
                <xsl:attribute name="startvo" select="@vo"/>    
            </xsl:if>
            <xsl:if test="@ho">
                <xsl:attribute name="startho" select="@ho"/>    
            </xsl:if>
            <xsl:attribute name="endid" select="$followingEnd/@startid"/>
            <xsl:attribute name="tstamp2" select="$followingEnd/@tstamp"/>
            <xsl:if test="$followingEnd/@vo">
                <xsl:attribute name="endvo" select="$followingEnd/@vo"/>
            </xsl:if>
            <xsl:if test="$followingEnd/@ho">
                <xsl:attribute name="endho" select="$followingEnd/@ho"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <!-- remove end bracket -->
    <xsldoc:doc>
        <xsldoc:desc>Suppress the ending bracket symbol because it is already been taken care of.</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:dir[mei:symbol/@glyph.num=$group_end]"/>
    
</xsl:stylesheet>


