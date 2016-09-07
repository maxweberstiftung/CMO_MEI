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
        <xsl:apply-templates select="node()" />
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
        <xsl:copy>
            <xsl:apply-templates select="@n"/>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="@lines"/>
            <xsl:apply-templates select="@clef.shape"/>
            <xsl:apply-templates select="@clef.line"/>
            <xsl:choose>
                <xsl:when test="@label = 'KS Uşşak'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Uşşak</xsl:text>
                        </xsl:attribute>
                        <!-- b4 loc 4 &e442; -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Acem aşiran'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Acem aşiran</xsl:text>
                        </xsl:attribute>
                        <!-- b4 loc 4 &e441; -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E441</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Mahur'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Mahur</xsl:text>
                        </xsl:attribute>
                        <!-- f5 loc 8 &e446; -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Nişabur'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Nişabur</xsl:text>
                        </xsl:attribute>
                        <!-- C5 loc 5 &e446; -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Büzürk'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Büzürk</xsl:text>
                        </xsl:attribute>
                        <!-- f5 loc 8 &e444; -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Rast'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Rast</xsl:text>
                        </xsl:attribute>
                        <!-- b4 loc 4 &e442; -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- f5 loc 8 &e444; -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Saba'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Saba</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    <!-- b4 loc 4 &e442; -->
                    <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="glyphnum">
                            <xsl:text>U+E442</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:text>4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:text>b</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:text>4</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    <!-- d5 loc 6 &e441; -->
                    <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="glyphnum">
                            <xsl:text>U+E441</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:text>6</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:text>d</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:text>5</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label ='KS Nihavend'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Nihavend</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E441 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E441</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- E5 loc 7 U+E441 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E441</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>7</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>e</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Hicaz'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Hicaz</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- C5 loc 5 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Nişaburek'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Nişaburek</xsl:text>
                        </xsl:attribute>
                        <!-- C5 loc 5 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Güldeste'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Güldeste</xsl:text>
                        </xsl:attribute>
                        <!-- D5 loc 6 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>d</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Tarz-ı nevin'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Tarz-ı nevin</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E441 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E441</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- D5 loc 6 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>d</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Ferahnak'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Ferahnak</xsl:text>
                        </xsl:attribute>
                        <!-- C5 loc 5 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E444 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Uzzal'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Uzzal</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    <!-- B4 loc 4 U+E442 -->
                    <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="glyphnum">
                            <xsl:text>U+E442</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:text>4</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:text>b</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:text>4</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    <!-- F5 loc 8 U+E444 -->
                    <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="glyphnum">
                            <xsl:text>U+E444</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:text>8</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:text>f</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:text>5</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    <!-- C5 loc 5 U+E446 -->
                    <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="glyphnum">
                            <xsl:text>U+E446</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:text>5</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:text>c</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:text>5</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Suznak'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Suznak</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- E5 loc 7 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>7</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>e</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E444 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Kürdili hicazkar'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Kürdili hicazkar</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E441 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E441</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- E5 loc 7 U+E441 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E441</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>7</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>e</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- A4 loc 3 U+E441 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E441</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>3</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>a</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Suz-i dil'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Suz-i dil</xsl:text>
                        </xsl:attribute>
                        <!-- F5 loc 8 U+E444 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- G5 loc 9 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>9</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>g</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- D5 loc 6 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>6</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>d</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Revnaknüma'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Revnaknüma</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- C5 loc 5 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- A4 loc 3 U+E445 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E445</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>3</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>a</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Hicazkar'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Hicazkar</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- E5 loc 7 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>7</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>e</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- A4 loc 3 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>3</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>a</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E444 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Şedaraban'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Şedaraban</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- E5 loc 7 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>7</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>e</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- C5 loc 5 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E444 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Şehnaz'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Şehnaz</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E444 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- C5 loc 5 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- G5 loc 9 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>9</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>g</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@label = 'KS Evcara'">
                    <xsl:element name="keySig" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="label">
                            <xsl:text>KS Evcara</xsl:text>
                        </xsl:attribute>
                        <!-- B4 loc 4 U+E442 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E442</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>b</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>4</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- F5 loc 8 U+E444 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E444</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>8</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>f</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- C5 loc 5 U+E446 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="glyphnum">
                                <xsl:text>U+E446</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loc">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="pname">
                                <xsl:text>c</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="oct">
                                <xsl:text>5</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <!-- E5 loc 7 U+E445 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="glyphnum">
                            <xsl:text>U+E445</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:text>7</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:text>e</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:text>5</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                        <!-- A4 loc 3 U+E445 -->
                        <xsl:element name="keyAccid" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="glyphnum">
                            <xsl:text>U+E445</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="loc">
                            <xsl:text>3</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="pname">
                            <xsl:text>a</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="oct">
                            <xsl:text>4</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    
                </xsl:otherwise>
            </xsl:choose>
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
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    
    
</xsl:stylesheet>