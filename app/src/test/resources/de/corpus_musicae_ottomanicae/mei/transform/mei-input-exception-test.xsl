<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:template match="node()">
        <xsl:message terminate="yes" error-code="MeiInputError">
            <context>test context</context>
            <message>test message</message>
        </xsl:message>
    </xsl:template>
</xsl:transform>