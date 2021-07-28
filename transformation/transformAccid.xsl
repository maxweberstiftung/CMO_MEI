<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns="http://www.music-encoding.org/ns/mei"
    xmlns:xsldoc="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:local="http://www.w3.org/2005/XQuery-local-functions"
    exclude-result-prefixes="xs math local mei xsldoc"
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
            Iterates through each note in staff 1 and copies the note.
            If the note has a cautionary accidental on the same pitch and no accid itself, it adds a gestural natrual.
            Variables:
                * measureN: Number of current measure
                * naturalNote: Note element that contains a cautionary natural.
        </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:note[ancestor::mei:staff/@n='1']">
        <xsl:variable name="measureN" select="ancestor::mei:measure/@n"/>
        <xsl:variable name="naturalNote"
            select="//mei:measure[@n=$measureN]/mei:staff[@n='1']/mei:layer//mei:note[mei:accid[@accid='n' and @func='caution']]"/>

        <xsl:copy>
            <xsl:apply-templates select="@*|node()[not(self::mei:accid)]"/>
            <xsl:if test=".[preceding::mei:note[@xml:id=$naturalNote/@xml:id]] and
                ./@pname = $naturalNote/@pname and ./@oct = $naturalNote/@oct and not(mei:accid)">
                <accid accid.ges="n"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsldoc:doc>
        <xsldoc:desc>
            Corrects accidental values for written and gestural accidentals.
        </xsldoc:desc>
    </xsldoc:doc>
    <xsl:template match="mei:accid">
        <xsl:copy>
            <xsl:apply-templates select="@xml:id"/>
            <!-- analyze the role of @func -->
            <xsl:if test="@accid">
                <!-- change to correct AEU value -->
                <xsl:attribute name="accid">
                    <xsl:call-template name="sibAccid2AEUaccid">
                        <xsl:with-param name="accid" select="@accid"/>
                    </xsl:call-template>
                </xsl:attribute>
                <!--
                    In the case of a <accid accid="n" func="caution" />, this should not be a cautionary accidental
                    We need to look for notes with the same pitch in the measure to add gestural accidentals!!!
                    This is done via the template matching mei:note[ancestor::mei:staff/@n='1']...
                -->
                <xsl:if test="@accid='n' and @func='caution'">
                    <!-- Start a template -->
                    <xsl:attribute name="accid" select="'n'"/>
                </xsl:if>
            </xsl:if>
            <xsl:if test="@accid.ges">
                <!-- change to correct AEU value -->
                <xsl:attribute name="accid.ges">
                    <xsl:call-template name="sibAccid2AEUaccid">
                        <xsl:with-param name="accid" select="@accid.ges"/>
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:if>
            <!-- keep accids in parentheses as parentheses, supplied or editorial? -->
        </xsl:copy>
    </xsl:template>

    <xsldoc:doc>
        <xsldoc:desc>
            Modifies the staffDef of the first staff (usually the music staff, while the second staff contains the usul pattern).
            Adds a keySignature according to staffDef/label, instrument name in Sibelius.
        </xsldoc:desc>
    </xsldoc:doc>

    <!-- <label>N</label> means no key signature -->
    <xsl:template match="mei:staffDef[@n='1'][@label and @label!='N']">
        <xsl:variable name="staffDef" select="."/>

        <xsl:copy>
            <xsl:apply-templates select="@n|@xml:id|@lines|@clef.shape|@clef.line"/>

            <!-- process key signatures -->
            <keySig>
                <!-- tokenize @label to process key signatures -->
                <xsl:for-each select="tokenize($staffDef/mei:label,'\s+')">
                    <xsl:if test="string-length(.) != 2">
                        <xsl:message terminate="yes">
                            <xsl:value-of select="concat('Unexpected syntax for key signature information in instrument label: ', $staffDef/mei:label)"/>
                        </xsl:message>
                    </xsl:if>
                    <xsl:variable name="accid" select="substring(.,2,1)"/>
                    <xsl:variable name="loc" select="substring(.,1,1)"/>
                    <xsl:variable name="accidVal" select="local:keyAccid2AEUaccid($accid)"/>
                    <xsl:variable name="octAndPname">
                        <xsl:apply-templates mode="getOctAndPname" select="$staffDef"/>
                    </xsl:variable>

                    <!-- because a new element is generated, we still need to add a xml:id, but later -->
                    <!-- Note: generate-id() doesn't work here because our current scope isn't a node but a string -->
                    <keyAccid loc="{$loc}" accid="{$accidVal}" oct="{$octAndPname[1]}" pname="{$octAndPname[2]}"/>
                </xsl:for-each>
            </keySig>
        </xsl:copy>
    </xsl:template>

    <xsldoc:doc>
        <xsldoc:desc>Maps the wrong accidental attributes from the Sibelius output to the correct AEU accidental values.</xsldoc:desc>
        <xsldoc:param name="accid">Irregular accidental value retrieved from Sibelius</xsldoc:param>
    </xsldoc:doc>
    <xsl:template name="sibAccid2AEUaccid">
        <xsl:param name="accid"/>
        <xsl:choose>
            <xsl:when test="$accid = 's'">
                <!-- Bakiye sharp -->
                <xsl:value-of select="'bs'"/>
            </xsl:when>
            <xsl:when test="$accid = 'f'">
                <!-- Küçük mücenneb (flat) -->
                <xsl:value-of select="'kmf'"/>
            </xsl:when>
            <xsl:when test="$accid = 'ff'">
                <!-- Büyük mücenneb (flat) -->
                <xsl:value-of select="'bmf'"/>
            </xsl:when>
            <xsl:when test="$accid = 'x'">
                <!-- Büyük mücenneb (sharp) -->
                <xsl:value-of select="'bms'"/>
            </xsl:when>
            <xsl:when test="$accid = 'fd'">
                <!-- Bakiye (flat) -->
                <xsl:value-of select="'bf'"/>
            </xsl:when>
            <xsl:when test="$accid = 'fu'">
                <!-- Koma (flat) -->
                <xsl:value-of select="'kf'"/>
            </xsl:when>
            <xsl:when test="$accid = 'su'">
                <!-- Küçük mücenneb (sharp) -->
                <xsl:value-of select="'kms'"/>
            </xsl:when>
            <xsl:when test="$accid = 'sd'">
                <!-- Koma (sharp) -->
                <xsl:value-of select="'ks'"/>
            </xsl:when>
            <xsl:when test="$accid = 'n'">
                <!-- n is always n, if it's accig.ges or a real accid, must be determined by @func -->
                <xsl:value-of select="'n'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:value-of select="concat('Unexpected accidental shape: ', $accid)"/>
                </xsl:message>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsldoc:doc>
        <xsldoc:desc>Maps the key accidental value given by the editors to the values for AEU accidentals.</xsldoc:desc>
        <xsldoc:param name="accid">Accid value as string</xsldoc:param>
    </xsldoc:doc>
    <xsl:function name="local:keyAccid2AEUaccid">
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
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:value-of select="concat('Unexpected accidental name in staff label: ', $accid)"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsldoc:doc>
        <xsldoc:desc>Returns two values: the octave number and the base pitch for the key accidental by the given loc.</xsldoc:desc>
        <xsldoc:param name="staffDef">staffDef element with @clef.line and @clef.shape attributes</xsldoc:param>
        <xsldoc:param name="loc">Staff location as number</xsldoc:param>
    </xsldoc:doc>
    <xsl:function name="local:getOctAndPname">
        <xsl:param name="staffDef" as="element(mei:staffDef)"/>
        <xsl:param name="loc" as="xs:double"/>
        <xsl:if test="($staffDef/@clef.line != 2) or ($staffDef/@clef.shape != 'G')">
            <xsl:message terminate="yes">
                <xsl:value-of select="'loc2pname only supports treble clef'"/>
            </xsl:message>
        </xsl:if>

        <xsl:copy-of select="floor(($loc + 3) div 7) + 4"/>
        <!-- Force the loc value into the range 0–6 (octave is not relevant). All e's will be loc=0 -->
        <xsl:variable name="normalizedLoc" select="($loc mod 7 + 7) mod 7"/>
        <xsl:value-of select="('e', 'f', 'g', 'a', 'b', 'c', 'd')[$normalizedLoc + 1]"/>
    </xsl:function>
</xsl:stylesheet>