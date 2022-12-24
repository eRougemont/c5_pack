<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  exclude-result-prefixes="tei" 
  >
  <xsl:import href="../vendor/oeuvres/xsl/tei_html/tei_toc_html.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" omit-xml-declaration="yes"/>
  <xsl:variable name="split" select="true()"/>
  <!-- Ne pas couper Nicolas de Flüe sur les actes -->
  <xsl:key name="split" match="
    tei:*[self::tei:div or self::tei:div1 or self::tei:div2][normalize-space(.) != ''][@type][
    contains(@type, 'article') 
    or contains(@type, 'chapter') 
    or contains(@subtype, 'split')
    or contains(@type, 'poem')
    or contains(@type, 'letter')
    ]
    " 
    use="generate-id(.)"/>
  <!-- No extension for links -->
  <xsl:variable name="_ext"/>
  <!-- prefix des liens -->
  <xsl:param name="bookname" select="/*/@xml:id"/>
  <xsl:variable name="base">
    <xsl:value-of select="$bookname"/>
    <xsl:text>/</xsl:text>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:call-template name="totoc"/>
  </xsl:template>
  
  <xsl:template name="totoc">
    <nav class="toc_details">
      <h2>Sommaire</h2>
      <xsl:apply-templates select="/*/tei:text/tei:front/* | /*/tei:text/tei:body/* | /*/tei:text/tei:group/* | /*/tei:text/tei:back/*" mode="tocsplit"/>
    </nav>
  </xsl:template>

  
  
  <!-- Identifiant local -->
  <xsl:template match="tei:div[@type = 'chapter']" mode="id">
    <xsl:number level="any" count="tei:div[@type = 'chapter']"/>
  </xsl:template>
</xsl:transform>