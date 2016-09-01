<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- adding application info -->
    <xsl:template match="mei:appInfo">
        <xsl:copy>
            <xsl:copy-of select="*"/>
            <xsl:element name="application" namespace="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="xml:id">
                    <xsl:text>measure_2_sections</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="isodate">
                    <xsl:value-of select="current-dateTime()"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:text>xslt-script</xsl:text>
                </xsl:attribute>
                <xsl:element name="name" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:text>CMO measure to section transformation prototype</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- convert measures into sections -->
    <xsl:template match="mei:measure">
        <xsl:element name="section" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:copy-of select="@xml:id"/>
            <xsl:copy-of select="@n"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- add several dirs and ties to referenced note -->
    <!--<xsl:template match="mei:note">
        <xsl:variable name="note_id" select="@xml:id"/>
        <xsl:variable name="id_ref" select="concat('#', $note_id)"/>
        <xsl:if test="./parent::mei:layer">
            <xsl:if test="./ancestor::mei:measure/mei:dir/@startid = $id_ref">
                <xsl:variable name="dir_start" select="./ancestor::mei:measure/mei:dir[@startid = $id_ref]"/>
                set group start before note 
                <xsl:if test="$dir_start/mei:symbol/@type = 'group_start'">
                    <xsl:copy-of select="$dir_start"></xsl:copy-of>
                </xsl:if>    
                
            </xsl:if>
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
            <xsl:if test="./ancestor::mei:measure/mei:dir/@startid = $id_ref">
                <xsl:variable name="dir_end" select="./ancestor::mei:measure/mei:dir[@startid = $id_ref]"/>
                set group start before note 
                <xsl:if test="$dir_end/mei:symbol/@type = 'group_end'">
                    <xsl:copy-of select="$dir_end"></xsl:copy-of>
                </xsl:if>    
                
            </xsl:if>
            add tie behind starting note 
            case 1: note within layer 
            <xsl:if test="./ancestor::mei:measure/mei:tie/@startid = $id_ref and ./parent::mei:layer">
                <xsl:copy-of select="./ancestor::mei:measure/mei:tie[@startid = $id_ref]"/>
            </xsl:if>
        </xsl:if>
        
    </xsl:template>-->
        
    <!-- add tie into layer, case 2: tie between notes of chords -->
    <xsl:template match="mei:chord">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
        <xsl:for-each select="./mei:note">
            <xsl:variable name="note_ref" select="concat('#',@xml:id)"/>
            <xsl:if test="./ancestor::mei:measure/mei:tie/@startid = $note_ref">
                <xsl:copy-of select="./ancestor::mei:measure/mei:tie[@startid = $note_ref]"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- prevent non valid ties to be in output -->
    <xsl:template match="mei:tie"/>
    
    <!-- surpress invalid directions -->
    <xsl:template match="mei:dir[mei:symbol/@type = 'group_start']"/>
    <xsl:template match="mei:dir[mei:symbol/@type = 'group_end']"/>
    <xsl:template match="mei:dir[mei:symbol/@type = 'HampSubDivision']"/>
    <xsl:template match="mei:dir[mei:symbol/@type = 'HampEndCycle']"/>
    <xsl:template match="mei:dir[mei:symbol/@type = 'suppliedBracketStart']"/>
    <xsl:template match="mei:dir[mei:symbol/@type = 'suppliedBracketEnd']"/>
    <!-- there is a template for each type of direction to prevent loss of information and get an invalid document instead -->
    
    <!-- add barlines and dirs to layer -->
    <xsl:template match="mei:layer">
        <xsl:variable name="dirs" select="./ancestor-or-self::mei:measure/mei:dir"/>
        <xsl:variable name="notes" select=".//mei:note"/>
        <xsl:variable name="rests" select=".//mei:rest"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="./ancestor::mei:measure/@left">
                <xsl:element name="barLine" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="form">
                        <xsl:value-of select="./ancestor::mei:measure/@left"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:for-each select="$dirs">
                <xsl:variable name="dir" select="."/>
                <xsl:for-each select="$notes">
                    <xsl:variable name="note_id" select="concat('#',./@xml:id)"/>
                    <xsl:if test="$note_id = $dir/@startid">
                        <xsl:copy-of select="$dir"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$rests">
                    <xsl:variable name="rest_id" select="concat('#',./@xml:id)"/>
                    <xsl:if test="$rest_id = $dir/@startid">
                        <xsl:copy-of select="$dir"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:if test="./ancestor::mei:measure/@right">
                <xsl:element name="barLine" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="form">
                        <xsl:value-of select="./ancestor::mei:measure/@right"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
        
    </xsl:template>
    
    <!-- copy every node in file -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>