<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- strip spaces -->
    <xsl:strip-space elements="measure"/>
    
    <xsl:variable name="baseURI2symbols" select="'https://raw.githubusercontent.com/annplaksin/CMO_MEI/master/'"/>
    <xsl:variable name="cmo_symbolTable" select="'cmo_symbolTable.xml'"/>
    <xsl:variable name="cmo_symbols" select="document(resolve-uri($cmo_symbolTable,$baseURI2symbols))"/>
    
    <!-- Variables for hampartsum groups -->
    <xsl:variable name="group_start" select="'Hampartsum group start'"/>
    <xsl:variable name="group_end" select="'Hampartsum group end'"/>
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:copy-of select="*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>cleanUp</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO additional cleanup before branching of versions</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- add ID to key accidentals -->
    <xsl:template match="mei:keyAccid">
        <xsl:copy>
            <xsl:attribute name="id" namespace="http://www.w3.org/XML/1998/namespace">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add line breaks and page breaks -->
    <xsl:template match="mei:layer[parent::mei:staff/@n='1'][ancestor::mei:measure/mei:anchoredText]">
        <xsl:variable name="anchoredBreak" select="ancestor::mei:measure/mei:anchoredText[@label = 'line break' or @label = 'page break' or @label = 'column break']"/>
        <xsl:variable name="groupSigns" select="ancestor::mei:measure/mei:dir[mei:symbol/@label=$group_start or mei:symbol/@label=$group_end]"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="./*">
                <xsl:variable name="selfOrChildIDs" select="for $x in descendant-or-self::*/@xml:id return concat('#',$x)"/>
                <xsl:choose>
                    <!-- put break before element if it is also a start of a group -->
                    <xsl:when test="$selfOrChildIDs = $anchoredBreak/@startid and $selfOrChildIDs = $groupSigns[mei:symbol/@label=$group_start]/@startid">
                        <xsl:choose>
                            <!-- create a page break event -->
                            <xsl:when test="$anchoredBreak/@label = 'page break'">
                                <xsl:element name="pb" namespace="http://www.music-encoding.org/ns/mei">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="$anchoredBreak/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="n">
                                        <xsl:value-of select="$anchoredBreak/text()"/>
                                    </xsl:attribute>
                                </xsl:element>
                                <xsl:apply-templates select="."/>
                            </xsl:when>
                            <!-- create a system break in case of line or column break -->
                            <xsl:otherwise>
                                <xsl:element name="sb" namespace="http://www.music-encoding.org/ns/mei">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="$anchoredBreak/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="label">
                                        <xsl:value-of select="$anchoredBreak/@label"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="n">
                                        <xsl:value-of select="$anchoredBreak/text()"/>
                                    </xsl:attribute>
                                </xsl:element>
                                <xsl:apply-templates select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- put break after element if it is also an end of a group -->
                    <xsl:when test="$selfOrChildIDs = $anchoredBreak/@startid and $selfOrChildIDs = $groupSigns[mei:symbol/@label=$group_end]/@startid">
                        <xsl:choose>
                            <!-- put break before element if it is also a start of a group -->
                            <xsl:when test="$anchoredBreak/@label = 'page break'">
                                <xsl:apply-templates select="."/>
                                <xsl:element name="pb" namespace="http://www.music-encoding.org/ns/mei">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="$anchoredBreak/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="n">
                                        <xsl:value-of select="$anchoredBreak/text()"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:when>
                            <!-- create a system break in case of line or column break -->
                            <xsl:otherwise>
                                <xsl:apply-templates select="."/>
                                <xsl:element name="sb" namespace="http://www.music-encoding.org/ns/mei">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="$anchoredBreak/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="label">
                                        <xsl:value-of select="$anchoredBreak/@label"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="n">
                                        <xsl:value-of select="$anchoredBreak/text()"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- suppress old break markings -->
    <xsl:template match="mei:anchoredText[@label = 'line break' or @label = 'page break' or @label = 'column break']"/>
    
    <!-- add @altsym to every symbol without @glyphnum -->
    <xsl:template match="mei:symbol[not(@glyphnum)]">
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
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>