<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei" 
  >
  <xsl:import href="../vendor/oeuvres/xsl/tei_html/tei_toc_html.xsl"/>
  <xsl:import href="../vendor/oeuvres/xsl/tei_html/tei_flow_html.xsl"/>
  <xsl:import href="../vendor/oeuvres/xsl/tei_html/tei_notes_html.xsl"/>
  <xsl:param name="srcdir"/>
  <!-- Pour indentation -->
  <xsl:strip-space elements="*" />
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
  <!-- Fixé par l’appelant -->
  <xsl:variable name="id"/>
  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <html>
      <head>
        <meta charset="UTF-8" />
        <title>Articles de Rougemont</title>
        <link rel="stylesheet" type="text/css" href="../static/vendor/sortable.css" />
        <link rel="stylesheet" type="text/css" href="../static/rougemont.css" />
        <script>const relup = "../../"; </script>
      </head>
      <body class="chapter">
        <header id="header">
          <div id="top"> </div>
        </header>
        <main>
          <header>
            Articles
          </header>
          <table class="sortable">
            <thead>
              <tr>
                <th>Date</th>
                <th>Titre</th>
                <th>Revue</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="/*/file">
                <xsl:variable name="name" select="substring-before(., '.')"/>
                <xsl:for-each select="document(concat($srcdir, .))">
                  <tr>
                    <td class="date">
                      <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@when"/>
                    </td>
                    <td class="title">
                      <a href="{$name}.html">
                        <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/node()"/>
                      </a>
                    </td>
                    <td class="journal">
                      <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title[@level='j']/node()"/>
                    </td>
                  </tr>
                </xsl:for-each>
              </xsl:for-each>
            </tbody>
          </table>
        </main>
        <a href="#" id="gotop">▲</a>
        <footer id="footer">
          <div id="bottom"></div>
        </footer>
        <script src="../static/js/common.js">//</script>
        <script src="../static/vendor/sortable.js">//</script>
      </body>
    </html>
  </xsl:template>
  
  
</xsl:transform>