<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:cmo="http://www.example.org/cmo"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:variable name="suppliedColor" select="'rgba(170,0,0,1)'"/>
    <xsl:variable name="suppliedSubtype" select="'supplied'"/>

    <!-- Convert title to main title -->
    <!-- SG: Alternative to below approach to insert from anchored text -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:title[not(@type)]">
        <xsl:copy>
            <xsl:apply-templates select="*"/>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="//mei:fileDesc/mei:titleStmt/mei:title[1]/@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="'titleTranscription'"/>
            </xsl:attribute>
            <xsl:value-of select="//mei:fileDesc/mei:titleStmt/mei:title[1]/text()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:title/@type['subtitle']">
        <xsl:attribute name="type">
            <xsl:value-of select="'incipit'"/>
        </xsl:attribute>
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="reason">
                <xsl:value-of select="'derived-from-lyrics'"/>
            </xsl:attribute>
            <xsl:attribute name="cert">
                <xsl:value-of select="'1'"/>
            </xsl:attribute>
            <xsl:attribute name="resp">
                <xsl:value-of select="'##[ID]'"/>
            </xsl:attribute>
            <xsl:copy-of select="translate(//mei:fileDesc/mei:titleStmt/mei:title[2]/text(), 'âêîôû', 'āēīōū')"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:title[2]/text()"/>
    
    <!-- Delete composer and lyricits information from Sibelius file metadata and elsewhere -->
    <!-- Transfer information into mei:respStmt element -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt/mei:persName[1]">
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="//mei:fileDesc/mei:titleStmt/mei:composer/@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="role">
                <xsl:text>composer</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="cert">
                <xsl:text>[0-1]</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="resp">
                <xsl:text>##[ID]</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="//mei:fileDesc/mei:titleStmt/mei:composer/text()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt/mei:persName[2]">
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="//mei:fileDesc/mei:titleStmt/mei:lyricist/@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="role">
                <xsl:text>lyricist</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="cert">
                <xsl:text>[0-1]</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="resp">
                <xsl:text>##[ID]</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="//mei:fileDesc/mei:titleStmt/mei:lyricist/text()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:fileDesc//mei:composer"/>
    <xsl:template match="mei:fileDesc//mei:lyricist"/>
    <xsl:template match="mei:anchoredText[@label = 'composer']"/>
    <xsl:template match="mei:anchoredText[@label = 'Lyricist']"/>

    <!-- catching colored notes and transform them into <supplied> elements -->
    <xsl:template match="*[(./mei:note[@color=$suppliedColor]) and (count(./mei:note[@color=$suppliedColor]) &lt; count(./*))]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="@color=$suppliedColor">
                <xsl:variable name="grp" select="current-group()"/>
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:apply-templates select="$grp"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$grp"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:beam[count(./mei:note[@color=$suppliedColor]) = count(./*)]">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates select="./*"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>

    <!-- suppress color -->
    <xsl:template match="@color[$suppliedColor]"/>

    <!-- put whole measures into supplied elements if not a whole section is affected -->
    <xsl:template
        match="*[(./mei:measure[contains(@type, $suppliedSubtype)]) and (count(./mei:measure[contains(@type, $suppliedSubtype)]) &lt; count(./*))]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="@subtype = $suppliedSubtype">
                <xsl:variable name="grp" select="current-group()"/>
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:element name="supplied"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:apply-templates select="$grp"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$grp"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

    <!-- put whole section into supplied element if every measure of a section is affected -->
    <xsl:template
        match="*[(./mei:measure[contains(@type, $suppliedSubtype)]) and (count(./mei:measure[contains(@type, $suppliedSubtype)]) = count(./*))]">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>

    <!-- catching enclosed accidentals and put them into <supplied> elements -->
    <xsl:template match="mei:accid[@enclose = 'paren']">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@enclose['paren']"/>

    <xsl:template match="//mei:score/mei:section">
        <xsl:for-each-group select="*" group-ending-with="mei:measure[@type='endCycle']">
            <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="'##[ID]'"/>
                </xsl:attribute>
                <xsl:attribute name="n">
                    <xsl:value-of select="position()"/>
                </xsl:attribute>
                <xsl:copy-of select="current-group()"/>
            </xsl:element>
        </xsl:for-each-group>
    </xsl:template>

    <!-- copy every node in file -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
