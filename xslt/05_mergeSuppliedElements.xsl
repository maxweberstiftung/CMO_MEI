<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:cmo="http://www.example.org/cmo"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output indent="yes" method="xml" encoding="UTF-16"/>
    <xsl:strip-space elements="*"/>
    
    <!-- Transform refrain into verse -->
    <xsl:template match="mei:refrain">
        <xsl:element name="verse" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
<!--    <xsl:template match="mei:measure[@type='division supplied' or @type='endCycle supplied']">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="reason">omitted-following-instruction</xsl:attribute>
            <xsl:attribute name="evidence">internal</xsl:attribute>
            <xsl:attribute name="cert">[0-1]</xsl:attribute>
            <xsl:attribute name="resp">##[ID]</xsl:attribute>
            <xsl:copy>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="@type = 'division supplied'">division</xsl:when>
                        <xsl:otherwise>endCycle</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates select="@*[local-name()!='type']"/>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    -->
    
    <!-- add <supplied> elements -->
    <xsl:template match="mei:measure[@type = ('division supplied', 'endCycle supplied')]">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="reason">omitted-in-original</xsl:attribute>
            <xsl:attribute name="type"></xsl:attribute>
            <xsl:attribute name="evidence">internal</xsl:attribute>
            <xsl:attribute name="cert">[0-1]</xsl:attribute>
            <xsl:attribute name="resp">##[ID]</xsl:attribute>
            <xsl:apply-templates select="." mode="process"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="mei:measure" mode="process">
        <xsl:element name="measure" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="name() = 'type' and . = 'division supplied'">
                        <xsl:attribute name="type">division</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="name() = 'type' and . = 'endCycle supplied'">
                        <xsl:attribute name="type">endCycle</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <!-- ORIGINAL
    <xsl:template match="mei:measure[@type = ('division supplied', 'endCycle supplied')]">
        <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="reason">omitted-in-original</xsl:attribute>
            <xsl:attribute name="type"></xsl:attribute>
            <xsl:attribute name="evidence">internal</xsl:attribute>
            <xsl:attribute name="cert">[0-1]</xsl:attribute>
            <xsl:attribute name="resp">##[ID]</xsl:attribute>
            <xsl:apply-templates select="." mode="process"/>
            <xsl:apply-templates select="
                mei:measure[
                @type = ('division supplied', 'endCycle supplied')]" mode="process"/>
        </xsl:element>
        <xsl:apply-templates select="following-sibling::mei:measure[@type = ('division supplied', 'endCycle supplied')]"/>
    </xsl:template>
    <xsl:template match="mei:measure" mode="process">
        <xsl:element name="measure" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="name() = 'type' and . = 'division supplied'">
                        <xsl:attribute name="type">division</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="name() = 'type' and . = 'endCycle supplied'">
                        <xsl:attribute name="type">endCycle</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:measure[@type = ('division supplied', 'endCycle supplied')][preceding-sibling::mei:measure[1][@type = ('division supplied', 'endCycle supplied')]]"/>
    -->


    <!-- merge adjacent <supplied> elements -->
    <!--<xsl:template match="*[./mei:supplied]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="name() = 'supplied'">
                <xsl:variable name="grp" select="current-group()"/>
                <xsl:choose>
                        Merge child nodes only when they are part of supplied (current-grouping-key() = true
                        and when there is more than one element in $grp (because one only supplied don't need 
                        to be merged). Therefor put the children of the group elements into a new supplied element.
                    <xsl:when test="count($grp) &gt; 1 and current-grouping-key()">
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
    -->

    <!-- Add makam, usul and genre information. -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:title[2] | //mei:fileDesc/mei:titleStmt/mei:title[count(../mei:title)=1]">
        <!--<xsl:copy>-->
            <xsl:copy-of select="."/>
            <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="type">
                    <xsl:value-of select="'makamStandardized'"/>
                </xsl:attribute>
                <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="reason">
                        <xsl:value-of select="'standardized-from-source'"/>
                    </xsl:attribute>
                    <xsl:attribute name="cert">
                        <xsl:value-of select="'1'"/>
                    </xsl:attribute>
                    <xsl:attribute name="resp">
                        <xsl:value-of select="'##[ID]'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'[Enter standard term for makam here or delete element]'"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="type">
                    <xsl:value-of select="'usulStandardized'"/>
                </xsl:attribute>
                <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="reason">
                        <xsl:value-of select="'standardized-from-source'"/>
                    </xsl:attribute>
                    <xsl:attribute name="cert">
                        <xsl:value-of select="'1'"/>
                    </xsl:attribute>
                    <xsl:attribute name="resp">
                        <xsl:value-of select="'##[ID]'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'[Enter standard term for usul here or delete element]'"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="type">
                    <xsl:value-of select="'genreStandardized'"/>
                </xsl:attribute>
                <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="reason">
                        <xsl:value-of select="'standardized-from-source'"/>
                    </xsl:attribute>
                    <xsl:attribute name="cert">
                        <xsl:value-of select="'1'"/>
                    </xsl:attribute>
                    <xsl:attribute name="resp">
                        <xsl:value-of select="'##[ID]'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'[Enter standard term for musical genre here or delete element]'"/>
                </xsl:element>
            </xsl:element>
        <!--</xsl:copy>-->
    </xsl:template>
    
    <!-- Add master section for mei:expansion -->
    <xsl:template match="//mei:scoreDef[1]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="n">
                <xsl:value-of select="'piece'"/>
            </xsl:attribute>
            <xsl:element name="expansion" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="type">
                    <xsl:value-of select="'melody'"/>
                </xsl:attribute>
                <xsl:attribute name="plist">
                    <xsl:text>[Enter mei:section IDs here for melody.]</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="expansion" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="type">
                    <xsl:value-of select="'lyrics'"/>
                </xsl:attribute>
                <xsl:attribute name="plist">
                    <xsl:text>#</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
        
    <!-- Entering tempo -->
    <xsl:template match="//mei:measure[@n='1']/mei:staff[@n='2']">
        <xsl:element name="tempo" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="staff">
                <xsl:value-of select="'1'"/>
            </xsl:attribute>
            <xsl:attribute name="tstamp">
                <xsl:value-of select="'1'"/>
            </xsl:attribute>
            <xsl:text>1 = </xsl:text>
            <xsl:element name="rend" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="fontfam">
                    <xsl:value-of select="'smufl'"/>
                </xsl:attribute>
                <xsl:text>[Enter note in unicode]</xsl:text>
            </xsl:element>
        </xsl:element>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- verse/syl labelling for performative sequence -->
    <xsl:function name="mei:get-raw-label" as="xs:string?">
        <xsl:param name="currentSyl" as="element(mei:syl)"/>
        <xsl:variable name="vNum" select="$currentSyl/parent::mei:verse/@n"/>
        <xsl:variable name="txt" select="$currentSyl/text()[1]"/>
        
        <xsl:choose>
            <xsl:when test="matches($txt, '^[a-z]\d+\.')">
                <xsl:value-of select="replace($txt, '^([a-z]\d+)\..*', '$1')"/>
            </xsl:when>
            <xsl:when test="matches($txt, '^\d+\.')">
                <xsl:value-of select="concat('H', replace($txt, '^(\d+)\..*', '$1'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="lastPrefix" select="$currentSyl/preceding::mei:syl[parent::mei:verse/@n = $vNum][matches(., '^([a-z]?\d+)\.')][1]"/>
                <xsl:if test="$lastPrefix">
                    <xsl:variable name="raw" select="replace($lastPrefix, '^([a-z]?\d+)\..*', '$1')"/>
                    <xsl:choose>
                        <xsl:when test="matches($raw, '^[a-z]')">
                            <xsl:variable name="lastH" select="$currentSyl/preceding::mei:syl[parent::mei:verse/@n = $vNum][matches(., '^\d+\.')][1]"/>
                            <xsl:value-of select="concat('tH', replace($lastH, '^(\d+)\..*', '$1'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('H', $raw)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="mei:get-final-label" as="xs:string?">
        <xsl:param name="currentSyl" as="element(mei:syl)"/>
        
        <xsl:variable name="rawLabel" select="mei:get-raw-label($currentSyl)"/>
        <xsl:variable name="parentNote" select="$currentSyl/ancestor::mei:note[1]"/>
        <xsl:variable name="allVerses" select="$parentNote/mei:verse"/>
        
        <xsl:variable name="allRawLabels" as="xs:string*">
            <xsl:for-each select="$allVerses">
                <xsl:sequence select="mei:get-raw-label(mei:syl)"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($allVerses) = 1 and starts-with($rawLabel, 'tH')">
                <xsl:value-of select="replace($rawLabel, '^tH', 't')"/>
            </xsl:when>
            
            <xsl:when test="some $l in $allRawLabels satisfies starts-with($l, 'tH')">
                <xsl:choose>
                    <xsl:when test="starts-with($rawLabel, 'H')">
                        <xsl:value-of select="concat('t', $rawLabel)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$rawLabel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="$rawLabel"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="mei:verse">
        <xsl:copy>
            <xsl:variable name="final" select="mei:get-final-label(mei:syl)"/>
            <xsl:if test="$final">
                <xsl:attribute name="label" select="$final"/>
            </xsl:if>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mei:syl">
        <xsl:copy>
            <xsl:variable name="final" select="mei:get-final-label(.)"/>
            <xsl:if test="$final">
                <xsl:attribute name="label" select="$final"/>
            </xsl:if>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- copy every node in file -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>