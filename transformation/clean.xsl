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
    
    <!--<xsl:strip-space elements="mei:note mei:staffDef"/>-->
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            Removes dispensable attributes, like midi-related information and automatically created anchored text elements.
            Fixes export of verse numbers.
        </desc>
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
    
    <!-- misc -->
    <xsldoc:doc>
        <xsldoc:desc>Delete added duration annot within score</xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:annot[@type='duration']"/>
    
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
    
    <!-- Clean Lyrics -->
    <xsldoc:doc>
        <xsldoc:desc>Delete verses with empty syllables </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:verse[not(mei:syl/text())]"/>
    
    <xsldoc:doc>
        <xsldoc:desc>Delete empty syllables </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:syl[not(text())]"/>
    
    <xsldoc:doc>
        <xsldoc:desc>
            Correct encoding of verse numbers. After export, they are individual verse attributes, but this is obviously wrong.
            Put verse numbers in labels inside verse instead.
        </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:note[mei:verse]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()[name() != 'verse']"/>
            <!-- Verse number verses can be detected by doublicate @n attributes -->
            <xsl:variable name="verses" select="mei:verse"/>
            <xsl:for-each select="distinct-values(mei:verse/@n)">
                <xsl:variable name="num" select="." as="xs:integer"/>
                <xsl:variable name="currentVerses" select="$verses[@n=$num]"/>
                <xsl:choose>
                    <!-- try to merge verse numbers and first syllables -->
                    <xsl:when test="count($currentVerses)=2">
                        <!-- check which one is the verse number -->
                        <xsl:variable name="verseNum" select="$currentVerses[matches(mei:syl,'\d.')]"/>
                        <xsl:variable name="verseSyl" select="$currentVerses[@xml:id!=$verseNum/@xml:id]"/>
                        
                        <xsl:element name="verse" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:apply-templates select="$verseSyl/@*"/>
                            <xsl:element name="label" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="$verseNum/mei:syl/@xml:id"/>
                                </xsl:attribute>
                                <xsl:value-of select="$verseNum/mei:syl"/>
                            </xsl:element>
                            <xsl:element name="syl" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:apply-templates select="$verseSyl/mei:syl/@*"/>
                                <xsl:value-of select="$verseSyl/mei:syl"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$currentVerses"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>