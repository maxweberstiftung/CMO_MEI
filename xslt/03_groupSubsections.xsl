<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Variables for sectioning -->
    <xsl:variable name="subsectionName" select="'Subsection'"/>
    
    <!-- put Section markings into sections and mark measures according to squared bracket lines and division signs -->
    <xsl:template match="mei:section[parent::mei:section]">
        <xsl:choose>
            <xsl:when test="./mei:measure[mei:anchoredText/@label=$subsectionName]">
                
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <!-- first, write every element without a preceding section mark -->
                    <xsl:for-each select="node()[not(mei:anchoredText/@label=$subsectionName) and not(preceding-sibling::mei:measure[mei:anchoredText/@label=$subsectionName]) and not(name() = 'scoreDef' and following-sibling::*[1]/mei:anchoredText/@label=$subsectionName)]">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <!-- then, write all measures from a section mark to the next mark in a section -->
                    <xsl:for-each select="mei:measure[mei:anchoredText/@label=$subsectionName]">
                        <!-- keep self as variable for comparing -->
                        <xsl:variable name="start_measure" select="."/>
                        <!-- get next start -->
                        <xsl:variable name="nextStartN" select="string(./following-sibling::mei:measure[mei:anchoredText/@label=$subsectionName][1]/@n)"/>
                        
                        <!-- generate section and put self in it -->
                        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="id" namespace="http://www.w3.org/XML/1998/namespace">
                                <xsl:value-of select="generate-id(mei:anchoredText[@label=$subsectionName])"/>
                            </xsl:attribute>
                            <!-- Set Section text as label -->
                            <xsl:attribute name="label">
                                <xsl:value-of select="mei:anchoredText[@label=$subsectionName]"/>
                            </xsl:attribute>
                            
                            <!-- catch a preceding <scoreDef> -->
                            <xsl:if test="./preceding-sibling::*[1]/name() = 'scoreDef'">
                                <xsl:apply-templates select="./preceding-sibling::*[1][name() = 'scoreDef']"/>
                            </xsl:if>
                            
                            <!-- write current measure -->
                            <xsl:apply-templates select="."/>
                            
                            <!-- write following elements until next start -->
                            <xsl:for-each select="./following-sibling::node()[not(mei:anchoredText/@label=$subsectionName)][preceding-sibling::mei:measure[mei:anchoredText/@label=$subsectionName][1] = $start_measure]">
                                <xsl:apply-templates select=". except (.[name() = 'scoreDef' and following-sibling::mei:measure[1]/@n = $nextStartN])"/>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|*"/> 
                </xsl:copy>           
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:anchoredText[@label=$subsectionName]"/>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>