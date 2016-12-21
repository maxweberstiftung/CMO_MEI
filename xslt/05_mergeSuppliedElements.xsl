<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:preserve-space elements="*"/>
    
    <!-- merge adjacent <supplied> elements -->
    <xsl:template match="*[./mei:supplied]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="name() = 'supplied'">
                <xsl:variable name="grp" select="current-group()"/>
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:apply-templates select="$grp/*"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$grp"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>