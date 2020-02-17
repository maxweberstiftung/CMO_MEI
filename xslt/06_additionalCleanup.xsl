<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- strip spaces -->
    <xsl:strip-space elements="mei:measure mei:note"/>
    
    <xsl:variable name="baseURI2symbols" select="'https://raw.githubusercontent.com/maxweberstiftung/CMO_MEI/master/'"/>
    <xsl:variable name="cmo_symbolTable" select="'cmo_symbolTable.xml'"/>
    <xsl:variable name="cmo_symbols" select="document(resolve-uri($cmo_symbolTable,$baseURI2symbols))"/>
    
    <!-- Variables for hampartsum groups -->
    <xsl:variable name="group_start" select="'U+E201'"/>
    <xsl:variable name="group_end" select="'U+E203'"/>
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:apply-templates select="@*|*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>CMO_sibmei-cleanUp</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO sibmei output cleanup before branching of versions</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- convert bracket symbols into <bracketSpan> -->
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
    <xsl:template match="mei:dir[mei:symbol/@glyph.num=$group_end]"/>
    
    <!-- add id to accidentals without id -->
    <xsl:template match="*[not(@xml:id)]">
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add @corresp for notes following a Nim geveşt -->
    <xsl:template match="mei:note[not(./mei:accid) and preceding::mei:note/mei:accid/@label='Nim geveşt' and ancestor::mei:staff/@n='1']">
        <xsl:variable name="currentMeasure" select="ancestor::mei:measure/@n"/>
        <xsl:variable name="precedingNimNote" select="preceding::mei:note[mei:accid/@label='Nim geveşt' and ancestor::mei:measure/@n = $currentMeasure]"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="@pname = $precedingNimNote/@pname and @oct = $precedingNimNote/@oct">
                <xsl:element name="accid" namespace="http://www.music-encoding.org/ns/mei">
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add line breaks and page breaks -->
    <xsl:template match="mei:anchoredText[@label = 'Line break' or @label = 'Page break' or @label = 'Column break']">
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
                        <xsl:value-of select="concat('#',//mei:source/@xml:id)"/>
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
                    <xsl:value-of select="concat('#',//mei:source/@xml:id)"/>
                </xsl:attribute>
            </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- add @glyph.auth to every element with @glyph.num -->
    <xsl:template match="*[@glyph.num]">
        <xsl:copy>
            <xsl:attribute name="glyph.auth" select="'smufl'"/>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- add @altsym to every symbol without @glyphnum -->
    <xsl:template match="mei:symbol[not(@glyph.num)]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@type='Division'">
                    <xsl:variable name="currentSymbol" select="'Division'"/>
                    <xsl:variable name="symbol" select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                    <xsl:attribute name="altsym">
                        <xsl:value-of select="concat($cmo_symbolTable,'#',$symbol/@xml:id)"/>
                    </xsl:attribute>
                    <!-- needs to add an xml:base url to find file -->
                    <xsl:attribute name="xml:base">
                        <xsl:value-of select="$baseURI2symbols"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='End_cycle'">
                    <xsl:choose>
                        <xsl:when test="@subtype='vertical'">
                            <xsl:variable name="currentSymbol" select="'End_cycle_vertical'"/>
                            <xsl:variable name="symbol" select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                            <xsl:attribute name="altsym">
                                <xsl:value-of select="concat($cmo_symbolTable,'#',$symbol/@xml:id)"/>
                            </xsl:attribute>
                            <!-- needs to add an xml:base url to find file -->
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="$baseURI2symbols"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@subtype='diagonal'">
                            <xsl:variable name="currentSymbol" select="'End_cycle_diagonal'"/>
                            <xsl:variable name="symbol" select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                            <xsl:attribute name="altsym">
                                <xsl:value-of select="concat($cmo_symbolTable,'#',$symbol/@xml:id)"/>
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
                    <xsl:variable name="symbol" select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                    <xsl:attribute name="altsym">
                        <xsl:value-of select="concat($cmo_symbolTable,'#',$symbol/@xml:id)"/>
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
    <xsl:template match="mei:artic[@label='singleStroke' or @label='doubleStroke']">
        <xsl:copy>
            <xsl:if test="@label = $cmo_symbols//@label">
                <xsl:variable name="currentSymbol" select="string(./@label)"/>
                <xsl:variable name="symbol" select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                <xsl:attribute name="altsym">
                    <xsl:value-of select="concat($cmo_symbolTable,'#',$symbol/@xml:id)"/>
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
    <xsl:template match="mei:scoreDef">
        <!-- get next Darb Text element -->
        <xsl:variable name="darbText" select="following::mei:anchoredText[@label='Darb text'][1]"/>
        <!-- process changed scoreDef -->
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
    
    <!-- delete Darb text from output -->
    <xsl:template match="mei:anchoredText[@label='Darb text']"/>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>