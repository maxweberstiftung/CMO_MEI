<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:xsldoc="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs math"
    version="3.0">
    <!-- copy every node in file -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsldoc:doc>
        <xsldoc:desc>Contains sanity checks for sibmei output.</xsldoc:desc>
    </xsldoc:doc>
</xsl:stylesheet>