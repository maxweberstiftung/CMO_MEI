<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- cleaning up the standard sibmei output and create a fully compatible MEI 3.0 version -->
    
    <!-- strip spaces -->
    <!--<xsl:strip-space elements="mei:staffDef mei:scoreDef mei:measure mei:section"/>-->
    
    <xsl:template match="/*">
        <xsl:if test="//mei:measure[count(mei:line[@type='bracket' and @subtype='vertical']) > 1]">
            <xsl:value-of select="error(QName('http://www.corpus-musicae-ottomanicae.de/err', 'cmo:error'),'There is more than one vertical bracket line in a measure!')"/>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:copy-of select="*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>clean-sibOutput</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO clean sibmei Output prototype</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- insert title information in header -->
    <!-- Title -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:title">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="./ancestor::mei:mei//mei:anchoredText/mei:title"/>    
        </xsl:copy>
        <!--<xsl:apply-templates select="node()" />-->
    </xsl:template>
    <xsl:template match="mei:anchoredText[mei:title]"/>
    
    <!-- Composer -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt/mei:persName[@xml:id]" name="composer">
        <xsl:copy>
            <xsl:attribute name="role">
                <xsl:text>Composer</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="./ancestor::mei:mei//mei:anchoredText[@label='composer']"/>  
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:anchoredText[@label='composer']"/>
    
    <!-- Editor -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt">
        <xsl:copy>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="node()"/>
            <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="id" namespace="http://www.w3.org/XML/1998/namespace">
                    <xsl:value-of select="generate-id()"/>
                </xsl:attribute>
                <xsl:attribute name="role">
                    <xsl:text>Editor</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="./ancestor::mei:mei//mei:anchoredText[@label='Editor_Initials']"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:anchoredText[@label='Editor_Initials']"/>
    
    <!-- 
        Theoretically, the metadata comes from the database and the information about genre, source, usul and makam from the transcription files is not needed.
        Therefor those <anchoredText> elements could be surpressed ... hopefully
    -->
    <xsl:template match="mei:anchoredText[@label='Usûl_name']"/>
    <xsl:template match="mei:anchoredText[@label='Usûl_subtitle']"/>
    <xsl:template match="mei:anchoredText[@label='Genre_subtitle']"/>
    <xsl:template match="mei:anchoredText[@label='Makâm_subtitle']"/>
    <xsl:template match="mei:anchoredText[@label='Source_subtitle']"/>
    
    <!-- clean notes -->
    <xsl:template match="mei:note/@dur.ges"/>
    <xsl:template match="mei:note/@oct.ges"/>
    <xsl:template match="mei:note/@pnum"/>
    
    <!-- clean rests -->
    <xsl:template match="mei:rest/@dur.ges"/>
    
    <!-- clean chords -->
    <xsl:template match="mei:chord/@dur.ges"/>
    
    <!-- clean scoreDef -->
    <xsl:template match="mei:scoreDef/@lyric.name"/>
    <xsl:template match="mei:scoreDef/@music.name"/>
    <xsl:template match="mei:scoreDef/@page.botmar"/>
    <xsl:template match="mei:scoreDef/@page.height"/>
    <xsl:template match="mei:scoreDef/@page.leftmar"/>
    <xsl:template match="mei:scoreDef/@page.rightmar"/>
    <xsl:template match="mei:scoreDef/@page.topmar"/>
    <xsl:template match="mei:scoreDef/@page.width"/>
    <xsl:template match="mei:scoreDef/@ppq"/>
    <xsl:template match="mei:scoreDef/@text.name"/>
    
    <!--
    <xsl:template match="mei:scoreDef/@meter.count"/>
    <xsl:template match="mei:scoreDef/@meter.unit"/>
    -->
    
    <!-- clean staffDef -->
    <xsl:template match="mei:staffDef/mei:instrDef"/>
    <xsl:template match="mei:staffDef/@key.mode"/>
    <xsl:template match="mei:staffDef/@key.sig"/>
    <xsl:template match="mei:staffDef/@clef.dis"/>
    <xsl:template match="mei:staffDef/@clef.dis.place"/>
    <xsl:template match="mei:staffDef/@label"/>
    <xsl:template match="mei:staffDef/comment()"/>
    
    
    <!-- set key signatures according to instrument labels -->
    <xsl:template match="mei:staffDef[@n='1']">
        
        <xsl:variable name="clef-shape" select="@clef.shape"/>
        <xsl:variable name="clef-line" select="@clef.line"/>
        
        <!-- transform staffDef -->
        <xsl:copy>
            <xsl:apply-templates select="@n"/>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="@lines"/>
            <xsl:apply-templates select="@clef.shape"/>
            <xsl:apply-templates select="@clef.line"/>
            
            <!-- process key signatures -->
            <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="id" namespace="http://www.w3.org/XML/1998/namespace">
                    <xsl:value-of select="generate-id()"/>
                </xsl:attribute>
                <!-- tokenize @label to process key signatures -->
                <xsl:for-each select="tokenize(@label,'\s+')">
                    <xsl:variable name="accid" select="substring(.,1,1)"/>
                    <xsl:variable name="loc" select="substring(.,2,1)"/>
                    <xsl:variable name="accidGlyph">
                        <xsl:call-template name="accid2glyph">
                            <xsl:with-param name="accid" select="$accid"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="oct">
                        <xsl:call-template name="loc2oct">
                            <xsl:with-param name="loc" select="number($loc)"/>
                            <xsl:with-param name="clef-shape" select="$clef-shape"/>
                            <xsl:with-param name="clef-line" select="$clef-line"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="pname">
                        <xsl:call-template name="loc2pname">
                            <xsl:with-param name="loc" select="number($loc)"/>
                            <xsl:with-param name="clef-shape" select="$clef-shape"/>
                            <xsl:with-param name="clef-line" select="$clef-line"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="id" namespace="http://www.w3.org/XML/1998/namespace">
                            <xsl:value-of select="generate-id()"/>
                        </xsl:attribute>
                        <xsl:attribute name="accid">
                            <xsl:value-of select="$accid"/>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:value-of select="$loc"/>
                        </xsl:attribute>
                        <xsl:attribute name="glyphnum">
                            <xsl:value-of select="$accidGlyph"/>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:value-of select="$oct"/>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:value-of select="$pname"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- correct accidentals -->
    <xsl:template match="mei:accid">
        <xsl:copy>
            <!-- set @accid -->
            <xsl:choose>
                <xsl:when test="@accid = 's'">
                    <!-- Bakiye sharp -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'B'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E445'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'f'">
                    <!-- Küçük mücenneb (flat) -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'m'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E441'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'fu'">
                    <!-- Büyük mücenneb (flat) -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'bm'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E440'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'su'">
                    <!-- Büyük mücenneb (sharp) -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'BM'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E447'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = '3qf'">
                    <!-- Bakiye (flat) -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'b'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E442'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = '1qf'">
                    <!-- Koma (flat) -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'k'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E443'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = '3qs'">
                    <!-- Küçük mücenneb (sharp) -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'M'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E446'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = '1qs'">
                    <!-- Koma (sharp) -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'K'"/>
                    </xsl:attribute>
                    <xsl:attribute name="glyphnum">
                        <xsl:value-of select="'U+E444'"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'n'">
                    <xsl:choose>
                        <xsl:when test="./@func='caution'">
                            <xsl:attribute name="accid">
                                <xsl:value-of select="'n'"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="accid.ges">
                                <xsl:value-of select="'n'"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- set @accid.ges -->
            <xsl:choose>
                <xsl:when test="@accid.ges = 's'">
                    <!-- Bakiye sharp -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'B'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'f'">
                    <!-- Küçük mücenneb (flat) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'m'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'fu'">
                    <!-- Büyük mücenneb (flat) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'bm'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'su'">
                    <!-- Büyük mücenneb (sharp) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'BM'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = '3qf'">
                    <!-- Bakiye (flat) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'b'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = '1qf'">
                    <!-- Koma (flat) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'k'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = '3qs'">
                    <!-- Küçük mücenneb (sharp) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'M'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = '1qs'">
                    <!-- Koma (sharp) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'K'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges">
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="@accid.ges"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="@* except (@accid, @accid.ges, @func)"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- delete page breaks -->
    <xsl:template match="mei:pb"/>
    
    <!-- correct linking of start group symbols in case of grace notes -->
    <xsl:template match="mei:dir[mei:symbol/@type='group_start']">
        <xsl:variable name="dirRef" select="substring(@startid,2)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'startid']"/>
            <xsl:choose>
                <xsl:when test="//*[@xml:id=$dirRef]/preceding::mei:note[1]/@grace">
                    <xsl:variable name="graceNote" select="//*[@xml:id=$dirRef]/preceding::mei:note[1]"/>
                    <xsl:attribute name="startid">
                        <xsl:value-of select="concat('#',$graceNote/@xml:id)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:when test="//*[@xml:id=$dirRef]/preceding-sibling::mei:beam[1]/mei:note/@grace">
                    <xsl:variable name="graceBeam" select="//*[@xml:id=$dirRef]/preceding-sibling::mei:beam[1][mei:note/@grace]"/>
                    <xsl:attribute name="startid">
                        <xsl:value-of select="concat('#',$graceBeam/mei:note[1]/@xml:id)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:when test="preceding-sibling::mei:dir[mei:symbol/@type='group_end'][1]/@startid = ./@startid and //*[@xml:id=$dirRef]/following::mei:note[1]/@grace">
                    <xsl:variable name="followingGrace" select="//*[@xml:id=$dirRef]/following::mei:note[1]"/>
                    <xsl:attribute name="startid">
                        <xsl:value-of select="concat('#',$followingGrace/@xml:id)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@startid|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- put Hanes into sections and mark measures according to squared bracket lines and division signs -->
    <xsl:template match="mei:measure[mei:anchoredText/@label='Section']">
        <!-- keep self as variable for comparing -->
        <xsl:variable name="start_measure" select="."/>
        <!-- get first note of melody staff -->
        <xsl:variable name="start_melody" select="if (./mei:staff[@n='1']/mei:layer/*[1]/name() = 'beam') then ./mei:staff[@n='1']/mei:layer/mei:beam[1]/*[1] else ./mei:staff[@n='1']/mei:layer[1]/*[1]"/>
        <!-- get last note of melody staff -->
        <xsl:variable name="end_melody" select="if (./mei:staff[@n='1']/mei:layer[1]/*[last()]/name() = 'beam') then ./mei:staff[@n='1']/mei:layer[1]/mei:beam[last()]/*[last()] else ./mei:staff[@n='1']/mei:layer[1]/*[last()]"/>
        <!-- get start measure of following section -->
        <xsl:variable name="next_start" select="$start_measure/following-sibling::mei:measure[mei:anchoredText/@label='Section'][1]/@xml:id"/>
        
        <!-- generate section and put self in it -->
        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="id" namespace="http://www.w3.org/XML/1998/namespace">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <!-- Set Section text as label -->
            <xsl:attribute name="label">
                <xsl:value-of select="mei:anchoredText[@label='Section']"/>
            </xsl:attribute>
            <xsl:copy>
                <!-- mark measure as hamparsum sub division or end of cycle -->
                <xsl:choose>
                    <xsl:when test="@right='dashed'">
                        <xsl:attribute name="type">
                            <xsl:text>HampSubDivision</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:text>HampEndCycle</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- set subtype according to vertical bracket lines -->
                <xsl:choose>
                    <xsl:when test="mei:line[@type='bracket' and @subtype='vertical' and @label='start']">
                        <xsl:choose>
                            <xsl:when test="substring(mei:line/@startid,2) = $start_melody/@xml:id">
                                <xsl:attribute name="subtype">
                                    <xsl:text>suppStart</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="substring(mei:line/@startid,2) = $end_melody/@xml:id">
                                <xsl:attribute name="subtype">
                                    <xsl:text>suppBeforeStart</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="mei:line[@type='bracket' and @subtype='vertical' and @label='end']">
                        <xsl:choose>
                            <xsl:when test="substring(mei:line/@startid,2) = $start_melody/@xml:id">
                                <xsl:attribute name="subtype">
                                    <xsl:text>suppAfterEnd</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="substring(mei:line/@startid,2) = $end_melody/@xml:id">
                                <xsl:attribute name="subtype">
                                    <xsl:text>suppEnd</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
            <!-- add following measures between the next start of a section to the active section -->
            <xsl:for-each select="./following-sibling::mei:measure[not(mei:anchoredText/@label='Section')][preceding-sibling::mei:measure[mei:anchoredText/@label='Section'][1] = $start_measure]">
                <!-- get first note of active measure's melody staff -->
                <xsl:variable name="start_melody2" select="if (./mei:staff[@n='1']/mei:layer[1]/*[1]/name() = 'beam') then ./mei:staff[@n='1']/mei:layer[1]/mei:beam[1]/*[1] else ./mei:staff[@n='1']/mei:layer[1]/*[1]"/>
                <!-- get last not of active measure's melody staff -->
                <xsl:variable name="end_melody2" select="if (./mei:staff[@n='1']/mei:layer[1]/*[last()]/name() = 'beam') then ./mei:staff[@n='1']/mei:layer[1]/mei:beam[last()]/*[last()] else ./mei:staff[@n='1']/mei:layer[1]/*[last()]"/>
                <xsl:copy>
                    <!-- mark measure as hamparsum sub division or end of cycle -->
                    <xsl:choose>
                        <xsl:when test="@right='dashed'">
                            <xsl:attribute name="type">
                                <xsl:text>HampSubDivision</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="type">
                                <xsl:text>HampEndCycle</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- set subtype according to vertical bracket lines -->
                    <xsl:choose>
                        <xsl:when test="mei:line[@type='bracket' and @subtype='vertical' and @label='start']">
                            <xsl:choose>
                                <xsl:when test="substring(mei:line/@startid,2) = $start_melody2/@xml:id">
                                    <xsl:attribute name="subtype">
                                        <xsl:text>suppStart</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <!--<xsl:when test="substring(mei:line/@startid,2) = $end_melody2/@xml:id">
                                    <xsl:attribute name="subtype">
                                        <xsl:text>suppBeforeStart</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>-->
                                <xsl:otherwise>
                                    <xsl:attribute name="subtype">
                                        <xsl:text>suppBeforeStart</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="mei:line[@type='bracket' and @subtype='vertical' and @label='end']">
                            <xsl:choose>
                                <!--<xsl:when test="substring(mei:line/@startid,2) = $start_melody2/@xml:id">
                                    <xsl:attribute name="subtype">
                                        <xsl:text>suppAfterEnd</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>-->
                                <xsl:when test="substring(mei:line/@startid,2) = $end_melody2/@xml:id">
                                    <xsl:attribute name="subtype">
                                        <xsl:text>suppEnd</xsl:text>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="subtype">
                                        <xsl:text>suppAfterEnd</xsl:text>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:measure[not(mei:anchoredText/@label='Section')]"/>
    <xsl:template match="mei:anchoredText[@label='Section']"/>
    
    <!-- change vertical bracket symbols to marking labels for start and end points of <supplied> elements -->
    <xsl:template match="mei:dir[mei:symbol/@type='suppliedBracketStart']"/>
    <xsl:template match="mei:dir[mei:symbol/@type='suppliedBracketEnd']"/>
        
    <xsl:template match="mei:layer[../following-sibling::mei:dir[mei:symbol/@type='suppliedBracketStart']]">
        <xsl:variable name="startBrackets" select="./../following-sibling::mei:dir[mei:symbol/@type='suppliedBracketStart']"/>
        <xsl:variable name="endBrackets" select="./../following-sibling::mei:dir[mei:symbol/@type='suppliedBracketEnd']"/>
        
        <xsl:variable name="startPoint" select="for $x in $startBrackets return substring($x/@startid,2)"/>
        <xsl:variable name="endPoint" select="for $x in $endBrackets return substring($x/@startid,2)"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="./*">
                <xsl:choose>
                    <!-- note is referenced in startid of a start bracket -->
                    <xsl:when test="./@xml:id = $startPoint and not(./@xml:id = $endPoint)">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                                <xsl:attribute name="label">
                                    <xsl:value-of select="'suppStart'"/>
                                </xsl:attribute>
                            <xsl:apply-templates select="./*"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="./@xml:id = $endPoint and not(./@xml:id = $startPoint)">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                                <xsl:attribute name="label">
                                    <xsl:value-of select="'suppEnd'"/>
                                </xsl:attribute>
                            <xsl:apply-templates select="./*"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="./@xml:id = $endPoint and ./@xml:id = $startPoint">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="label">
                                <xsl:value-of select="'suppStartEnd'"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="./*"/>
                        </xsl:copy>
                    </xsl:when>
                    <!-- get referenced child elements -->
                    <xsl:when test="././*/@xml:id = $startPoint or ././*/@xml:id = $endPoint">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:for-each select="./*">
                                <xsl:choose>
                                    <xsl:when test="./@xml:id = $startPoint and not(./@xml:id = $endPoint)">
                                        <xsl:copy>
                                            <xsl:apply-templates select="@*"/>
                                            <xsl:attribute name="label">
                                                <xsl:value-of select="'suppStart'"/>
                                            </xsl:attribute>
                                            <xsl:apply-templates select="./*"/>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:when test="./@xml:id = $endPoint and not(./@xml:id = $startPoint)">
                                        <xsl:copy>
                                            <xsl:apply-templates select="@*"/>
                                            <xsl:attribute name="label">
                                                <xsl:value-of select="'suppEnd'"/>
                                            </xsl:attribute>
                                            <xsl:apply-templates select="./*"/>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:when test="./@xml:id = $endPoint and ./@xml:id = $startPoint">
                                        <xsl:copy>
                                            <xsl:apply-templates select="@*"/>
                                            <xsl:attribute name="label">
                                                <xsl:value-of select="'suppStartEnd'"/>
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
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates select="./*"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <!-- case 3.2: start bracket in middle of measure and end bracket elsewhere (hopefully not in a following measure) -->
    
    <!-- clean vertical bracket lines from unused @endid -->
    <xsl:template match="mei:line[@type='bracket' and @subtype='vertical']">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@startid = @endid">
                    <xsl:apply-templates select="@*[name() != 'endid']"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
      
    <!-- add note information, if it is a start supply or end supply of a vertical bracket from a middle of a measure -->
    <xsl:template match="node()[name() = 'note' or name() = 'rest'][ancestor::mei:staff[@n='1'] and ancestor::mei:measure[child::mei:line[@type='bracket']]]">
        <!-- safe line for comparison -->
        <xsl:variable name="line" select="./ancestor::mei:staff/following-sibling::mei:line[@type='bracket']"/>
        <!-- get first note of melody staff -->
        <xsl:variable name="start_melody" select="if (./parent::mei:layer/*[1]/name() = 'beam') then ./parent::mei:layer/mei:beam[1]/*[1] else ./parent::mei:layer[1]/*[1]"/>
        <!-- get last note of melody staff -->
        <xsl:variable name="end_melody" select="if (./parent::mei:layer/*[last()]/name() = 'beam') then ./parent::mei:layer/mei:beam[last()]/*[last()] else ./parent::mei:layer/*[last()]"/>
        
        
        <!-- first, check if bracket is start or end of an insertion -->
        <xsl:choose>
            <xsl:when test="$line/@label='start'">
                <!-- if start, then check position of referenced event within layer -->
                <xsl:choose>
                    <!-- referenced event of bracket is start point -->
                    <xsl:when test="./@xml:id = substring($line/@startid,2)">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="label">
                                <xsl:value-of select="'suppStart'"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:when>
                    <!-- last event in layer is end point -->
                    <xsl:when test="./@xml:id = $end_melody/@xml:id">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="label">
                                <xsl:value-of select="'suppEnd'"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$line/@label='end'">
                <!-- if end, then check position of referenced event within layer -->
                <xsl:choose>
                    <!-- referenced musical event is end point -->
                    <xsl:when test="./@xml:id = substring($line/@startid,2)">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="label">
                                <xsl:value-of select="'suppEnd'"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:when>
                    <!-- first musical event in layer is start point -->
                    <xsl:when test="./@xml:id = $start_melody/@xml:id">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="label">
                                <xsl:value-of select="'suppStart'"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- transform accid letter to glyph -->
    <xsl:template name="accid2glyph">
        <xsl:param name="accid"/>
        <xsl:choose>
            
            <!-- Bakiye flat -->
            <xsl:when test="$accid = 'b'">
                <xsl:value-of select="'U+E442'"/>
            </xsl:when>
            <!-- Küçük mücenneb flat -->
            <xsl:when test="$accid = 'm'">
                <xsl:value-of select="'U+E441'"/>
            </xsl:when>
            <!-- Koma flat -->
            <xsl:when test="$accid = 'k'">
                <xsl:value-of select="'U+E443'"/>
            </xsl:when>
            <!-- Bakiye sharp -->
            <xsl:when test="$accid = 'B'">
                <xsl:value-of select="'U+E445'"/>
            </xsl:when>
            <!-- Küçük mücenneb sharp -->
            <xsl:when test="$accid = 'M'">
                <xsl:value-of select="'U+E446'"/>
            </xsl:when>
            <!-- Koma sharp -->
            <xsl:when test="$accid = 'K'">
                <xsl:value-of select="'U+E444'"/>
            </xsl:when>
            <!-- Büyük mücenneb flat -->
            <xsl:when test="$accid = 'f'">
                <xsl:value-of select="'U+E440'"/>
            </xsl:when>
            <!-- Büyük mücenneb sharp -->
            <xsl:when test="$accid = 'S'">
                <xsl:value-of select="'U+E447'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- get ocatve number by loc -->
    <xsl:template name="loc2oct">
        <xsl:param name="loc" as="xs:double"/>
        <xsl:param name="clef-line"/>
        <xsl:param name="clef-shape"/>
        <xsl:if test="($clef-line = 2) and ($clef-shape = 'G')">
            <xsl:choose>
                <xsl:when test="($loc &gt;= -9) and ($loc &lt;= -3)">
                    <xsl:value-of select="'3'"/>
                </xsl:when>
                <xsl:when test="($loc &lt;= 4) and ($loc &gt;= -2)">
                    <xsl:value-of select="'4'"/>
                </xsl:when>
                <xsl:when test="($loc &gt;= 5) and ($loc &lt;= 11)">
                    <xsl:value-of select="'5'"/>
                </xsl:when>
                <xsl:when test="$loc &lt;= 12">
                    <xsl:value-of select="'6'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!-- get pitchname by loc -->
    <xsl:template name="loc2pname">
        <xsl:param name="loc" as="xs:double"/>
        <xsl:param name="clef-line"/>
        <xsl:param name="clef-shape"/>
        <xsl:if test="($clef-line = 2) and ($clef-shape = 'G')">
            <xsl:choose>
                <xsl:when test="($loc = -9) or ($loc = -2) or ($loc = 5) or ($loc = 12)">
                    <xsl:value-of select="'c'"/>
                </xsl:when>
                <xsl:when test="($loc = -8) or ($loc = -1) or ($loc = 6)">
                    <xsl:value-of select="'c'"/>
                </xsl:when>
                <xsl:when test="($loc = -7) or ($loc = 0) or ($loc = 7)">
                    <xsl:value-of select="'c'"/>
                </xsl:when>
                <xsl:when test="($loc = -6) or ($loc = 1) or ($loc = 8)">
                    <xsl:value-of select="'f'"/>
                </xsl:when>
                <xsl:when test="($loc = -5) or ($loc = 2) or ($loc = 9)">
                    <xsl:value-of select="'g'"/>
                </xsl:when>
                <xsl:when test="($loc = -4) or ($loc = 3) or ($loc = 10)">
                    <xsl:value-of select="'a'"/>
                </xsl:when>
                <xsl:when test="($loc = -3) or ($loc = 4) or ($loc = 11)">
                    <xsl:value-of select="'b'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>