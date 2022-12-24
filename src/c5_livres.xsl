<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

  exclude-result-prefixes="tei">
  <xsl:import href="../vendor/oeuvres/xsl/tei_html/tei_toc_html.xsl"/>
  <xsl:import href="../vendor/oeuvres/xsl/tei_html/tei_flow_html.xsl"/>
  <xsl:import href="../vendor/oeuvres/xsl/tei_html/tei_notes_html.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" omit-xml-declaration="no"/>
  <xsl:param name="bookpath"/>
  <xsl:param name="package"/>
  <xsl:variable name="split" select="true()"/>
  <xsl:key name="split" match="tei:div[@type='chapter']" use="generate-id(.)"/>
  <!-- No extension for links -->
  <xsl:variable name="_ext"/>
  <xsl:variable name="bibl">
    <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/node()"/>
  </xsl:variable>
  

  
  <xsl:template match="/" priority="10">
    <concrete5-cif version="1.0">
      <pages>
        <xsl:choose>
          <xsl:when test="//tei:div[@type='chapter']">
            <xsl:for-each select="//tei:div[@type='chapter']">
              <xsl:call-template name="chapter"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="//tei:body">
              <xsl:call-template name="chapter"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </pages>
    </concrete5-cif>
  </xsl:template>
  
  <xsl:template name="chapter">
    <xsl:variable name="chapid">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <!--
    <xsl:variable name="title">
      <xsl:variable name="rich">
        <xsl:copy-of select="$doctitle"/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$docdate"/>
        <xsl:text>) </xsl:text>
        <xsl:for-each select="ancestor-or-self::*">
          <xsl:sort order="descending" select="position()"/>
          <xsl:choose>
            <xsl:when test="self::tei:TEI"/>
            <xsl:when test="self::tei:text"/>
            <xsl:when test="self::tei:body"/>
            <xsl:otherwise>
              <xsl:if test="position() != 1"> — </xsl:if>
              <xsl:apply-templates mode="title" select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    -->
    <xsl:variable name="name">
      <xsl:variable name="rich">
        <xsl:apply-templates select="." mode="title"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    <page path="{$bookpath}/{$chapid}" name="{$name}" searchable="1" indexed="1" package="{$package}" template="liseuse" pagetype="liseuse">
      <attributes>
        <attributekey handle="doctype">
          <value>Chapter</value>
        </attributekey>
        <!--  TODO ?
        <attributekey handle="bookid">
          <value>
            <xsl:value-of select="$bookid"/>
          </value>
        </attributekey>
        -->
        <attributekey handle="meta_title">
          <value>
            <xsl:value-of select="$name"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$docdate"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$doctitle"/>
            <xsl:text>)</xsl:text>
          </value>
        </attributekey>
        <attributekey handle="meta_ld">
          <value>
{
  "@context": "https://schema.org/",
  "@type": "BreadcrumbList",
  "itemListElement": [{
    "@type": "ListItem",
    "position": 1,
    "name": "Rougemont",
    "item": {
      "@id": "https://www.unige.ch/rougemont/",
      "@type": "Person"
    }
  },{
    "@type": "ListItem",
    "position": 2,
    "name": "<xsl:value-of select="$doctitle"/> (<xsl:value-of select="$docdate"/>)",
    "item": {
      "@id": "https://www.unige.ch/rougemont<xsl:value-of select="$bookpath"/>",
      "@type": "Book"
    }
  },{
    "@type": "ListItem",
    "position": 3,
    "name": "<xsl:value-of select="$name"/>"
  }]
}
          </value>
        </attributekey>
        <xsl:if test="tei:div">
          <attributekey handle="meta_description">
            <value>
              <xsl:for-each select=".//tei:div">
                <xsl:variable name="subhead">
                  <xsl:call-template name="title"/>
                </xsl:variable>
                <xsl:value-of select="normalize-space($subhead)"/>
                <xsl:if test="position() != last()"> – </xsl:if>
              </xsl:for-each>
            </value>
          </attributekey>
          <attributekey handle="subheads">
            <value>
              <xsl:apply-templates mode="subhead"/>
            </value>
          </attributekey>
        </xsl:if>
      </attributes>
      <area name="Main">
        <blocks>
          <block type="content">
            <data table="btContentLocal">
              <record>
                <content>
                  <article role="article">
                    
                    <xsl:call-template name="div-header">
                      <xsl:with-param name="level" select="1"/>
                    </xsl:call-template>
                    <footer>
                      <xsl:call-template name="footnotes"/>
                    </footer>
                  </article>
                </content>
              </record>
            </data>
          </block>
        </blocks>
      </area>
      <area name="Sidebar">
        <blocks>
          <block type="content" name="">
            <data table="btContentLocal">
              <record>
                <content>
                  <xsl:choose>
                    <!-- un seul chapitre -->
                    <xsl:when test="//tei:body[count(tei:div) = 1]">
                      <ol>
                        <xsl:apply-templates select="/*/tei:text/tei:body/tei:div/*" mode="toclocal">
                          <xsl:with-param name="localid" select="generate-id()"/>
                        </xsl:apply-templates>
                      </ol>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="toclocal"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </content>
              </record>
            </data>
          </block>
        </blocks>
      </area>
    </page>
  </xsl:template>
  
  
  <!-- Should be only iniside another chapter -->
  <xsl:template match="tei:div[@type='chapter']"/>
  <xsl:template match="tei:div[@type='chapter']" mode="copynote"/>
  <xsl:template match="tei:div[@type='chapter']" mode="fn"/>

  <xsl:template match="text()" mode="subhead"/>
  <xsl:template match="*" mode="subhead">
    <xsl:apply-templates mode="subhead"/>
  </xsl:template>
  <xsl:template match="tei:div[@type='chapter']" mode="subhead"/>
  <xsl:template match="tei:div" mode="subhead">
    <xsl:variable name="subhead">
      <xsl:call-template name="title"/>
    </xsl:variable>
    <xsl:call-template name="id"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="normalize-space($subhead)"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="$docdate"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$doctitle"/>
    <xsl:text>)</xsl:text>
    <xsl:value-of select="$lf"/>
  </xsl:template> 

  <!-- Identifiant local -->
  <xsl:template match="tei:div[@type = 'chapter']" mode="id">
    <xsl:number level="any" count="tei:div[@type = 'chapter']"/>
  </xsl:template>

  <xsl:template match="tei:body" mode="id">
    <xsl:text>1</xsl:text>
  </xsl:template>
  
  
  <!-- a prev/next navigation -->
  <xsl:template name="prevnext">
    <nav class="prevnext">
      <div class="prev">
        <xsl:for-each select="preceding::*[@type='chapter'][1]">
          <xsl:variable name="title">
            <xsl:call-template name="title"/>
          </xsl:variable>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="normalize-space($title)"/>
            </xsl:attribute>
            <xsl:copy-of select="$title"/>
          </a>
        </xsl:for-each>
        <xsl:text> </xsl:text>
      </div>
      <div class="next">
        <xsl:text> </xsl:text>
        <xsl:for-each select="following::*[@type='chapter'][1]">
          <xsl:variable name="title">
            <xsl:call-template name="title"/>
          </xsl:variable>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="normalize-space($title)"/>
            </xsl:attribute>
            <xsl:copy-of select="$title"/>
          </a>
        </xsl:for-each>
      </div>
    </nav>
  </xsl:template>
</xsl:transform>
