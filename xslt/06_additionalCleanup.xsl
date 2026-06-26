<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs" version="2.0">

    <!-- copy every node in file -->
    <xsl:output indent="yes" method="xml" encoding="UTF-16"/>

    <!-- strip spaces -->
    <xsl:strip-space elements="mei:measure mei:note mei:section"/>

    <xsl:variable name="baseURI2symbols"
        select="'https://raw.githubusercontent.com/maxweberstiftung/CMO_MEI/master/'"/>
    <xsl:variable name="cmo_symbolTable" select="'cmo_symbolTable.xml'"/>
    <xsl:variable name="cmo_symbols"
        select="document(resolve-uri($cmo_symbolTable, $baseURI2symbols))"/>

    <!-- Variables for hampartsum groups -->
    <xsl:variable name="group_start" select="'U+E201'"/>
    <xsl:variable name="group_end" select="'U+E203'"/>
    
    <!-- convert bracket symbols into <bracketSpan> -->
    <xsl:template match="mei:dir[mei:symbol/@glyph.num = $group_start]">
        <xsl:variable name="followingEnd"
            select="following-sibling::mei:dir[mei:symbol/@glyph.num = $group_end][1]"/>

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
    <xsl:template match="mei:dir[mei:symbol/@glyph.num = $group_end]"/>

    <!-- add id to accidentals without id -->
    <!--
    <xsl:template match="*[not(@xml:id)]">
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    -->

    <!-- add @corresp for notes following a Nim geveşt -->
    <xsl:template
        match="mei:note[not(./mei:accid) and preceding::mei:note/mei:accid/@label = 'Nim geveşt' and ancestor::mei:staff/@n = '1']">
        <xsl:variable name="currentMeasure" select="ancestor::mei:measure/@n"/>
        <xsl:variable name="precedingNimNote"
            select="preceding::mei:note[mei:accid/@label = 'Nim geveşt' and ancestor::mei:measure/@n = $currentMeasure]"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="@pname = $precedingNimNote/@pname and @oct = $precedingNimNote/@oct">
                <xsl:element name="accid" namespace="http://www.music-encoding.org/ns/mei"
                > </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>

    <!-- add line breaks and page breaks -->
    <xsl:template
        match="mei:anchoredText[@label = 'Line break' or @label = 'Page break' or @label = 'Column break']">
        <xsl:choose>
            <xsl:when test="@label = 'Page break'">
                <xsl:element name="pb" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="n">
                        <xsl:value-of select="text()"/>
                    </xsl:attribute>
                    <xsl:attribute name="synch">
                        <xsl:value-of select="@startid"/>
                    </xsl:attribute>
                    <xsl:attribute name="source">
                        <xsl:value-of select="concat('#', //mei:source/@xml:id)"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="sb" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="label">
                        <xsl:value-of select="@label"/>
                    </xsl:attribute>
                    <xsl:attribute name="n">
                        <xsl:value-of select="text()"/>
                    </xsl:attribute>
                    <xsl:attribute name="synch">
                        <xsl:value-of select="@startid"/>
                    </xsl:attribute>
                    <xsl:attribute name="source">
                        <xsl:value-of select="concat('#', //mei:source/@xml:id)"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- add @glyph.auth to every element with @glyph.num -->
    <!-- Deprecated with MEI 5 -->
    <!--
    <xsl:template match="*[@glyph.num]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:attribute name="glyph.auth" select="'smufl'"/>
        </xsl:copy>
    </xsl:template>
    -->

    <!-- add @altsym to every symbol without @glyph.num -->
    <xsl:template match="mei:symbol[not(@glyph.num)]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@type = 'division'">
                    <xsl:variable name="currentSymbol" select="'division'"/>
                    <xsl:variable name="symbol"
                        select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                    <xsl:attribute name="altsym">
                        <xsl:value-of select="concat($cmo_symbolTable, '#', $symbol/@xml:id)"/>
                    </xsl:attribute>
                    <!-- needs to add an xml:base url to find file -->
                    <xsl:attribute name="xml:base">
                        <xsl:value-of select="$baseURI2symbols"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@type = 'endCycle'">
                    <xsl:choose>
                        <xsl:when test="@subtype = 'vertical'">
                            <xsl:variable name="currentSymbol" select="'End_cycle_vertical'"/>
                            <xsl:variable name="symbol"
                                select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                            <xsl:attribute name="altsym">
                                <xsl:value-of
                                    select="concat($cmo_symbolTable, '#', $symbol/@xml:id)"/>
                            </xsl:attribute>
                            <!-- needs to add an xml:base url to find file -->
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="$baseURI2symbols"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@subtype = 'diagonal'">
                            <xsl:variable name="currentSymbol" select="'End_cycle_diagonal'"/>
                            <xsl:variable name="symbol"
                                select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                            <xsl:attribute name="altsym">
                                <xsl:value-of
                                    select="concat($cmo_symbolTable, '#', $symbol/@xml:id)"/>
                            </xsl:attribute>
                            <!-- needs to add an xml:base url to find file -->
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="$baseURI2symbols"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <!-- and now all the Segnos symbols and Pincer, Prolongation, dot, and Loop repeat sign -->
                <xsl:when test="@label = $cmo_symbols//@label">
                    <xsl:variable name="currentSymbol" select="string(./@label)"/>
                    <xsl:variable name="symbol"
                        select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                    <xsl:attribute name="altsym">
                        <xsl:value-of select="concat($cmo_symbolTable, '#', $symbol/@xml:id)"/>
                    </xsl:attribute>
                    <!-- needs to add an xml:base url to find file -->
                    <xsl:attribute name="xml:base">
                        <xsl:value-of select="$baseURI2symbols"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- add @altsym to singleStroke and doubleStroke articulations -->
    <xsl:template match="mei:artic[@label = 'singleStroke' or @label = 'doubleStroke']">
        <xsl:copy>
            <xsl:if test="@label = $cmo_symbols//@label">
                <xsl:variable name="currentSymbol" select="string(./@label)"/>
                <xsl:variable name="symbol"
                    select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                <xsl:attribute name="altsym">
                    <xsl:value-of select="concat($cmo_symbolTable, '#', $symbol/@xml:id)"/>
                </xsl:attribute>
                <!-- needs to add an xml:base url to find file -->
                <xsl:attribute name="xml:base">
                    <xsl:value-of select="$baseURI2symbols"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- conversion of time signatures with Darb text style -->
    <!-- get next Darb Text element -->
    <!-- process changed scoreDef -->
    <!--
    <xsl:template match="mei:scoreDef">
        <xsl:variable name="darbText" select="following::mei:anchoredText[@label = 'Darb text'][1]"/>
        <xsl:copy>
            <xsl:apply-templates select="@* except (@meter.count)"/>
            <xsl:choose>
                <xsl:when test="$darbText != '' and @meter.count != string($darbText)">
                    <xsl:attribute name="meter.count">
                        <xsl:value-of select="string($darbText)"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@meter.count"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    -->

    <!-- delete Darb text from output -->
    <xsl:template match="mei:anchoredText[@label = 'Darb text']"/>
               
    <!-- Copy all sections numbered >=1 into the master section -->
    <xsl:template match="mei:section[@n='piece']">
        <xsl:copy>
            <xsl:apply-templates select="mei:expansion | mei:expansion[@type='lyrics'] | mei:expansion[@type='melody'] | node()[not(self::mei:expansion)]"/>
            <xsl:for-each select="//mei:section[not(@n='piece') and number(@n) >= 1]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:section[@n >= 1 and not(@n='piece')]"/>
        
    <!-- Inserting correspondance with original notation and pitch set -->
    <xsl:template match="mei:body">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="mdiv" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:element name="score" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="scoreDef" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
                            <xsl:attribute name="href">
                                <xsl:value-of select="'https://gitlab.gwdg.de/perspectivia.net/cmo-mei/-/raw/main/hampartsum_symbolDef.xml'"/>
                            </xsl:attribute>
                            <xsl:attribute name="parse">
                                <xsl:value-of select="'xml'"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="staffGrp" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:element name="label" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:text>Pitch Set</xsl:text>
                            </xsl:element>
                            <xsl:element name="staffDef" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="n">
                                    <xsl:value-of select="'0'"/>
                                </xsl:attribute>
                                <xsl:attribute name="lines">
                                    <xsl:value-of select="'5'"/>
                                </xsl:attribute>
                                <xsl:attribute name="clef.shape">
                                    <xsl:value-of select="'G'"/>
                                </xsl:attribute>
                                <xsl:attribute name="clef.line">
                                    <xsl:value-of select="'2'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="n">
                            <xsl:value-of select="'0'"/>
                        </xsl:attribute>
                        <xsl:attribute name="resp">
                            <xsl:value-of select="'##[ID]'"/>
                        </xsl:attribute>
                        <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
                            <xsl:attribute name="href">
                                <xsl:value-of select="'pitchSet.xml'"/>
                            </xsl:attribute>
                            <xsl:attribute name="xpointer">
                                <xsl:value-of select="''"/>
                            </xsl:attribute>
                            <xsl:attribute name="parse">
                                <xsl:value-of select="'xml'"/>
                            </xsl:attribute>
                            <xsl:element name="xi:fallback" namespace="http://www.w3.org/2001/XInclude"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates select="mei:mdiv"/>
        </xsl:copy>
    </xsl:template>

    <!-- Delete duration annotations -->
    <xsl:template match="mei:annot[@type='duration']"/>

    <!-- add schema to file -->
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            <xsl:text>href="https://gitlab.gwdg.de/perspectivia.net/cmo-mei/-/raw/main/CMOmeischema.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
        </xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">
            <xsl:text>href="https://gitlab.gwdg.de/perspectivia.net/cmo-mei/-/raw/main/CMOmeischema.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
        </xsl:processing-instruction>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- copy every node in file -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
