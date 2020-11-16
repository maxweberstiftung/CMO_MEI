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
            Converts the semantically wrong overwritten accidentals into proper AEU accidentals and 
            creates proper key signatures from the instrument labels.
        </desc>
    </doc>
    
    <xsldoc:doc>
        <xsldoc:desc>
            Corrects accidental values for written and gestural accidentals.
        </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:accid"></xsl:template>
    
    <xsldoc:doc>
        <xsldoc:desc>
            Modifies the staffDef of the first staff (usually the music staff, while the second staff contains the usul pattern).
            
        </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:staffDef[@n='1']">
        <xsl:variable name="clef-shape" select="@clef.shape"/>
        <xsl:variable name="clef-line" select="@clef.line"/>
        <xsl:variable name="label" select="mei:label"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@n"/>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="@lines"/>
            <xsl:apply-templates select="@clef.shape"/>
            <xsl:apply-templates select="@clef.line"/>
            
            <xsl:choose>
                <!-- In case of 'N' no key signature is needed -->
                <xsl:when test="$label = 'N'"/>
                <xsl:when test="empty($label)"/>
                <xsl:otherwise>
                    <!-- process key signatures -->
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <!-- tokenize @label to process key signatures -->
                        <xsl:for-each select="tokenize($label,'\s+')">
                            <xsl:variable name="accid" select="substring(.,2,1)"/>
                            <xsl:variable name="loc" select="substring(.,1,1)"/>
                            <xsl:variable name="accidVal">
                                <xsl:call-template name="keyAccid2AEUaccid">
                                    <xsl:with-param name="accid" select="$accid"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="oct">
                                <xsl:call-template name="loc2oct">
                                    <xsl:with-param name="loc" select="number($loc)"/>
                                    <xsl:with-param name="clef-shape" select="$clef-shape"/>
                                    <xsl:with-param name="clef-line" select="$clef-line"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="pname">
                                <xsl:call-template name="loc2pname">
                                    <xsl:with-param name="loc" select="number($loc)"/>
                                    <xsl:with-param name="clef-shape" select="$clef-shape"/>
                                    <xsl:with-param name="clef-line" select="$clef-line"/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="xml:id">
                                    <!-- generate ID -->
                                </xsl:attribute>
                                <xsl:attribute name="loc">
                                    <xsl:value-of select="$loc"/>
                                </xsl:attribute>
                                <xsl:attribute name="glyph.num">
                                    <xsl:value-of select="$accidVal"/>
                                </xsl:attribute>
                                <xsl:attribute name="oct">
                                    <xsl:value-of select="$oct"/>
                                </xsl:attribute>
                                <xsl:attribute name="pname">
                                    <xsl:value-of select="$pname"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsldoc:doc>
        <xsldoc:desc>Maps the wrong accidental attributes from the Sibelius output to the correct AEU accidental values.</xsldoc:desc>
        <xsldoc:param name="accid">Irregular accidental value retrieved from Sibelius</xsldoc:param>
    </xsldoc:doc>
    <xsl:template name="sibAccid2AEUaccid">
        <xsl:param name="accid"/>
        <xsl:choose>
            <xsl:when test="@accid = 's'">
                <!-- Bakiye sharp -->
                <xsl:value-of select="'bs'"/>
            </xsl:when>
            <xsl:when test="@accid = 'f'">
                <!-- Küçük mücenneb (flat) -->
                <xsl:value-of select="'kmf'"/>
            </xsl:when>
            <xsl:when test="@accid = 'ff'">
                <!-- Büyük mücenneb (flat) -->
                <xsl:value-of select="'bmf'"/>
            </xsl:when>
            <xsl:when test="@accid = 'x'">
                <!-- Büyük mücenneb (sharp) -->
                <xsl:value-of select="'bms'"/>
            </xsl:when>
            <xsl:when test="@accid = 'fd'">
                <!-- Bakiye (flat) -->
                <xsl:value-of select="'bf'"/>
            </xsl:when>
            <xsl:when test="@accid = 'fu'">
                <!-- Koma (flat) -->
                <xsl:value-of select="'kf'"/>
            </xsl:when>
            <xsl:when test="@accid = 'su'">
                <!-- Küçük mücenneb (sharp) -->
                <xsl:value-of select="'kms'"/>
            </xsl:when>
            <xsl:when test="@accid = 'sd'">
                <!-- Koma (sharp) -->
                <xsl:value-of select="'ks'"/>
            </xsl:when>
            <xsl:when test="@accid = 'n'">
                <!-- n is always n, if it's accig.ges or a real accid, must be determined by @func -->
                <xsl:value-of select="'n'"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- in the case onf any strange cases, just copy them -->
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsldoc:doc>
        <xsldoc:desc>Maps the key accidental value given by the editors to the values for AEU accidentals.</xsldoc:desc>
        <xsldoc:param name="accid">Accid value as string</xsldoc:param>
    </xsldoc:doc>
    <xsl:template name="keyAccid2AEUaccid">
        <xsl:param name="accid"/>
        <xsl:choose>
            <!-- Bakiye flat -->
            <xsl:when test="$accid = 'b'">
                <xsl:value-of select="'bf'"/>
            </xsl:when>
            <!-- Küçük mücenneb flat -->
            <xsl:when test="$accid = 'm'">
                <xsl:value-of select="'kmf'"/>
            </xsl:when>
            <!-- Koma flat -->
            <xsl:when test="$accid = 'k'">
                <xsl:value-of select="'kf'"/>
            </xsl:when>
            <!-- Bakiye sharp -->
            <xsl:when test="$accid = 'B'">
                <xsl:value-of select="'bs'"/>
            </xsl:when>
            <!-- Küçük mücenneb sharp -->
            <xsl:when test="$accid = 'M'">
                <xsl:value-of select="'kms'"/>
            </xsl:when>
            <!-- Koma sharp -->
            <xsl:when test="$accid = 'K'">
                <xsl:value-of select="'ks'"/>
            </xsl:when>
            <!-- Büyük mücenneb flat -->
            <xsl:when test="$accid = 'f'">
                <xsl:value-of select="'bmf'"/>
            </xsl:when>
            <!-- Büyük mücenneb sharp -->
            <xsl:when test="$accid = 'S'">
                <xsl:value-of select="'bms'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsldoc:doc>
        <xsldoc:desc>Retrieves the pitch name for the key accidental by the given loc.</xsldoc:desc>
        <xsldoc:param name="loc">Staff location as number</xsldoc:param>
        <xsldoc:param name="clef-line">Clef line of staffDef, should always be "2" according to House Styles</xsldoc:param>
        <xsldoc:param name="clef-shape">Clef shape of staffDef, should always be "G" accourding to House Styles</xsldoc:param>
    </xsldoc:doc>
    <xsl:template name="loc2pname">
        <xsl:param name="loc" as="xs:double"/>
        <xsl:param name="clef-line"/>
        <xsl:param name="clef-shape"/>
        <xsl:if test="($clef-line = 2) and ($clef-shape = 'G')">
            <xsl:choose>
                <xsl:when test="($loc = -9) or ($loc = -2) or ($loc = 5) or ($loc = 12)">
                    <xsl:value-of select="'c'"/>
                </xsl:when>
                <xsl:when test="($loc = -8) or ($loc = -1) or ($loc = 6)">
                    <xsl:value-of select="'c'"/>
                </xsl:when>
                <xsl:when test="($loc = -7) or ($loc = 0) or ($loc = 7)">
                    <xsl:value-of select="'c'"/>
                </xsl:when>
                <xsl:when test="($loc = -6) or ($loc = 1) or ($loc = 8)">
                    <xsl:value-of select="'f'"/>
                </xsl:when>
                <xsl:when test="($loc = -5) or ($loc = 2) or ($loc = 9)">
                    <xsl:value-of select="'g'"/>
                </xsl:when>
                <xsl:when test="($loc = -4) or ($loc = 3) or ($loc = 10)">
                    <xsl:value-of select="'a'"/>
                </xsl:when>
                <xsl:when test="($loc = -3) or ($loc = 4) or ($loc = 11)">
                    <xsl:value-of select="'b'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsldoc:doc>
        <xsldoc:desc>Retrieves the octave number for the key accidental by the given loc.</xsldoc:desc>
        <xsldoc:param name="loc">Staff location as number</xsldoc:param>
        <xsldoc:param name="clef-line">Clef line of staffDef, should always be "2" according to House Styles</xsldoc:param>
        <xsldoc:param name="clef-shape">Clef shape of staffDef, should always be "G" accourding to House Styles</xsldoc:param>
    </xsldoc:doc>
    <xsl:template name="loc2oct">
        <xsl:param name="loc" as="xs:double"/>
        <xsl:param name="clef-line"/>
        <xsl:param name="clef-shape"/>
        <xsl:if test="($clef-line = 2) and ($clef-shape = 'G')">
            <xsl:choose>
                <xsl:when test="($loc &gt;= -9) and ($loc &lt;= -3)">
                    <xsl:value-of select="'3'"/>
                </xsl:when>
                <xsl:when test="($loc &lt;= 4) and ($loc &gt;= -2)">
                    <xsl:value-of select="'4'"/>
                </xsl:when>
                <xsl:when test="($loc &gt;= 5) and ($loc &lt;= 11)">
                    <xsl:value-of select="'5'"/>
                </xsl:when>
                <xsl:when test="$loc &lt;= 12">
                    <xsl:value-of select="'6'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>