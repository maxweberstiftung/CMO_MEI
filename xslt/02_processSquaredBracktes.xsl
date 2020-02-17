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
    
   
    
    <!-- processing bracket lines -->
    <xsl:template match="mei:measure">
        <xsl:variable name="listOfTypes" select="tokenize(@type,' ')"/>
        
        <xsl:variable name="types">
            <xsl:choose>
                <!-- mark start and end measures of insertions -->
                <xsl:when test="$listOfTypes[2]">
                    <xsl:choose>
                        <xsl:when test="$listOfTypes[2]='suppStart' or $listOfTypes[2]='suppEnd'">
                            <xsl:value-of select="concat($listOfTypes[1],' ',$suppliedSubtype)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- if suppBeforeStart or suppAfterEnd the current measure is not supplied -->
                            <xsl:value-of select="$listOfTypes[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- if first preceeding measure with supp is start and first following measure with supp is end, 
                    then this measure is supplied as well -->
                    <xsl:variable name="next_preceding" select="preceding::node()[name()='measure'][contains(@type,'supp')][1]"/>
                    <xsl:variable name="next_following" select="following::node()[name()='measure'][contains(@type,'supp')][1]"/>
                    <xsl:choose>
                        <xsl:when test="contains($next_preceding/@type, 'Start') and contains($next_following/@type, 'End')">
                            <xsl:value-of select="concat($listOfTypes[1],' ',$suppliedSubtype)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$listOfTypes[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            
        <xsl:copy>
            <xsl:attribute name="type">
                <xsl:value-of select="$types"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* except (@type)"/>
            <xsl:apply-templates select="./node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- suppress vertical bracket lines -->
    <xsl:template match="mei:line[starts-with(@type,'bracket vertical')]"/>
    
    <!-- changing start and end positions of editorial additions into colored notes -->
    <!--<xsl:template match="*[name() = $eventElements][@label]">
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
    </xsl:template>-->
    
    <!-- suppress marking labels -->
    <!--<xsl:template match="@label[. = 'suppStart' or . = 'suppEnd' or . = 'suppStartEnd']"/>-->
    
    
    <!-- coloring every element between a start and an end point of an editorial addition -->
    <!--<xsl:template match="*[name() = $eventElements][not(@label) and preceding::node()/@label = 'suppStart' and following::node()/@label = 'suppEnd']">
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
    </xsl:template>-->
    
    <!-- coloring beam with first note starting an insertion or last note ending an insertion -->
    <!--<xsl:template match="*[(name() = $eventLikeElements) and count(child::*) = count(child::*[name() = $eventLikeElements or name() = $eventElements])]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="child::node()[1]/@label = 'suppStart' or child::node()[last()]/@label = 'suppEnd'">
                <xsl:attribute name="color">
                    <xsl:value-of select="$suppliedColor"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="./*"/>
        </xsl:copy>
    </xsl:template>-->
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>