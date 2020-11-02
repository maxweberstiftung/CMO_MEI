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
        <desc>Removes dispensable attributes, like midi-related information and automatically created anchored text elements.</desc>
    </doc>
    
    <!-- clean notes -->
    <xsldoc:doc>
        <xsldoc:desc>Remove @oct.ges</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:note/@oct.ges"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove @pnum</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:note/@pnum"/>
    
    <!-- remove midi-related attributes from notes, rests and chords -->
    <xsldoc:doc>
        <xsldoc:desc>Remove @dur.ppq</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="@dur.ppq"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove @tstamp.real</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="@tstamp.real"/>
    
    
    <!-- clean scoreDef -->
    <xsldoc:doc>
        <xsldoc:desc>Remove fontname for lyrics</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@lyric.name"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove name of music font</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@music.name"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove page bottom margin</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@page.botmar"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove page height</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@page.height"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove page left margin</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@page.leftmar"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove page right margin</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@page.rightmar"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove page top margin</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@page.topmar"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove page width</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@page.width"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove pulses per quarter note</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@ppq"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove text fontname</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:scoreDef/@text.name"/>
    
    <!-- clean staffDef -->
    <xsldoc:doc>
        <xsldoc:desc>Remove instrument definition</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:staffDef/mei:instrDef"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove key mode because it's wrong anyway</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:staffDef/@key.mode"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove key signature because it's wrong anyway</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:staffDef/@key.sig"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove clef displacement because it's wrong anyway</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:staffDef/@clef.dis"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove clef displacement because it's wrong anyway</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:staffDef/@clef.dis.place"/>
    <xsldoc:doc>
        <xsldoc:desc>Remove comments from staffDef</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:staffDef/comment()"/>
    
    
    <xsldoc:doc>
        <xsldoc:desc>Delete verses with empty syllables </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:verse[not(mei:syl/text())]"/>
    
    <xsldoc:doc>
        <xsldoc:desc>Delete empty syllables </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:syl[not(text())]"/>
    
</xsl:stylesheet>