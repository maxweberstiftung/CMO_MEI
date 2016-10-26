<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- cleaning up the standard sibmei output and create a fully compatible MEI 3.0 version -->
    
    <!-- strip spaces -->
    <!--<xsl:strip-space elements="mei:staffDef mei:scoreDef mei:measure mei:section"/>-->
    
    
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
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="@func"/>
            <!-- set correct @accid -->
            <xsl:choose>
                <xsl:when test="@accid"></xsl:when>
            </xsl:choose>
            <!-- set correct @accid.ges -->
            <xsl:choose>
                <xsl:when test="@accid.ges"></xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- delete page breaks -->
    <xsl:template match="mei:pb"/>
    
    <!-- put Hanes into sections -->
    <xsl:template match="mei:measure[mei:anchoredText/@label='Hâne']">
        <xsl:variable name="start_measure" select="."/>
        <xsl:variable name="next_start" select="$start_measure/following-sibling::mei:measure[mei:anchoredText/@label='Hâne'][1]/@xml:id"/>
        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="label">
                <xsl:value-of select="mei:anchoredText[@label='Hâne']"/>
            </xsl:attribute>
            <xsl:copy>
                <!-- mark measure as hamparsum sub division or end of cycle -->
                <xsl:choose>
                    <xsl:when test="mei:dir/mei:symbol/@type = 'HampSubDivision'">
                        <xsl:attribute name="type">
                            <xsl:text>HampSubDivision</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="mei:dir/mei:symbol/@type = 'HampEndCycle'">
                        <xsl:attribute name="type">
                            <xsl:text>HampEndCycle</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
            <xsl:for-each select="./following-sibling::mei:measure[not(mei:anchoredText/@label='Hâne')][preceding-sibling::mei:measure[mei:anchoredText/@label='Hâne'][1] = $start_measure]">
                <xsl:copy>
                    <!-- mark measure as hamparsum sub division or end of cycle -->
                    <xsl:choose>
                        <xsl:when test="mei:dir/mei:symbol/@type = 'HampSubDivision'">
                            <xsl:attribute name="type">
                                <xsl:text>HampSubDivision</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="mei:dir/mei:symbol/@type = 'HampEndCycle'">
                            <xsl:attribute name="type">
                                <xsl:text>HampEndCycle</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:measure[not(mei:anchoredText/@label='Hâne')]"/>
    <xsl:template match="mei:anchoredText[@label='Hâne']"/>
    
    <!-- change vertical brackets into <supplied> elements -->
    <!-- case 1: symbol vertical bracket 2 lines -->
    <!-- case 2: symbol vertical bracket 3 lines -->
    <!-- case 3: vertical brackets as lines -->
    <!-- case 3.1: start bracket at beginning of measure and end at start of following measure -->
    <!-- case 3.2: start bracket in middle of measure and end bracket elsewhere (hopefully not in a following measure) -->
    
    <!-- test conversion of colored notes into supplied notes -->
    <xsl:template match="mei:note[@color='rgba(170,0,0,1)']">
          <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
              <xsl:copy>
                  <xsl:apply-templates select="@*[name()!='color']|node()" />
              </xsl:copy>
          </xsl:element>
    </xsl:template>
    <!--<xsl:template match="mei:note[@color='rgba(170,0,0,1)'][position()!=1]"></xsl:template>-->
    
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