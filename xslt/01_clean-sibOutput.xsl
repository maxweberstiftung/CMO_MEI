<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:cmo="http://www.example.org/cmo"
    exclude-result-prefixes="xs" version="3.0">

    <!-- copy every node in file -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="UTF-16"/>

    <!-- cleaning up the standard sibmei output and create a fully compatible MEI 4.0.1 version -->

    <!-- strip spaces -->
    <xsl:strip-space elements="*"/>

    <!-- Variables for handling of special <symbol> -->
    <xsl:variable name="baseURI2symbols"
        select="'https://raw.githubusercontent.com/maxweberstiftung/CMO_MEI/master/'"/>
    <xsl:variable name="cmo_symbolTable" select="'cmo_symbolTable.xml'"/>
    <xsl:variable name="cmo_symbols"
        select="document(resolve-uri($cmo_symbolTable, $baseURI2symbols))"/>

    <!-- Variables for sectioning -->
    <xsl:variable name="sectionName" select="'Section'"/>

    <!-- Variables for hampartsum groups -->
    <xsl:variable name="group_start" select="'U+E201'"/>
    <xsl:variable name="group_end" select="'U+E203'"/>

    <!-- check if only one vertical bracket line is in a measure -->
    <xsl:template match="/*">
        <xsl:if
            test="//mei:measure[count(mei:line[@type = 'bracket' and @subtype = 'vertical']) > 1]">
            <xsl:value-of
                select="error(QName('http://www.corpus-musicae-ottomanicae.de/err', 'cmo:error'), 'There is more than one vertical bracket line in a measure!')"
            />
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- set CMO Ref as altID -->
    <!--
    <xsl:template match="mei:meiHead">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="//mei:anchoredText[@label = 'CMO Ref']">
                <xsl:element name="altId" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="label">
                        <xsl:value-of select="'CMO Ref'"/>
                    </xsl:attribute>
                    <xsl:value-of select="//mei:anchoredText[@label = 'CMO Ref']"/>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    -->

    <!-- Convert title to main title and subtitle to incipit -->
    <!-- Moved to 04 -->

    <!-- insert title information in header -->
    <!-- replace title information from metadata with title information from score -->
    <!--
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:title["/>
    <xsl:template match="mei:anchoredText[mei:title]"/>
    -->

    <xsl:template match="//mei:fileDesc/mei:titleStmt">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- add Fasıl title-->
            <xsl:if test="//mei:anchoredText[@label = 'Fasıl']">
                <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="label">
                        <xsl:value-of select="'fasil'"/>
                    </xsl:attribute>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="//mei:anchoredText[@label = 'Fasıl']/@xml:id"/>
                    </xsl:attribute>
                    <xsl:value-of select="//mei:anchoredText[@label = 'Fasıl']"/>
                </xsl:element>
            </xsl:if>
            <!-- add title -->
            <!--
            <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="//mei:anchoredText/mei:title/@xml:id"/>
                </xsl:attribute>
                <xsl:value-of select="//mei:anchoredText/mei:title"/>
            </xsl:element>
            -->
            <!-- add Incipit -->
            <!--
            <xsl:if test="//mei:anchoredText[@label = 'Incipit']">
                <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="label">
                        <xsl:value-of select="'Incipit'"/>
                    </xsl:attribute>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="//mei:anchoredText[@label = 'Incipit']/@xml:id"/>
                    </xsl:attribute>
                    <xsl:value-of select="//mei:anchoredText[@label = 'Incipit']"/>
                </xsl:element>
            </xsl:if>
            -->
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Source information -->
    <!--<xsl:template match="mei:fileDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*|*"/>
            <xsl:element name="sourceDesc" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:if test="//mei:anchoredText[@label='Source']">
                    <xsl:call-template name="addsource"/>
                </xsl:if>
            </xsl:element>
        </xsl:copy>
    </xsl:template>-->

    <!-- Composer and Lyricist -->
    <!--
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt/mei:persName[@xml:id]"
        name="composer">
        <xsl:copy>
            <xsl:attribute name="role">
                <xsl:text>attribution</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="//mei:anchoredText[@label = 'composer']/@xml:id"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="./ancestor::mei:mei//mei:anchoredText[@label = 'composer']"/>
        </xsl:copy>
        <xsl:choose>
            <xsl:when test="//mei:anchoredText[@label = 'Lyricist']">
                <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="role">
                        <xsl:text>lyricist</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="//mei:anchoredText[@label = 'Lyricist']/@xml:id"/>
                    </xsl:attribute>
                    <xsl:value-of
                        select="./ancestor::mei:mei//mei:anchoredText[@label = 'Lyricist']"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="//mei:lyricist">
                <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="role">
                        <xsl:text>Lyricist</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="//mei:lyricist/@xml:id"/>
                    </xsl:attribute>
                    <xsl:value-of select="//mei:lyricist"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    -->

    <!-- Editor -->
    <!--
    <xsl:template match="//mei:fileDesc/mei:titleStmt/mei:respStmt">
        <xsl:copy>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="node()"/>
            <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="//mei:anchoredText[@label = 'Editor Initials']/@xml:id"/>
                </xsl:attribute>
                <xsl:attribute name="role">
                    <xsl:text>editor</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="//mei:anchoredText[@label = 'Editor Initials']/text()"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:anchoredText[@label = 'Editor Initials']"/>
    -->

    <!-- 
        Theoretically, the metadata comes from the database and the information about genre, source, usul and makam from the transcription files is not needed.
        Therefore, those <anchoredText> elements could be surpressed ... hopefully
    -->

    <!--<xsl:template match="mei:anchoredText[@label = 'Usûl']"/>
    <xsl:template match="mei:anchoredText[@label = 'Genre']"/>
    <xsl:template match="mei:anchoredText[@label = 'Makâm']"/>
    <xsl:template match="mei:anchoredText[@label = 'Source']"/>
    <xsl:template match="mei:anchoredText[@label = 'CMO Ref']"/>
    <xsl:template match="mei:anchoredText[@label = 'Fasıl']"/>
    <xsl:template match="mei:anchoredText[@label = 'Incipit']"/>-->

    <!-- Build Edition Statement in parallel to the text edition -->
    <!-- Customize the following part depending on the actual edition --> 
    <xsl:variable name="editorID" select="'#CM'"/>
    <xsl:variable name="normdataURI" select="''"/>
    <xsl:variable name="editor" select="'C. Ersin Mıhçı'"/>
    <!-- End customization -->
    <xsl:template match="//mei:fileDesc/mei:titleStmt">
        <xsl:copy-of select="."/>
        <xsl:element name="editionStmt" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:element name="edition" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:value-of select="'First Edition'"/>
            </xsl:element>
            <xsl:element name="funder" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="target">
                        <xsl:value-of select="'https://www.dfg.de'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Deutsche Forschungsgemeinschaft'"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="sponsor" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="target">
                        <xsl:value-of select="'https://www.uni-muenster.de'"/>
                    </xsl:attribute>
                <xsl:value-of select="'Universität Münster'"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="analog">
                        <xsl:value-of select="'ged'"/>
                    </xsl:attribute>
                    <xsl:attribute name="auth">
                        <xsl:value-of select="'MARC'"/>
                    </xsl:attribute>
                    <xsl:attribute name="auth.uri">
                        <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'General Editor'"/>
                </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="'#RJ'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://explore.gnd.network/gnd/122654099'"/>
                        </xsl:attribute>
                        <xsl:value-of select="'Prof. Dr. Ralf Martin Jäger'"/>
                    </xsl:element>
                    <xsl:element name="corpName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:value-of select="'Universität Münster'"/>
                    </xsl:element>
            </xsl:element>
            <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="analog">
                        <xsl:value-of select="'edi'"/>
                    </xsl:attribute>
                    <xsl:attribute name="auth">
                        <xsl:value-of select="'MARC'"/>
                    </xsl:attribute>
                    <xsl:attribute name="auth.uri">
                        <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Editor(s)'"/>
                </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="'##[ID]'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'[Delete if none]'"/>
                        </xsl:attribute>
                        <xsl:value-of select="'[Enter persName]'"/>
                    </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Build Publication Statement in parallel to the text edition -->
    <xsl:variable name="year" select="current-date()"/>
    <xsl:template match="//mei:fileDesc/mei:pubStmt">
        <xsl:copy>
            <xsl:element name="publisher" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:value-of select="'Corpus Musicae Ottomanicae'"/>
            </xsl:element>
            <xsl:element name="distributor" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:value-of
                    select="'perspectiva.net - Die Publikationsplattform der Max Weber Stiftung'"/>
            </xsl:element>
            <xsl:element name="date" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:value-of select="format-date($year, '[Y0001]')"/>
            </xsl:element>
            <xsl:element name="pubPlace" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:value-of select="'online'"/>
            </xsl:element>
            <xsl:element name="availability" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="//mei:fileDesc/mei:pubStmt/mei:availability/@xml:id"/>
                </xsl:attribute>
                <xsl:element name="useRestrict" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="//mei:fileDesc/mei:pubStmt/mei:availability/mei:useRestrict/@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="auth.uri">
                        <xsl:value-of
                            select="'http://creativecommons.org/licenses/by-sa/4.0/deed.en'"/>
                    </xsl:attribute>
                    <xsl:value-of
                        select="'Licence: Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)'"/>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- clean notes and measures -->
    <xsl:template match="mei:note/@oct.ges"/>
    <xsl:template match="mei:note/@pnum"/>
    <xsl:template match="mei:measure/@label"/>

    <!-- remove midi-related attributes from notes, rests and chords -->
    <xsl:template match="@dur.ppq"/>
    <xsl:template match="@tstamp.real"/>
    <xsl:template match="@vel"/>


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
    <xsl:template match="mei:scoreDef/@vu.height"/>
    <xsl:template match="mei:scoreDef/@spacing.staff"/>
    <xsl:template match="mei:scoreDef/@spacing.system"/>
    <xsl:template match="mei:scoreDef/@meter.unit"/>
    <xsl:template match="mei:scoreDef/@meter.count">
        <xsl:attribute name="beat.count">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <!-- clean staffDef -->
    <xsl:template match="mei:staffDef/mei:instrDef"/>
    <xsl:template match="mei:staffDef/@key.mode"/>
    <xsl:template match="mei:staffDef/@key.sig"/>
    <xsl:template match="mei:staffDef/@clef.dis"/>
    <xsl:template match="mei:staffDef/@clef.dis.place"/>
    <xsl:template match="mei:staffDef/@label"/>
    <xsl:template match="mei:staffDef/comment()"/>

    <!-- delete verses with empty syllables -->
    <xsl:template match="mei:verse[not(mei:syl/text())]"/>
    <!-- delete empty syllables -->
    <xsl:template match="mei:syl[not(text())]"/>

    <!-- Change MEI Version -->
    <xsl:template match="mei:mei/@meiversion">
        <xsl:attribute name="meiversion">
            <xsl:value-of select="'5.0'"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Add info to workList -->
    <!--<xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    -->
    <xsl:template match="//mei:workList/mei:work/mei:notesStmt/mei:annot">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="type">
                <xsl:value-of select="'identifierCMO'"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
        <xsl:element name="annot" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="type">
                <xsl:value-of select="'workNumber'"/>
            </xsl:attribute>
            <xsl:text>[Enter Work Number here or delete element]</xsl:text>
        </xsl:element>
    </xsl:template>
    
    <!-- set key signatures according to instrument labels -->
    <xsl:template match="mei:staffDef[@n = '1']">

        <xsl:variable name="clef-shape" select="@clef.shape"/>
        <xsl:variable name="clef-line" select="@clef.line"/>

        <!-- transform staffDef -->
        <xsl:copy>
            <xsl:apply-templates select="@n"/>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="@lines"/>
            <xsl:apply-templates select="@clef.shape"/>
            <xsl:apply-templates select="@clef.line"/>
            
            <!-- New for manual -->
            <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="type">
                    <xsl:value-of select="''"/>
                </xsl:attribute>
                <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="'ka-1'"/>
                    </xsl:attribute>
                    <xsl:attribute name="loc">
                        <xsl:value-of select="'[3-9]'"/>
                    </xsl:attribute>
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'[AEU]'"/>
                    </xsl:attribute>
                </xsl:element>
                <xsl:comment> Delete me / duplicate as needed. </xsl:comment>
            </xsl:element>

            <!-- Original -->
                <!--
                <xsl:choose>
                <xsl:when test="@label = 'N'"/>
                <xsl:when test="empty(@label)"/>
                <xsl:otherwise>
                -->
                    <!-- process key signatures -->
                    <!--
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                    -->
                        <!-- tokenize @label to process key signatures -->
                        <!--
                        <xsl:for-each
                            select="tokenize(substring(@label, 2, @label/string-length() - 2), '\s+')">
                            <xsl:variable name="accid" select="substring(., 2, 1)"/>
                            <xsl:variable name="loc" select="substring(., 1, 1)"/>
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

                            <xsl:element name="keyAccid"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="accid">
                                    <xsl:value-of select="$accid"/>
                                </xsl:attribute>
                                <xsl:attribute name="loc">
                                    <xsl:value-of select="$loc"/>
                                </xsl:attribute>
                                <xsl:attribute name="glyph.num">
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
                </xsl:otherwise>
            </xsl:choose>
            -->

        </xsl:copy>
    </xsl:template>

    <xsl:template match="mei:note">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()[name() != 'verse']"/>
            
            <xsl:variable name="preparedVerses">
                <xsl:for-each select="mei:verse">
                    <xsl:copy>
                        <xsl:choose>
                            <xsl:when test="@n">
                                <xsl:copy-of select="@n"/>
                            </xsl:when>
                            <xsl:when test="matches(mei:syl, '^\s*\d+\.?\s*$')">
                                <xsl:attribute name="n" select="replace(mei:syl, '[^\d]', '')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="prevNum" select="preceding-sibling::mei:verse[matches(mei:syl, '^\s*\d+\.?\s*$')][1]"/>
                                <xsl:if test="$prevNum">
                                    <xsl:attribute name="n" select="replace($prevNum/mei:syl, '[^\d]', '')"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="@*[name() != 'n'] | node()"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:variable name="verses" select="$preparedVerses/mei:verse"/>
            
            <xsl:for-each select="distinct-values($verses/@n)">
                <xsl:variable name="num" select="."/>
                <xsl:variable name="currentVerses" select="$verses[@n = $num]"/>
                
                <xsl:choose>
                    <xsl:when test="count($currentVerses) >= 2">
                        <xsl:variable name="verseNum" select="$currentVerses[matches(mei:syl, '^\s*\d+\.?\s*$')][1]"/>
                        <xsl:variable name="textVerses" select="$currentVerses[not(generate-id() = generate-id($verseNum))]"/>
                        
                        <xsl:choose>
                            <xsl:when test="$verseNum">
                                <xsl:element name="verse" namespace="http://www.music-encoding.org/ns/mei">
                                    <xsl:attribute name="n" select="$num"/>
                                    <xsl:apply-templates select="$textVerses[1]/@*[name() != 'n']"/>
                                    <xsl:element name="syl" namespace="http://www.music-encoding.org/ns/mei">
                                        <xsl:apply-templates select="$textVerses[1]/mei:syl/@*"/>
                                        <xsl:value-of select="concat($verseNum/mei:syl, ' ', string-join($textVerses/mei:syl, ' '))"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$currentVerses"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$currentVerses"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!--
    <xsl:template match="mei:note">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()[name() != 'verse']"/>
            <xsl:variable name="verses" select="mei:verse"/>
            <xsl:for-each select="distinct-values(mei:verse/@n)">
                <xsl:variable name="num" select="." as="xs:integer"/>
                <xsl:variable name="currentVerses" select="$verses[@n = $num]"/>
                <xsl:choose>
                    try to merge verse numbers and first syllables
                    <xsl:when test="count($currentVerses) = 2">
                        check which one is the verse number
                        <xsl:variable name="verseNum"
                            select="$currentVerses[matches(mei:syl, '\d.')]"/>
                        <xsl:variable name="verseSyl"
                            select="$currentVerses[@xml:id != $verseNum/@xml:id]"/>
                        
                        <xsl:element name="verse" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:apply-templates select="$verseSyl/@*"/>
                            <xsl:element name="syl" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:apply-templates select="$verseSyl/mei:syl/@*"/>
                                <xsl:value-of
                                    select="concat($verseNum/mei:syl, ' ', $verseSyl/mei:syl)"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$currentVerses"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
-->
    
    <!-- correct accidentals -->
    <xsl:template match="mei:accid">
        <xsl:copy>
            <!-- set @accid -->
            <xsl:choose>
                <xsl:when test="@accid = 'sd'">
                    <!-- Koma sharp -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'ks'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E444'"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'fu'">
                    <!-- Koma flat -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'kf'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E443'"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 's'">
                    <!-- Bakiye sharp -->
                    <xsl:apply-templates select="@* | node()"/>
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'bs'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E445'"/>
                    </xsl:attribute>-->
                </xsl:when>
                <xsl:when test="@accid = 'fd'">
                    <!-- Bakiye flat -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'bf'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E442'"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'su'">
                    <!-- Küçük mücenneb sharp -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'kms'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E446'"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'f'">
                    <!-- Küçük mücenneb flat -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'kmf'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E441'"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'x'">
                    <!-- Büyük mücenneb sharp -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'bms'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E447'"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'ff'">
                    <!-- Büyük mücenneb flat -->
                    <xsl:attribute name="accid">
                        <xsl:value-of select="'bmf'"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="glyph.num">
                        <xsl:value-of select="'U+E440'"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="@func"/>
                </xsl:when>
                <xsl:when test="@accid = 'n'">
                    <xsl:choose>
                        <xsl:when test="./@func = 'caution'">
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
                <xsl:when test="@accid.ges = 'sd'">
                    <!-- Koma sharp -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'ks'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'fu'">
                    <!-- Koma flat -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'kf'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 's'">
                    <!-- Bakiye sharp -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'bs'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'fd'">
                    <!-- Bakiye (flat) -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'bf'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'su'">
                    <!-- Küçük mücenneb sharp -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'kms'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'f'">
                    <!-- Küçük mücenneb flat -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'kmf'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'x'">
                    <!-- Büyük mücenneb sharp -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'bms'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges = 'ff'">
                    <!-- Büyük mücenneb flat -->
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="'bmf'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@accid.ges">
                    <xsl:attribute name="accid.ges">
                        <xsl:value-of select="@accid.ges"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <!-- adding @altsym to Nim geveşt -->
            <xsl:if test="@label = $cmo_symbols//@label">
                <xsl:variable name="currentSymbol" select="string(./@label)"/>
                <xsl:variable name="symbol"
                    select="$cmo_symbols//mei:symbolDef[@label = $currentSymbol]"/>
                <xsl:attribute name="altsym">
                    <xsl:value-of select="concat($cmo_symbolTable, '#', $symbol/@xml:id)"/>
                </xsl:attribute>
                <!-- needs to add an xml:base url to find file -->
                <xsl:attribute name="xml:base">
                    <xsl:value-of select="$baseURI2symbols"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@* except (@accid, @accid.ges, @func)"/>
        </xsl:copy>
    </xsl:template>

    <!-- delete page breaks -->
    <xsl:template match="mei:pb"/>

    <!-- correct linking of start group symbols in case of grace notes -->
    <xsl:template match="mei:dir[mei:symbol/@glyph.num = $group_start]">
        <xsl:variable name="dirRef" select="substring(@startid, 2)"/>
        <xsl:copy>
            <xsl:apply-templates select="@* except (@startid)"/>
            <xsl:choose>
                <xsl:when test="//*[@xml:id = $dirRef]/preceding::*[1][@grace]">
                    <xsl:variable name="firstPrecedingWithGrace"
                        select="//*[@xml:id = $dirRef]/preceding::*[1][@grace]"/>
                    <xsl:choose>
                        <xsl:when
                            test="$firstPrecedingWithGrace/parent::*/local-name() = 'beam' and count($firstPrecedingWithGrace/preceding-sibling::*/@grace) = count($firstPrecedingWithGrace/preceding-sibling::*)">
                            <!-- get first note in preceding beams that consist entirely of grace notes -->
                            <xsl:attribute name="startid"
                                select="concat('#', $firstPrecedingWithGrace/preceding-sibling::mei:note[position() = last()]/@xml:id)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- get preceding grace note, chord or graceGrp -->
                            <xsl:attribute name="startid"
                                select="concat('#', $firstPrecedingWithGrace/@xml:id)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@startid"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- add Mükerrer and Grgnum into same <dir> element with Division sign -->
    <!-- E.g. 204 pc 78. -->
    <xsl:template
        match="mei:dir[descendant::mei:symbol/@type = 'endCycle' or descendant::mei:symbol/@type = 'division']">
        <xsl:variable name="dirReference" select="./@startid"/>
        <xsl:variable name="anchoredText"
            select="../mei:anchoredText[((@label = 'Mükerrer') or (@label = 'Grgnum')) and @startid = $dirReference]"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when
                    test="contains($anchoredText/text(), '[') and contains($anchoredText/text(), ']')">
                    <xsl:variable name="croppedText"
                        select="substring-before(substring-after($anchoredText/text(), '['), ']')"/>
                    <xsl:element name="supplied" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:value-of select="$croppedText"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$anchoredText/text()"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--<xsl:copy-of select="$anchoredText"/>-->
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:anchoredText[@label = 'Mükerrer']"/>
    <xsl:template match="mei:anchoredText[@label = 'Grgnum']"/>

    <!-- put Section markings into sections and mark measures according to squared bracket lines and division signs -->
    <xsl:template match="mei:section">
        <xsl:choose>
            <xsl:when test="./mei:measure[mei:anchoredText/@label = $sectionName]">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <!-- first, write every element without a preceding section mark -->
                    <xsl:for-each
                        select="node()[not(mei:anchoredText/@label = $sectionName) and not(preceding-sibling::mei:measure[mei:anchoredText/@label = $sectionName]) and not(name() = 'scoreDef' and following-sibling::*[1]/mei:anchoredText/@label = $sectionName)]">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <!-- then, write all measures from a section mark to the next mark in a section -->
                    <xsl:for-each select="mei:measure[mei:anchoredText/@label = $sectionName]">
                        <!-- keep self as variable for comparing -->
                        <xsl:variable name="start_measure" select="."/>
                        <xsl:variable name="nextStartN"
                            select="string(./following-sibling::mei:measure[mei:anchoredText/@label = $sectionName][1]/@n)"/>

                        <!-- generate section and put self in it -->
                        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
                            <!-- Set Section text as label -->
                            <xsl:attribute name="label">
                                <xsl:value-of select="mei:anchoredText[@label = $sectionName]"/>
                            </xsl:attribute>
                            <!-- add id of text element -->
                            <xsl:attribute name="xml:id">
                                <xsl:value-of
                                    select="mei:anchoredText[@label = $sectionName]/@xml:id"/>
                            </xsl:attribute>
                            <!-- catch a preceding <scoreDef> -->
                            <xsl:if test="./preceding-sibling::*[1]/name() = 'scoreDef'">
                                <xsl:apply-templates
                                    select="./preceding-sibling::*[1][name() = 'scoreDef']"/>
                            </xsl:if>

                            <!-- write current measure -->
                            <xsl:apply-templates select="."/>

                            <!-- write following elements until next start -->
                            <xsl:for-each
                                select="./following-sibling::node()[not(mei:anchoredText/@label = $sectionName)][preceding-sibling::mei:measure[mei:anchoredText/@label = $sectionName][1] = $start_measure]">
                                <xsl:apply-templates
                                    select=". except (.[name() = 'scoreDef' and following-sibling::mei:measure[1]/@n = $nextStartN])"
                                />
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="mei:measure">
        <!-- get first note of melody staff -->
        <xsl:variable name="start_melody"
            select="
                if (./mei:staff[@n = '1']/mei:layer/*[1]/name() = 'beam') then
                    ./mei:staff[@n = '1']/mei:layer/mei:beam[1]/*[1]
                else
                    ./mei:staff[@n = '1']/mei:layer[1]/*[1]"/>
        <!-- get last note of melody staff -->
        <xsl:variable name="end_melody"
            select="
                if (./mei:staff[@n = '1']/mei:layer[1]/*[last()]/name() = 'beam') then
                    ./mei:staff[@n = '1']/mei:layer[1]/mei:beam[last()]/*[last()]
                else
                    ./mei:staff[@n = '1']/mei:layer[1]/*[last()]"/>

        <!-- get if measure is division or end of cycle -->
        <xsl:variable name="measureType"
            select="
                if (@right = 'dashed') then
                    'division'
                else
                    'endCycle'"/>

        <!-- get type attribute according to vertical brackets -->
        <xsl:variable name="suppliedStatus">
            <xsl:choose>
                <xsl:when test="mei:line[@type = 'bracket vertical start']">
                    <xsl:choose>
                        <xsl:when
                            test="substring(mei:line[@type = 'bracket vertical start']/@startid, 2) = $start_melody/@xml:id">
                            <xsl:value-of select="'suppStart'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'suppBeforeStart'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="mei:line[@type = 'bracket vertical end']">
                    <xsl:choose>
                        <xsl:when
                            test="substring(mei:line[@type = 'bracket vertical end']/@startid, 2) = $end_melody/@xml:id">
                            <xsl:value-of select="'suppEnd'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'suppAfterEnd'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:copy>
            <xsl:attribute name="type">
                <xsl:value-of
                    select="
                        if ($suppliedStatus != '') then
                            concat($measureType, ' ', $suppliedStatus)
                        else
                            $measureType"
                />
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Build Series Statement in parallel to the text edition -->
    <xsl:template match="//mei:fileDesc">
        <xsl:copy>
            <xsl:apply-templates select="*"/>
            <xsl:element name="seriesStmt" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="type">
                        <xsl:value-of select="'edition'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Corpus Musicae Ottomanicae'"/>
                </xsl:element>
                <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="type">
                        <xsl:value-of select="'#part'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Part [#]: Edition of Manuscripts in [Hampartsum/Staff] Notation'"/>
                </xsl:element>
                <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="type">
                        <xsl:value-of select="'#series'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Series [#]: The Manuscript Sources from [Institution]'"/>
                </xsl:element>
                <xsl:element name="title" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="type">
                        <xsl:value-of select="'#idno'"/>
                    </xsl:attribute>
                    <xsl:value-of select="'CMO[#-#]'"/>
                </xsl:element>
                <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="analog">
                            <xsl:value-of select="'edc'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth">
                            <xsl:value-of select="'MARC'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                        </xsl:attribute>
                        <xsl:value-of select="'Editor of Digital Corpus'"/>
                    </xsl:element>
                        <xsl:element name="corpName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'CMO'"/>
                            </xsl:attribute>
                            <xsl:attribute name="xml:lang">
                                <xsl:value-of select="'en'"/>
                            </xsl:attribute>
                            <xsl:value-of
                                select="
                                    'Corpus Musicae Ottomanicae, Research Center of the 
                            German Research Foundation at the University of Münster, Institute of
                            Musicology.'"
                            />
                        </xsl:element>
                </xsl:element>
                <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="analog">
                            <xsl:value-of select="'oth'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth">
                            <xsl:value-of select="'MARC'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                        </xsl:attribute>
                        <xsl:value-of select="'Cooperation Partners'"/>
                    </xsl:element>
                        <xsl:element name="corpName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'MWS'"/>
                            </xsl:attribute>
                            <xsl:attribute name="xml:lang">
                                <xsl:value-of select="'en'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'Max Weber Stiftung'"/>
                            <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="xml:base">
                                    <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                                </xsl:attribute>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="'GND'"/>
                                </xsl:attribute>
                                <xsl:value-of select="'1028661126'"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="corpName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'OII'"/>
                            </xsl:attribute>
                            <xsl:attribute name="xml:lang">
                                <xsl:value-of select="'en'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'Orient-Institut Istanbul'"/>
                        </xsl:element>
                </xsl:element>
                <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="analog">
                            <xsl:value-of select="'pdr'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth">
                            <xsl:value-of select="'MARC'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                        </xsl:attribute>
                        <xsl:value-of select="'Project Director'"/>
                    </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="'RJ'"/>
                        </xsl:attribute>
                        <xsl:element name="persName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:value-of select="'Ralf Martin Jäger'"/>
                        </xsl:element>
                        <xsl:element name="corpName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="'#CMO'"/>
                            </xsl:attribute>
                            <xsl:attribute name="startdate">
                                <xsl:value-of select="'2015-10'"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'GND'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'122654099'"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="analog">
                            <xsl:value-of select="'oth'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth">
                            <xsl:value-of select="'MARC'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                        </xsl:attribute>
                        <xsl:value-of select="'Research Assistant'"/>
                    </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="'ZH'"/>
                        </xsl:attribute>
                        <xsl:element name="persName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:value-of select="'Zeynep Helvacı'"/>
                        </xsl:element>
                        <xsl:element name="corpName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="'#CMO'"/>
                            </xsl:attribute>
                            <xsl:attribute name="startdate">
                                <xsl:value-of select="'2015-10'"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'GND'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'1080200312'"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="analog">
                            <xsl:value-of select="'edt'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth">
                            <xsl:value-of select="'MARC'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                        </xsl:attribute>
                        <xsl:value-of select="'Editors'"/>
                    </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="'NA'"/>
                        </xsl:attribute>
                        <xsl:element name="persName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:value-of select="'Nejla Melike Atalay'"/>
                        </xsl:element>
                        <xsl:element name="corpName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="'#CMO'"/>
                            </xsl:attribute>
                            <xsl:attribute name="startdate">
                                <xsl:value-of select="'2021-01'"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'GND'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'1244416428'"/>
                        </xsl:element>
                        <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'ND'"/>
                            </xsl:attribute>
                            <xsl:element name="persName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:value-of select="'Neslihan Demirkol'"/>
                            </xsl:element>
                            <xsl:element name="corpName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="'#CMO'"/>
                                </xsl:attribute>
                                <xsl:attribute name="startdate">
                                    <xsl:value-of select="'2019-09'"/>
                                </xsl:attribute>
                                <xsl:attribute name="enddate">
                                    <xsl:value-of select="'2024-05'"/>
                                </xsl:attribute>
                            </xsl:element>
                            <xsl:element name="identifier"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="xml:base">
                                    <xsl:value-of select="'https://orcid.org/'"/>
                                </xsl:attribute>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="'ORCID'"/>
                                </xsl:attribute>
                                <xsl:value-of select="'0000-0002-8602-1704'"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'SD'"/>
                            </xsl:attribute>
                            <xsl:element name="persName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:value-of select="'Salih Demirtaş'"/>
                            </xsl:element>
                            <xsl:element name="corpName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="'#CMO'"/>
                                </xsl:attribute>
                                <xsl:attribute name="startdate">
                                    <xsl:value-of select="'2015'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'MD'"/>
                            </xsl:attribute>
                            <xsl:element name="persName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:value-of select="'Marco Dimitriou'"/>
                            </xsl:element>
                            <xsl:element name="corpName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="'#CMO'"/>
                                </xsl:attribute>
                                <xsl:attribute name="startdate">
                                    <xsl:value-of select="'2015'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'CM'"/>
                            </xsl:attribute>
                            <xsl:element name="persName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:value-of select="'C. Ersin Mıhçı'"/>
                            </xsl:element>
                            <xsl:element name="corpName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="'#CMO'"/>
                                </xsl:attribute>
                                <xsl:attribute name="startdate">
                                    <xsl:value-of select="'2015'"/>
                                </xsl:attribute>
                                <xsl:attribute name="enddate">
                                    <xsl:value-of select="'2023'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'JO'"/>
                            </xsl:attribute>
                            <xsl:element name="persName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:value-of select="'Jacob Olley'"/>
                            </xsl:element>
                            <xsl:element name="corpName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="'#CMO'"/>
                                </xsl:attribute>
                                <xsl:attribute name="startdate">
                                    <xsl:value-of select="'2015'"/>
                                </xsl:attribute>
                                <xsl:attribute name="enddate">
                                    <xsl:value-of select="'2020'"/>
                                </xsl:attribute>
                            </xsl:element>
                            <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="xml:base">
                                    <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                                </xsl:attribute>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="'GND'"/>
                                </xsl:attribute>
                                <xsl:value-of select="'1129199630'"/>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'SP'"/>
                            </xsl:attribute>
                            <xsl:element name="persName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:value-of select="'Semih Pelen'"/>
                            </xsl:element>
                            <xsl:element name="corpName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="'#CMO'"/>
                                </xsl:attribute>
                                <xsl:attribute name="startdate">
                                    <xsl:value-of select="'2020'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="'NV'"/>
                            </xsl:attribute>
                            <xsl:element name="persName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:value-of select="'Nazlı Vatansever'"/>
                            </xsl:element>
                            <xsl:element name="corpName"
                                namespace="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="corresp">
                                    <xsl:value-of select="'#CMO'"/>
                                </xsl:attribute>
                                <xsl:attribute name="startdate">
                                    <xsl:value-of select="'2024-02'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="analog">
                            <xsl:value-of select="'led'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth">
                            <xsl:value-of select="'MARC'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                        </xsl:attribute>
                        <xsl:value-of
                            select="'Head of Section perspectivia.net, IT, Library Affairs'"/>
                    </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="'MK'"/>
                        </xsl:attribute>
                        <xsl:element name="persName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:value-of select="'Michael Kaiser'"/>
                        </xsl:element>
                        <xsl:element name="corpName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="'#MWS'"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'GND'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'139213147'"/>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://orcid.org/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'ORCID'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'0000-0001-9520-8119'"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="respStmt" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:element name="resp" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="analog">
                            <xsl:value-of select="'oth'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth">
                            <xsl:value-of select="'MARC'"/>
                        </xsl:attribute>
                        <xsl:attribute name="auth.uri">
                            <xsl:value-of select="'https://www.loc.gov/marc/relators/relacode.html'"/>
                        </xsl:attribute>
                        <xsl:value-of
                            select="'Research Managers Digital Editions and Data Management'"/>
                    </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="'SG'"/>
                        </xsl:attribute>
                        <xsl:element name="persName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:value-of select="'Sven Gronemeyer'"/>
                        </xsl:element>
                        <xsl:element name="corpName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="'#MWS'"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="corpName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:value-of select="'La Trobe University, Melbourne'"/>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'GND'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'1155600487'"/>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://orcid.org/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'ORCID'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'0000-0002-9066-0461'"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="'NRP'"/>
                        </xsl:attribute>
                        <xsl:element name="persName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:value-of select="'Nanette Rißler-Pipka'"/>
                        </xsl:element>
                        <xsl:element name="corpName"
                            namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="'#MWS'"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://explore.gnd.network/gnd/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'GND'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'130085154'"/>
                        </xsl:element>
                        <xsl:element name="identifier" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="xml:base">
                                <xsl:value-of select="'https://orcid.org/'"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'ORCID'"/>
                            </xsl:attribute>
                            <xsl:value-of select="'0000-0002-0719-9003'"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Application info EN/DE/TR -->

    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:apply-templates select="@* | *"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">sibmei_transform2cmo</xsl:attribute>
                <xsl:attribute name="isodate"><xsl:value-of select="current-dateTime()"/></xsl:attribute>
                <xsl:attribute name="type">xslt-script</xsl:attribute>
                <xsl:attribute name="version">2.0</xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>Document created by the CMO post-processing transformation routine to transform Sibelius MEI.cmn export into MEI.cmo.</xsl:text>
                </xsl:element>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Das Dokument wurde mit der CMO-Postprocessor-Transformation bearbeitet, um den Export von Sibelius MEI.cmn in MEI.cmo durchzuführen.</xsl:text>
                </xsl:element>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Sibelius MEI dışa aktarımını MEI.cmo formatına dönüştürmek üzere CMO işleme sonrası dönüştürme rutini tarafından oluşturulan belge.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>This file is the result of a MEI transformation of the </xsl:text><xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="target">https://github.com/music-encoding/sibmei</xsl:attribute><xsl:text>SibMEI plugin</xsl:text></xsl:element><xsl:text> that enhances regular MEI output from Sibelius with information relevant for Ottoman art music encoded in the MEI.cmo module.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>The transformation was created by </xsl:text><xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei"><xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="target">https://explore.gnd.network/gnd/1229022201</xsl:attribute><xsl:text>Dr. Anna Plaksin</xsl:text></xsl:element></xsl:element><xsl:text> and was enhanced by </xsl:text><xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="corresp">#SG</xsl:attribute><xsl:text>Dr. Sven Gronemeyer</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Diese Datei ist das Resultat einer MEI-Transformation des </xsl:text><xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="target">https://github.com/music-encoding/sibmei</xsl:attribute><xsl:text>SibMEI Plugin</xsl:text></xsl:element><xsl:text>, welches regulären MEI-Export von Sibelius mit Informationen anreichert, die relevant für osmanische Kunstmusik sind, die im MEI.cmo-Modul kodiert sind.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Die Transformation wurde erstellt von </xsl:text><xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei"><xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="target">https://explore.gnd.network/gnd/1229022201</xsl:attribute><xsl:text>Dr. Anna Plaksin</xsl:text></xsl:element></xsl:element><xsl:text> und wurde erweitert durch </xsl:text><xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="corresp">#SG</xsl:attribute><xsl:text>Dr. Sven Gronemeyer</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Bu dosya, Sibelius'un standart MEI çıktısını MEI.cmo modülünde kodlanmış Osmanlı sanat müziği ile ilgili bilgilerle zenginleştiren </xsl:text><xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="target">https://github.com/music-encoding/sibmei</xsl:attribute><xsl:text>SibMEI eklentisi</xsl:text></xsl:element><xsl:text>'nin MEI dönüştürme işleminin sonucudur.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Bu dönüşüm, </xsl:text><xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei"><xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="target">https://explore.gnd.network/gnd/1229022201</xsl:attribute><xsl:text>Dr. Anna Plaksin</xsl:text></xsl:element></xsl:element><xsl:text> tarafından oluşturulmuş ve </xsl:text><xsl:element name="persName" namespace="http://www.music-encoding.org/ns/mei"><xsl:attribute name="corresp">#SG</xsl:attribute><xsl:text>Dr. Sven Gronemeyer</xsl:text></xsl:element><xsl:text> tarafından genişletilmiştir.</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Project Description and Editorial Declaration -->
    <xsl:template match="mei:encodingDesc">
        <xsl:copy>
            <xsl:apply-templates select="@* | *"/>
            <xsl:element name="editorialDecl" namespace="http://www.music-encoding.org/ns/mei">
                <!-- Editorial Declaration EN -->
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>An explanation of the editorial process can be found in the </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://projects.academiccloud.de/projects/corpus-musicae-ottomanicae-cmo-public-wiki/wiki/1-workflows</xsl:attribute>
                        <xsl:text>editorial guidelines</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>A summary of the standardized terms of Ottoman music can be found in </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://uri.gbv.de/terminology/?search=CMO</xsl:attribute>
                        <xsl:text>controlled vocabularies</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>The true-type font VF OttoAneumatic to render Hampartsum notation can be found in this </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://repository.de.dariah.eu/1.0/dhcrud/21.11113/0000-000E-5CAE-8</xsl:attribute>
                        <xsl:text>compressed archive file to download</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <!-- Editorial Declaration DE -->
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Eine Erläuterung des Editionsprozesses finden Sie in den </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://projects.academiccloud.de/projects/corpus-musicae-ottomanicae-cmo-public-wiki/wiki/1-workflows</xsl:attribute>
                        <xsl:text>editorischen Leitlinien</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Eine Übersicht über die standardisierten Begriffe der osmanischen Musik findet sich in </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://uri.gbv.de/terminology/?search=CMO</xsl:attribute>
                        <xsl:text>kontrollierten Vokabularen</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Die True-Type-Schriftart VF OttoAneumatic zur Darstellung der Hampartsum-Notation kann in einem </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://repository.de.dariah.eu/1.0/dhcrud/21.11113/0000-000E-5CAE-8</xsl:attribute>
                        <xsl:text>komprimierten Archiv heruntergeladen werden</xsl:text></xsl:element><xsl:text>.</xsl:text>
                </xsl:element>
                <!-- Editorial Declaration TR -->
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Editoryal sürecin ayrıntılarına dair bilgileri </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://projects.academiccloud.de/projects/corpus-musicae-ottomanicae-cmo-public-wiki/wiki/1-workflows</xsl:attribute>
                        <xsl:text>editoryal yönergeler</xsl:text></xsl:element><xsl:text> sayfalarında bulabilirsiniz.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Osmanlı müziğine ait standartlaştırılmış terimlerin bir özeti, </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://uri.gbv.de/terminology/?search=CMO</xsl:attribute>
                        <xsl:text>kontrollü sözlüklerde</xsl:text></xsl:element><xsl:text> bulunabilir.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Hampartsum notasyonunu görüntülemek için kullanılan TrueType yazı tipi VF OttoAneumatic, bu </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://repository.de.dariah.eu/1.0/dhcrud/21.11113/0000-000E-5CAE-8</xsl:attribute>
                        <xsl:text>indirilebilir sıkıştırılmış arşiv dosyasında</xsl:text></xsl:element><xsl:text> bulunabilir.</xsl:text>
                </xsl:element>
            </xsl:element>
            <!-- Project description EN -->
            <xsl:element name="projectDesc" namespace="http://www.music-encoding.org/ns/mei">
                <!-- Project description EN -->
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>Corpus Musicae Ottomanicae (CMO) is a project funded by the </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.dfg.de</xsl:attribute>
                        <xsl:text>Deutsche Forschungsgemeinschaft</xsl:text>
                    </xsl:element>
                    <xsl:text> (DFG, German Research Foundation). The CMO project is carried out collaboratively across three locations: Münster and Bonn (both in Germany) and Istanbul (Turkey). Each center deals with a specific aspect of the project. The central research task – the transcription and critical editing of nineteenth-century sources of Ottoman music – is carried out at the </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de/Musikwissenschaft/</xsl:attribute>
                        <xsl:text>Institute for Musicology</xsl:text>
                    </xsl:element>
                    <xsl:text> at the </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de</xsl:attribute>
                        <xsl:text>University of Münster</xsl:text>
                    </xsl:element>
                    <xsl:text>. Critical editions of the accompanying texts of vocal pieces are prepared in collaboration with </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de/ArabistikIslam/</xsl:attribute>
                        <xsl:text>Institute of Arabic and Islamic Studies</xsl:text>
                    </xsl:element>
                    <xsl:text>, also at the </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de</xsl:attribute>
                        <xsl:text>University of Münster</xsl:text>
                    </xsl:element>
                    <xsl:text>. The project support and digital publication of the edition is undertaken jointly by associates based at the </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.maxweberstiftung.de/en/</xsl:attribute>
                        <xsl:text>Max Weber Foundation</xsl:text>
                    </xsl:element>
                    <xsl:text> in Bonn and the </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.oiist.org/en/</xsl:attribute>
                        <xsl:text>Orient-Institut Istanbul</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>For further information on the project, please visit the following page: </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://projects.academiccloud.de/projects/corpus-musicae-ottomanicae-cmo-public-wiki</xsl:attribute>
                        <xsl:text>Project Description</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:text>For an overview of the staff involved, please visit the following page: </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://corpus-musicae-ottomanicae.de/content/below/contributors.xml</xsl:attribute>
                        <xsl:text>Contributors</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <!-- Project description DE -->
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Corpus Musicae Ottomanicae (CMO) ist ein von der </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.dfg.de</xsl:attribute>
                        <xsl:text>Deutschen Forschungsgemeinschaft</xsl:text>
                    </xsl:element>
                    <xsl:text> finanziertes Projekt. Das CMO-Projekt wird in Zusammenarbeit an drei Standorten durchgeführt: Münster und Bonn (beide in Deutschland) und Istanbul (Türkei). Jedes Zentrum beschäftigt sich mit einem spezifischen Aspekt des Projekts. Die zentrale Forschungsaufgabe - die Transkription und kritische Edition von Quellen osmanischer Musik aus dem 19. Jahrhundert - wird am </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de/Musikwissenschaft/</xsl:attribute>
                        <xsl:text>Institut für Musikwissenschaft</xsl:text>
                    </xsl:element>
                    <xsl:text> der </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de</xsl:attribute>
                        <xsl:text>Universität Münster</xsl:text>
                    </xsl:element>
                    <xsl:text> durchgeführt. Kritische Editionen der Begleittexte von Vokalstücken werden in Zusammenarbeit mit dem </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de/ArabistikIslam/</xsl:attribute>
                        <xsl:text>Institut für Arabistik und Islamwissenschaft</xsl:text>
                    </xsl:element>
                    <xsl:text>, ebenfalls an der </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de</xsl:attribute>
                        <xsl:text>Universität Münster</xsl:text>
                    </xsl:element>
                    <xsl:text>, erstellt. Die Projektbegleitung und digitale Publikation der Ausgabe erfolgt gemeinsam mit Mitarbeitenden der </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.maxweberstiftung.de/</xsl:attribute>
                        <xsl:text>Max Weber Stiftung</xsl:text>
                    </xsl:element>
                    <xsl:text> in Bonn und des </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.oiist.org/en/</xsl:attribute>
                        <xsl:text>Orient-Instituts Istanbul</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Weitere Informationen zum Projekt finden Sie auf der folgenden Seite: </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://projects.academiccloud.de/projects/corpus-musicae-ottomanicae-cmo-public-wiki</xsl:attribute>
                        <xsl:text>Projektbeschreibung</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">de</xsl:attribute>
                    <xsl:text>Einen Überblick über die beteiligten Mitarbeitenden finden Sie auf der folgenden Seite: </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://corpus-musicae-ottomanicae.de/content/below/contributors.xml</xsl:attribute>
                        <xsl:text>Mitarbeitende</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <!-- Project description TR -->
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Corpus Musicae Ottomanicae (CMO), </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.dfg.de</xsl:attribute>
                        <xsl:text>Deutsche Forschungsgemeinschaft</xsl:text>
                    </xsl:element>
                    <xsl:text> (DFG, Alman Araştırma Vakfı) tarafından finanse edilen bir projedir. CMO projesi, Münster ve Bonn (her ikisi de Almanya’da) ile İstanbul (Türkiye) olmak üzere üç farklı merkezde işbirliği içinde yürütülmektedir. Her merkez, projenin belirli bir yönüyle ilgilenmektedir. Ana araştırma görevi olan 19. yüzyıl Osmanlı müzik kaynaklarının transkripsiyonu ve eleştirel edisyonu, </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de/Musikwissenschaft/</xsl:attribute>
                        <xsl:text>Müzikoloji Enstitüsü</xsl:text>
                    </xsl:element>
                    <xsl:text> (</xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de</xsl:attribute>
                        <xsl:text>Münster Üniversitesi</xsl:text>
                    </xsl:element>
                    <xsl:text>)'nde yürütülmektedir. Sözlü eserlere eşlik eden metinlerinin eleştirel edisyonları, </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de/ArabistikIslam/</xsl:attribute>
                        <xsl:text>Arap ve İslam Araştırmaları Enstitüsü</xsl:text>
                    </xsl:element>
                    <xsl:text> ile işbirliği içinde, yine </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.uni-muenster.de</xsl:attribute>
                        <xsl:text>Münster Üniversitesi</xsl:text>
                    </xsl:element>
                    <xsl:text>'nde hazırlanmaktadır. Bu edisyonun proje desteği ve dijital yayını, Bonn’daki </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.maxweberstiftung.de/en/</xsl:attribute>
                        <xsl:text>Max Weber Vakfı</xsl:text>
                    </xsl:element>
                    <xsl:text> ile </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://www.oiist.org/en/</xsl:attribute>
                        <xsl:text>Orient-Institut Istanbul</xsl:text>
                    </xsl:element>
                    <xsl:text>'da bulunan ortaklar tarafından yürütülmektedir.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Proje hakkında daha fazla bilgi için lütfen şu sayfayı ziyaret edin: </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://projects.academiccloud.de/projects/corpus-musicae-ottomanicae-cmo-public-wiki</xsl:attribute>
                        <xsl:text>Proje Tanımı</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
                <xsl:element name="p" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:lang">tr</xsl:attribute>
                    <xsl:text>Katkıda bulunan personele ilişkin genel bilgi için lütfen aşağıdaki sayfayı ziyaret edin: </xsl:text>
                    <xsl:element name="ref" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target">https://corpus-musicae-ottomanicae.de/content/below/contributors.xml</xsl:attribute>
                        <xsl:text>Katkıda bulunanlar</xsl:text>
                    </xsl:element>
                    <xsl:text>.</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!--<xsl:template match="mei:anchoredText[@label=$sectionName]"/>-->

    <!-- change vertical bracket symbols to marking labels for start and end points of <supplied> elements -->
    <!--<xsl:template match="mei:dir[mei:symbol/@type='suppliedBracketStart']"/>
    <xsl:template match="mei:dir[mei:symbol/@type='suppliedBracketEnd']"/>
        
    <xsl:template match="mei:layer[../following-sibling::mei:dir[mei:symbol/@type='suppliedBracketStart'] and ../@n='1']">
        <xsl:variable name="startBrackets" select="./../following-sibling::mei:dir[mei:symbol/@type='suppliedBracketStart']"/>
        <xsl:variable name="endBrackets" select="./../following-sibling::mei:dir[mei:symbol/@type='suppliedBracketEnd']"/>
        
        <xsl:variable name="startPoint" select="for $x in $startBrackets return substring($x/@startid,2)"/>
        <xsl:variable name="endPoint" select="for $x in $endBrackets return substring($x/@startid,2)"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="./*">
                <xsl:choose>
                    <!-\- note is referenced in startid of a start bracket -\->
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
                    <!-\- get referenced child elements -\->
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
    
    
    <!-\- clean vertical bracket lines from unused @endid -\->
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
     
    <!-\- case 3.2: start bracket in middle of measure and end bracket elsewhere (hopefully not in a following measure) -\->
    <!-\- add note information, if it is a start supply or end supply of a vertical bracket from a middle of a measure -\->
    <xsl:template match="node()[name() = 'note' or name() = 'rest'][ancestor::mei:staff[@n='1'] and ancestor::mei:measure[child::mei:line[@type='bracket']]]">
        <!-\- safe line for comparison -\->
        <xsl:variable name="line" select="./ancestor::mei:staff/following-sibling::mei:line[@type='bracket']"/>
        <!-\- get first note of melody staff -\->
        <xsl:variable name="start_melody" select="if (./parent::mei:layer/*[1]/name() = 'beam') then ./parent::mei:layer/mei:beam[1]/*[1] else ./parent::mei:layer[1]/*[1]"/>
        <!-\- get last note of melody staff -\->
        <xsl:variable name="end_melody" select="if (./parent::mei:layer/*[last()]/name() = 'beam') then ./parent::mei:layer/mei:beam[last()]/*[last()] else ./parent::mei:layer/*[last()]"/>
        
        
        <!-\- first, check if bracket is start or end of an insertion -\->
        <xsl:choose>
            <xsl:when test="$line/@label='start'">
                <!-\- run this part only when the start bracket is not attached to the first or the last note -\->
                <xsl:choose>
                    <xsl:when test="$start_melody/@xml:id != substring($line/@startid,2) and $end_melody/@xml:id != substring($line/@startid,2)">
                        <!-\- if start, then check position of referenced event within layer -\->
                        <xsl:choose>
                            <!-\- referenced event of bracket is start point -\->
                            <xsl:when test="./@xml:id = substring($line/@startid,2)">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*"/>
                                    <xsl:attribute name="label">
                                        <xsl:value-of select="'suppStart'"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="node()"/>
                                </xsl:copy>
                            </xsl:when>
                            <!-\- last event in layer is end point -\->
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
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$line/@label='end'">
                <!-\- if end, then check position of referenced event within layer -\->
                <!-\- but run this only, when the line is not attached to the start or the end note -\->
                <xsl:choose>
                    <xsl:when test="$start_melody/@xml:id != substring($line/@startid,2) and $end_melody/@xml:id != substring($line/@startid,2)">
                        <xsl:choose>
                            <!-\- referenced musical event is end point -\->
                            <xsl:when test="./@xml:id = substring($line/@startid,2)">
                                <xsl:copy>
                                    <xsl:apply-templates select="@*"/>
                                    <xsl:attribute name="label">
                                        <xsl:value-of select="'suppEnd'"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="node()"/>
                                </xsl:copy>
                            </xsl:when>
                            <!-\- first musical event in layer is start point -\->
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
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>    
            </xsl:when>
        </xsl:choose>
    </xsl:template>-->

    <!-- change @pname of usul staff into @label and @loc -->
    <xsl:template match="mei:note[ancestor::mei:staff/@n = '2']">
        <xsl:copy>
            <xsl:attribute name="label">
                <xsl:choose>
                    <xsl:when test="./@pname = 'g'">
                        <xsl:value-of select="'tek'"/>
                    </xsl:when>
                    <xsl:when test="./@pname = 'd'">
                        <xsl:value-of select="'düm'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="loc">
                <xsl:choose>
                    <xsl:when test="./@pname = 'g'">
                        <xsl:value-of select="'0'"/>
                    </xsl:when>
                    <xsl:when test="./@pname = 'd'">
                        <xsl:value-of select="'2'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- transform accid letter to glyph -->

    <xsl:template name="accid2glyph">
        <xsl:param name="accid"/>
        <xsl:choose>

            <!-- Koma sharp -->
            <xsl:when test="$accid = 'ks'">
                <xsl:value-of select="'U+E444'"/>
            </xsl:when>
            <!-- Koma flat -->
            <xsl:when test="$accid = 'kf'">
                <xsl:value-of select="'U+E443'"/>
            </xsl:when>
            <!-- Bakiye sharp -->
            <xsl:when test="$accid = 'bs'">
                <xsl:value-of select="'U+E445'"/>
            </xsl:when>
            <!-- Bakiye flat -->
            <xsl:when test="$accid = 'bf'">
                <xsl:value-of select="'U+E442'"/>
            </xsl:when>
            <!-- Küçük mücenneb sharp -->
            <xsl:when test="$accid = 'kms'">
                <xsl:value-of select="'U+E446'"/>
            </xsl:when>
            <!-- Küçük mücenneb flat -->
            <xsl:when test="$accid = 'kmf'">
                <xsl:value-of select="'U+E441'"/>
            </xsl:when>
            <!-- Büyük mücenneb sharp -->
            <xsl:when test="$accid = 'bms'">
                <xsl:value-of select="'U+E447'"/>
            </xsl:when>
            <!-- Büyük mücenneb flat -->
            <xsl:when test="$accid = 'bmf'">
                <xsl:value-of select="'U+E440'"/>
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

    <xsl:template name="addsource">
        <xsl:variable name="sourceLabel"
            select="normalize-space(//mei:anchoredText[@label = 'Source'])"/>
        <xsl:element name="source" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="//mei:anchoredText[@label = 'Source']/@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="label">
                <xsl:value-of select="$sourceLabel"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!-- copy every node in file -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>