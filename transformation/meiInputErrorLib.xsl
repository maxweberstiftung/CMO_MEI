<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="3.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:mei="http://www.music-encoding.org/ns/mei"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:template mode="context-info" match="element()">
        <xsl:variable name="elementInfo" select="concat(local-name(), ' element ', @xml:id)"/>
        <xsl:variable name="divisionInfo" select="ancestor-or-self::mei:measure[1]/(@label, @n)/concat(', division number ', .)"/>
        <xsl:value-of select="concat($elementInfo, $divisionInfo)"/>
    </xsl:template>

    <xsl:template mode="mei-input-error" match="element()">
        <xsl:param name="message" as="xs:string"/>
        <xsl:message terminate="yes" error-code="MeiInputError">
            <context>
                <xsl:apply-templates select="." mode="context-info"/>
            </context>
            <message>
                <xsl:value-of select="$message"/>
            </message>
        </xsl:message>
    </xsl:template>
</xsl:transform>