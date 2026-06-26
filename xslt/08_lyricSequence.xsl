<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs" version="2.0">

    <!-- copy every node in file -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:output indent="yes" method="xml" encoding="UTF-16"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="mei:p//text()">
        <xsl:variable name="normText" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="string-length($normText) = 0 and contains(., '&#10;')"/>
            <xsl:otherwise>
                <xsl:if test="matches(., '^\s')"><xsl:text> </xsl:text></xsl:if>
                <xsl:value-of select="$normText"/>
                <xsl:if test="matches(., '\s$')"><xsl:text> </xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:expansion[@type='lyrics']">
        
        <xsl:for-each-group select="//mei:syl[starts-with(tokenize(@xml:id, '-')[3], 'H')]" 
            group-by="replace(tokenize(@xml:id, '-')[3], '[^\d]', '')">
            <xsl:sort select="current-grouping-key()" data-type="number"/>
            
            <xsl:variable name="n" select="current-grouping-key()"/>
            
            <xsl:variable name="currentH" select="current-group()"/>
            
            <xsl:variable name="currentTH" select="//mei:syl[tokenize(@xml:id, '-')[3] = concat('tH', $n)]"/>
            
            <xsl:variable name="relevantT" as="element(mei:syl)*">
                <xsl:choose>
                    <xsl:when test="$n = '3'">
                        <xsl:sequence select="//mei:syl[tokenize(@xml:id, '-')[3] = 't3' or (tokenize(@xml:id, '-')[3] = 't1' and number(tokenize(@xml:id, '-')[2]) >= 30)]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="//mei:syl[tokenize(@xml:id, '-')[3] = 't1' and number(tokenize(@xml:id, '-')[2]) &lt; 30]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="combinedSyls" select="$currentH | $currentTH | $relevantT"/>
            
            <xsl:variable name="sortedSyls" as="element(mei:syl)*">
                <xsl:perform-sort select="$combinedSyls">
                    <xsl:sort select="number(tokenize(@xml:id, '-')[2])" data-type="number"/>
                    <xsl:sort select="if (starts-with(tokenize(@xml:id, '-')[3], 'H')) then 1 
                        else if (matches(tokenize(@xml:id, '-')[3], '^t\d+$')) then 2 
                        else 3" data-type="number"/>
                    <xsl:sort select="number(tokenize(@xml:id, '-')[last()])" data-type="number"/>
                </xsl:perform-sort>
            </xsl:variable>
            
            <xsl:comment>
                <xsl:text> Lyrics for H</xsl:text>
                <xsl:value-of select="$n"/>
                <xsl:text>: </xsl:text>
                <xsl:for-each select="$sortedSyls">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text> </xsl:text>
            </xsl:comment>
            
            <xsl:element name="expansion" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id" select="concat('lyr-', $n)"/>
                <xsl:attribute name="type" select="'lyrics'"/>
                <xsl:attribute name="n" select="$n"/>
                <xsl:attribute name="plist">
                    <xsl:for-each select="$sortedSyls">
                        <xsl:value-of select="concat('#', @xml:id)"/>
                        <xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
                    </xsl:for-each>
                </xsl:attribute>
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
