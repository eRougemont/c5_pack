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
  <!-- No extension for links -->
  <xsl:variable name="_ext"/>
  <xsl:variable name="title_j">
    <xsl:apply-templates select="//title[@level='j'][1]" mode="title"/>
  </xsl:variable>
  <xsl:template match="/" priority="10">
    <concrete5-cif version="1.0">
      <pages>
        <xsl:for-each select="//tei:div[@type='letter']">
          <xsl:call-template name="letter"/>
        </xsl:for-each>
      </pages>
    </concrete5-cif>
  </xsl:template>
  <xsl:template name="letter">
    <xsl:variable name="divid">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <xsl:variable name="name">
      <xsl:variable name="rich">
        <xsl:apply-templates select="." mode="title"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    <xsl:variable name="meta_title">
      <xsl:variable name="rich">
        <xsl:apply-templates select="tei:head" mode="title"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    <page path="{$bookpath}/{$divid}" name="{$name}" package="{$package}" searchable="1" indexed="1" template="liseuse" pagetype="liseuse">
      <attributes>
        <attributekey handle="doctype">
          <value>Lettre</value>
        </attributekey>
        <attributekey handle="meta_title">
          <value>
            <xsl:value-of select="$meta_title"/>
          </value>
        </attributekey>
      </attributes>
      <area name="Main">
        <blocks>
          <block type="content">
            <data table="btContentLocal">
              <record>
                <content>
                  <article>
                    <xsl:apply-templates>
                      <xsl:with-param name="level" select="1"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="footnotes">
                      <!--
                      <xsl:with-param name="pb" select="NONODE"/>
                      -->
                    </xsl:call-template>
                  </article>
                </content>
              </record>
            </data>
          </block>
        </blocks>
      </area>
      <area name="Sidebar">
        <blocks>
          <block type="autonav" name="autonav">
            <data table="btNavigation">
              <record>
                <orderBy>display_asc</orderBy>
                <displayPages>current</displayPages>
                <displayPagesCID/>
                <displayPagesIncludeSelf>0</displayPagesIncludeSelf>
                <displaySubPages>none</displaySubPages>
                <displaySubPageLevels>enough</displaySubPageLevels>
                <displaySubPageLevelsNum>0</displaySubPageLevelsNum>
                <displayUnavailablePages>0</displayUnavailablePages>
              </record>
            </data>
          </block>
        </blocks>
      </area>
    </page>
  </xsl:template>
  <!-- numéro de note par chapitre -->
  <xsl:template name="note-n">
    <xsl:variable name="resp" select="@resp"/>
    <xsl:choose>
      <xsl:when test="@resp='editor'">
        <xsl:number count="tei:note[@resp=$resp]" format="a" from="tei:div[@type='letter' or @type='article' or @type='chapter']" level="any"/>
      </xsl:when>
      <xsl:when test="@resp">
        <xsl:number count="tei:note[@resp=$resp]" from="tei:div[@type='letter' or @type='article' or @type='chapter']" level="any"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number count="tei:note[not(@resp) and not(@rend) and not(@place='margin') and not(parent::tei:div) and not(parent::tei:notesStmt)]" from="tei:div[@type='article']" level="any"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Identifiant local -->
  <xsl:template match="tei:div[@type = 'letter']" mode="id">
    <xsl:value-of select="substring-after(substring-after(@xml:id, 'ddr-'), '-')"/>
  </xsl:template>
</xsl:transform>
