<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- standard color used to mark insertions -->
    <xsl:variable name="suppliedColor" select="'rgba(170,0,0,1)'"/>
    <!-- standard type to mark inserted measures -->
    <xsl:variable name="suppliedSubtype" select="'supplied'"/>
    <!-- members of model.EventLike -->
    <xsl:variable name="eventLikeElements" select="('chord', 'beam', 'tuplet', 'beatRpt', 'bTrem', 'fTrem')"/>
    <xsl:variable name="eventElements" select="('note', 'rest', 'space')"/>
    
    
    <!-- processing bracket symbols -->
    
    <!-- changing start and end positions of editorial additions into colored notes -->
    <xsl:template match="*[name() = $eventElements][@label]">
        <xsl:choose>
            <xsl:when test="@label = 'suppStart' or @label = 'suppEnd' or @label = 'suppStartEnd'">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="color">
                        <xsl:value-of select="$suppliedColor"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="./node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- suppress marking labels -->
    <xsl:template match="@label[. = 'suppStart' or . = 'suppEnd' or . = 'suppStartEnd']"/>
    
    <!-- suppress vertical bracket lines -->
    <xsl:template match="mei:line[@type='bracket' and @subtype='vertical']"/>
    
    <!-- coloring every element between a start and an end point of an editorial addition -->
    <xsl:template match="*[name() = $eventElements][not(@label) and preceding::node()/@label = 'suppStart' and following::node()/@label = 'suppEnd']">
        <xsl:choose>
            <xsl:when test="preceding::node()[@label][1]/@label = 'suppStart' and following::node()[@label][1]/@label = 'suppEnd'">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="color">
                        <xsl:value-of select="$suppliedColor"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="./*"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="./*"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- coloring beam with first note starting an insertion or last note ending an insertion -->
    <xsl:template match="*[(name() = $eventLikeElements) and count(child::*) = count(child::*[name() = $eventLikeElements or name() = $eventElements])]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="child::node()[1]/@label = 'suppStart' or child::node()[last()]/@label = 'suppEnd'">
                <xsl:attribute name="color">
                    <xsl:value-of select="$suppliedColor"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="./*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- processing bracket lines -->
    <xsl:template match="mei:measure">
        <xsl:choose>
            <!-- mark start and end measures of insertions -->
            <xsl:when test="@subtype = 'suppStart' or @subtype = 'suppEnd'">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                        <xsl:attribute name="subtype">
                           <xsl:value-of select="$suppliedSubtype"/>
                        </xsl:attribute>
                    <xsl:apply-templates select="./node()"/>
                </xsl:copy>
            </xsl:when>
            <!-- get measures without subtype -->
            <xsl:when test=".[not(@subtype) and preceding::node()[name()='measure']/@subtype and following::node()[name()='measure']/@subtype]">
                <xsl:variable name="next_preceding" select="preceding::node()[name()='measure'][@subtype][1]"/>
                <xsl:variable name="next_following" select="following::node()[name()='measure'][@subtype][1]"/>
                <xsl:choose>
                    <!-- mark every measure between suppStart/suppBeforeStart and suppEnd/suppAfterEnd -->
                    <xsl:when test="($next_preceding/@subtype = 'suppBeforeStart' or $next_preceding/@subtype = 'suppStart') and ($next_following/@subtype = 'suppEnd' or $next_following/@subtype = 'suppAfterEnd')">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="subtype">
                                <xsl:value-of select="$suppliedSubtype"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="./node()"/>
                        </xsl:copy>
                    </xsl:when>
                    <!-- don't mark other measures -->
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates select="./node()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- don't mark any other measure -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="./node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- suppress marking subtypes -->
    <xsl:template match="@subtype[parent::mei:measure]"/>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>