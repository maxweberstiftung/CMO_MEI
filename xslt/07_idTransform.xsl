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
    
    <!-- Inserting comment for usul grouping stand-off markup -->
    <xsl:template match="mei:measure | mei:supplied/mei:measure">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="bracketSpan" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="func">
                    <xsl:value-of select="'usulGroup'"/>
                </xsl:attribute>
                <xsl:attribute name="staff">
                    <xsl:value-of select="'1'"/>
                </xsl:attribute>
                <xsl:attribute name="startid">
                    <xsl:value-of select="''"/>
                </xsl:attribute>
                <xsl:attribute name="endid">
                    <xsl:value-of select="''"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:comment> Delete or duplicate for indicating usûl groups </xsl:comment>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="rootDoc" select="/"/>
    
    <xsl:function name="mei:get-prefix" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:choose>
            <xsl:when test="$node/self::mei:measure">meas</xsl:when>
            <xsl:when test="$node/self::mei:staff">st</xsl:when>
            <xsl:when test="$node/self::mei:layer">lay</xsl:when>
            <xsl:when test="$node/self::mei:note">n</xsl:when>
            <xsl:when test="$node/self::mei:rest">r</xsl:when>
            <xsl:when test="$node/self::mei:beam">b</xsl:when>
            <xsl:when test="$node/self::mei:chord">ch</xsl:when>
            <xsl:when test="$node/self::mei:ending">end</xsl:when>
            <xsl:otherwise>id</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="mei:generate-new-id" as="xs:string">
        <xsl:param name="elem" as="element()"/>
        
        <xsl:variable name="measureN" select="$elem/ancestor-or-self::mei:measure[1]/@n"/>
        <xsl:variable name="staff" select="$elem/ancestor-or-self::mei:staff[1]"/>
        <xsl:variable name="staffN" select="$staff/@n"/>
        <xsl:variable name="name" select="local-name($elem)"/>
        
        <xsl:variable name="suffix">
            <xsl:choose>
                <xsl:when test="$staffN = '1'">a</xsl:when>
                <xsl:when test="$staffN = '2'">b</xsl:when>
                <xsl:when test="normalize-space($staffN)">
                    <xsl:value-of select="$staffN"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$elem/self::mei:ending">
                <xsl:variable name="mN" select="($elem//mei:measure)[1]/@n"/>
                <xsl:value-of select="concat('end-', $mN, '-', $elem/@n)"/>
            </xsl:when>
            
            <xsl:when test="$elem/self::mei:measure">
                <xsl:value-of select="concat('meas-', $measureN)"/>
            </xsl:when>
            
            <xsl:when test="$elem/self::mei:staff or $elem/self::mei:layer">
                <xsl:value-of select="concat(mei:get-prefix($elem), '-', $measureN, $suffix)"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="pos" select="count($elem/preceding::*[local-name() = $name][ancestor::mei:staff[1] is $staff]) - 
                    count($elem/ancestor::mei:measure[1]/preceding::*[local-name() = $name][ancestor::mei:staff[1] is $staff]) + 1"/>
                <xsl:value-of select="concat(mei:get-prefix($elem), '-', $measureN, '-', $pos, $suffix)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="mei:measure/@xml:id | mei:staff/@xml:id | mei:layer/@xml:id | 
        mei:note/@xml:id | mei:rest/@xml:id | mei:beam/@xml:id | 
        mei:chord/@xml:id | mei:accid/@xml:id | mei:ending/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="parent::mei:accid/parent::mei:note">
                    <xsl:value-of select="concat(mei:generate-new-id(parent::mei:accid/parent::mei:note), '-acc')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="mei:generate-new-id(..)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@startid | @endid | @plist">
        <xsl:attribute name="{name()}">
            <xsl:variable name="tokens" select="tokenize(., '\s+')"/>
            <xsl:variable name="newTokens" as="xs:string*">
                <xsl:for-each select="$tokens">
                    <xsl:variable name="currentID" select="substring-after(., '#')"/>
                    <xsl:variable name="target" select="$rootDoc//*[@xml:id = $currentID]"/>
                    
                    <xsl:choose>
                        <xsl:when test="$target/self::mei:accid[parent::mei:note]">
                            <xsl:value-of select="concat('#', mei:generate-new-id($target/parent::mei:note), '-acc')"/>
                        </xsl:when>
                        <xsl:when test="$target/(self::mei:measure | self::mei:staff | self::mei:layer | 
                            self::mei:note | self::mei:rest | self::mei:beam | self::mei:chord | self::mei:ending)">
                            <xsl:value-of select="concat('#', mei:generate-new-id($target))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="string-join($newTokens, ' ')"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Convert specifically verse and syl ids -->
    <xsl:template match="mei:verse/@xml:id">
        <xsl:variable name="measureN" select="ancestor::mei:measure/@n"/>
        <xsl:variable name="label" select="../@label"/>
        <xsl:variable name="count">
            <xsl:number level="any" from="mei:measure" count="mei:verse"/>
        </xsl:variable>
        
        <xsl:attribute name="xml:id">
            <xsl:value-of select="concat('v-', $measureN, '-', $label, '-', $count)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="mei:syl/@xml:id">
        <xsl:variable name="measureN" select="ancestor::mei:measure/@n"/>
        <xsl:variable name="label" select="../@label"/>
        <xsl:variable name="count">
            <xsl:number level="any" from="mei:measure" count="mei:syl"/>
        </xsl:variable>
        
        <xsl:attribute name="xml:id">
            <xsl:value-of select="concat('s-', $measureN, '-', $label, '-', $count)"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- No IDs -->
    <xsl:template match="*[not(@xml:id)]">
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generateUniqueId">
                    <xsl:with-param name="base" select="generate-id(.)"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="generateUniqueId">
        <xsl:param name="base"/>
        <xsl:param name="suffix" select="''"/>
        
        <xsl:variable name="proposedId" select="concat($base, $suffix)"/>
        
        <xsl:choose>
            <xsl:when test="//*[@xml:id = $proposedId]">
                <xsl:call-template name="generateUniqueId">
                    <xsl:with-param name="base" select="$base"/>
                    <xsl:with-param name="suffix" select="concat($suffix, '_new')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$proposedId"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- copy every node in file -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>