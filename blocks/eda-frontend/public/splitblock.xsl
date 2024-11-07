<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ext="http://exslt.org/common"
  exclude-result-prefixes="xsl ext"
>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:key name="k-input" match="ExplicitInputPort" use="@parent" />
    <xsl:key name="k-output" match="ExplicitOutputPort" use="@parent" />
    <xsl:key name="k-link" match="ExplicitLink" use="@source | @target" />
    <xsl:key name="k-srclink" match="ExplicitLink" use="@source" />
    <xsl:key name="k-tgtlink" match="ExplicitLink" use="@target" />

    <xsl:key name="k-control" match="ControlPort" use="@parent" />
    <xsl:key name="k-command" match="CommandPort" use="@parent" />
    <xsl:key name="k-commandlink" match="CommandControlLink" use="@source | @target" />
    <xsl:key name="k-commandsrclink" match="CommandControlLink" use="@source" />
    <xsl:key name="k-commandtgtlink" match="CommandControlLink" use="@target" />

    <xsl:key name="k-implicitinput" match="ImplicitInputPort | ImplicitOutputPort" use="@parent" />
    <xsl:key name="k-implicitlink" match="ImplicitLink" use="@source | @target" />
    <xsl:key name="k-implicitsrclink" match="ImplicitLink" use="@source" />
    <xsl:key name="k-implicittgtlink" match="ImplicitLink" use="@target" />

    <xsl:template name="links">
      <xsl:param name="linktype" />
      <xsl:param name="targetonelink" />
      <xsl:param name="targetonelinksrcortgt" />
      <xsl:param name="sourceonelink" />
      <xsl:param name="sourceonelinksrcortgt" />
      <xsl:param name="sourcetwolink" />
      <xsl:param name="sourcetwolinksrcortgt" />
      <xsl:param name="sourcethreelink" />
      <xsl:param name="sourcethreelinksrcortgt" />
      <xsl:param name="targetonesrcsecondlink" />
      <xsl:param name="targetonetgtsecondlink" />
      <xsl:param name="sourceonesrcsecondlink" />
      <xsl:param name="sourceonetgtsecondlink" />
      <xsl:param name="sourcetwosrcsecondlink" />
      <xsl:param name="sourcetwotgtsecondlink" />
      <xsl:param name="sourcethreesrcsecondlink" />
      <xsl:param name="sourcethreetgtsecondlink" />
      <xsl:param name="targetonewaypoints" />
      <xsl:param name="sourceonewaypoints" />
      <xsl:param name="sourcetwowaypoints" />
      <xsl:param name="x" />
      <xsl:param name="y" />
      <xsl:param name="parent" />

      <!-- generate new primary link one id -->
      <xsl:variable name="newidone">
        <xsl:choose>
          <xsl:when test="$targetonelink/@id != '' and $sourceonelink/@id != ''">
            <xsl:value-of select="concat($targetonelink/@id, generate-id())" />
          </xsl:when>
          <xsl:when test="$targetonelink/@id != ''">
            <xsl:value-of select="$targetonelink/@id" />
          </xsl:when>
          <xsl:when test="$sourceonelink/@id != ''">
            <xsl:value-of select="$sourceonelink/@id" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No match found</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    
      <xsl:if test="$targetonelink/@id != '' and $sourceonelink/@id != ''">
        <!-- generate new primary link one -->
        <xsl:element name="{$linktype}">
          <xsl:attribute name="id">
            <xsl:value-of select="$newidone" />
          </xsl:attribute>
          <xsl:attribute name="parent">
            <xsl:value-of select="$parent" />
          </xsl:attribute>
          <xsl:attribute name="source">
            <xsl:value-of select="$targetonelinksrcortgt" /> <!-- removed by suchita $targetonelink/@source-->
          </xsl:attribute>
          <xsl:attribute name="target">
            <xsl:value-of select="$sourceonelinksrcortgt" /> <!-- removed by suchita sourceonelink/@target-->
          </xsl:attribute>
          <xsl:attribute name="style">
            <xsl:value-of select="$linktype" />
          </xsl:attribute>
          <xsl:attribute name="value"></xsl:attribute>
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <xsl:for-each select="$targetonewaypoints">
                <xsl:copy-of select="." />
              </xsl:for-each>
              <xsl:for-each select="$sourceonewaypoints">
                <xsl:copy-of select="." />
              </xsl:for-each>
            </Array>
            <xsl:for-each select="$targetonelink/mxGeometry/mxPoint">
              <xsl:copy>
                <xsl:copy-of select="@*" />
              </xsl:copy>
            </xsl:for-each>
          </mxGeometry>
        </xsl:element>
      </xsl:if>
      

      <!-- generate new primary link two id -->
      <xsl:variable name="newidtwo">
        <xsl:choose>
          <xsl:when test="($targetonelink/@id != '' or $sourceonelink/@id != '') and $sourcetwolink/@id != ''">
            <xsl:value-of select="concat($sourcetwolink/@id, generate-id($sourcetwolink))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No match found</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="newidthree">
        <xsl:choose>
          <xsl:when test="$targetonelink/@id != '' and $sourceonelink/@id != ''">
            <xsl:value-of select="$newidone" />
          </xsl:when>
          <xsl:when test="$targetonelink/@id != ''">
            <xsl:value-of select="$targetonelinksrcortgt" />
          </xsl:when>
          <xsl:when test="$sourceonelink/@id != ''">
            <xsl:value-of select="$sourceonelinksrcortgt" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No match found</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="newidfour">
        <xsl:choose>
          <xsl:when test="$targetonelink/@id != '' and $sourceonelink/@id != ''">
            <xsl:value-of select="$newidone" />
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$newidtwo" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- generate new primary link two -->
      <xsl:if test="$newidthree != 'No match found' and $sourcetwolink/@id != ''">
      <xsl:element name="{$linktype}">
        <xsl:attribute name="id">
          <xsl:value-of select="$newidtwo" />
        </xsl:attribute>
        <xsl:attribute name="parent">
          <xsl:value-of select="$parent" />
        </xsl:attribute>
        <xsl:attribute name="source">
          <xsl:value-of select="$newidthree" />
        </xsl:attribute>
        <xsl:attribute name="target">
          <xsl:value-of select="$sourcetwolinksrcortgt" />
        </xsl:attribute>
        <xsl:attribute name="style">
          <xsl:value-of select="$linktype" />
        </xsl:attribute>
        <xsl:attribute name="value"></xsl:attribute>
        <mxGeometry relative="1" as="geometry">
          <mxPoint>
            <xsl:attribute name="x">
              <xsl:value-of select="$x" />
            </xsl:attribute>
            <xsl:attribute name="y">
              <xsl:value-of select="$y" />
            </xsl:attribute>
            <xsl:attribute name="as">sourcePoint</xsl:attribute>
          </mxPoint>
          <Array as="points">
            <xsl:for-each select="$sourcetwowaypoints">
              <xsl:copy-of select="." />
            </xsl:for-each>
          </Array>
        </mxGeometry>
      </xsl:element>
      </xsl:if>
      <!-- change source or target of secondary link -->
      <!-- foreach loop, link copy, source change -->
      <xsl:for-each select="$targetonesrcsecondlink">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:attribute name="source">
            <xsl:value-of select="$newidfour" />
          </xsl:attribute>
          <xsl:copy-of select="node()" />
        </xsl:copy>
      </xsl:for-each>
      <xsl:for-each select="$targetonetgtsecondlink">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:attribute name="target">
            <xsl:value-of select="$newidfour" />
          </xsl:attribute>
          <xsl:copy-of select="node()" />
        </xsl:copy>
      </xsl:for-each>
      <xsl:for-each select="$sourceonesrcsecondlink">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:attribute name="source">
            <xsl:value-of select="$newidfour" />
          </xsl:attribute>
          <xsl:copy-of select="node()" />
        </xsl:copy>
      </xsl:for-each>
      <xsl:for-each select="$sourceonetgtsecondlink">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:attribute name="target">
            <xsl:value-of select="$newidfour" />
          </xsl:attribute>
          <xsl:copy-of select="node()" />
        </xsl:copy>
      </xsl:for-each>
      <xsl:for-each select="$sourcetwosrcsecondlink">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:attribute name="source">
            <xsl:value-of select="$newidtwo" />
          </xsl:attribute>
          <xsl:copy-of select="node()" />
        </xsl:copy>
      </xsl:for-each>
      <xsl:for-each select="$sourcetwotgtsecondlink">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:attribute name="target">
            <xsl:value-of select="$newidtwo" />
          </xsl:attribute>
          <xsl:copy-of select="node()" />
        </xsl:copy>
      </xsl:for-each>
    </xsl:template>

    <xsl:template match="/XcosDiagram/mxGraphModel/root/SplitBlock[position() = 1]">
      <xsl:variable name="InputPort" select="key('k-input', @id)" />
      <xsl:variable name="OutputPort" select="key('k-output', @id)" />

      <xsl:variable name="ControlPort" select="key('k-control', @id)" />
      <xsl:variable name="CommandPort" select="key('k-command', @id)" />

      <xsl:variable name="ImplicitPort" select="key('k-implicitinput', @id)" />

      <xsl:variable name="geometry" select="mxGeometry" />
      <xsl:variable name="x" select="$geometry/@x" />
      <xsl:variable name="y" select="$geometry/@y" />
      <xsl:variable name="parent" select="@parent" />
      <xsl:variable name="linktype">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">ExplicitLink</xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">CommandControlLink</xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">ImplicitLink</xsl:when>
      </xsl:choose>
      </xsl:variable>
      <!-- find ports connected to splitblock (value) -->
      <xsl:variable name="targetoneid">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:value-of select="$InputPort[position()=1]/@id" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:value-of select="$ControlPort[position()=1]/@id" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:value-of select="$ImplicitPort[position()=1]/@id" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourceoneid">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:value-of select="$OutputPort[position()=1]/@id" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:value-of select="$CommandPort[position()=1]/@id" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:value-of select="$ImplicitPort[position()=2]/@id" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcetwoid">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:value-of select="$OutputPort[position()=2]/@id" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:value-of select="$CommandPort[position()=2]/@id" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:value-of select="$ImplicitPort[position()=3]/@id" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcethreeid">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:value-of select="$OutputPort[position()=3]/@id" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:value-of select="$CommandPort[position()=3]/@id" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:value-of select="$ImplicitPort[position()=4]/@id" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <!-- find links connected to ports connected to splitblock (node-set) -->
      <xsl:variable name="targetonelink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-link', $targetoneid)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandlink', $targetoneid)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitlink', $targetoneid)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourceonelink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-link', $sourceoneid)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandlink', $sourceoneid)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitlink', $sourceoneid)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcetwolink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-link', $sourcetwoid)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandlink', $sourcetwoid)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitlink', $sourcetwoid)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcethreelink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-link', $sourcethreeid)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandlink', $sourcethreeid)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitlink', $sourcethreeid)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <!-- find secondary links connected to links connected to ports connected to splitblock (node-set) -->
      <xsl:variable name="targetonesrcsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-srclink', $targetonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandsrclink', $targetonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $targetonelink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="targetonetgtsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-tgtlink', $targetonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandtgtlink', $targetonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $targetonelink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourceonesrcsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-srclink', $sourceonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandsrclink', $sourceonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $sourceonelink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourceonetgtsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-tgtlink', $sourceonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandtgtlink', $sourceonelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $sourceonelink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcetwosrcsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-srclink', $sourcetwolink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandsrclink', $sourcetwolink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $sourcetwolink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcetwotgtsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-tgtlink', $sourcetwolink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandtgtlink', $sourcetwolink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $sourcetwolink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcethreesrcsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-srclink', $sourcethreelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandsrclink', $sourcethreelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $sourcethreelink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcethreetgtsecondlink">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">
        <xsl:copy-of select="key('k-tgtlink', $sourcethreelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">
        <xsl:copy-of select="key('k-commandtgtlink', $sourcethreelink/@id)" />
        </xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">
        <xsl:copy-of select="key('k-implicitsrclink', $sourcethreelink/@id)" />
        </xsl:when>
      </xsl:choose>
      </xsl:variable>

      <!-- find other (tgt|src) ports connected to links connected to (src|tgt) ports connected to splitblock (value) -->
      <xsl:variable name="targetonelinksort">
        <xsl:choose>
          <xsl:when test="$targetoneid = $targetonelink/@source">
            <xsl:value-of select="$targetonelink/@target" />
          </xsl:when>
          <xsl:when test="$targetoneid = $targetonelink/@target">
            <xsl:value-of select="$targetonelink/@source" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No match found</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourceonelinksort">
        <xsl:choose>
          <xsl:when test="$sourceoneid = $sourceonelink/@source">
            <xsl:value-of select="$sourceonelink/@target" />
          </xsl:when>
          <xsl:when test="$sourceoneid = $sourceonelink/@target">
            <xsl:value-of select="$sourceonelink/@source" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No match found</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcetwolinksort">
        <xsl:choose>
          <xsl:when test="$sourcetwoid = $sourcetwolink/@source">
            <xsl:value-of select="$sourcetwolink/@target" />
          </xsl:when>
          <xsl:when test="$sourcetwoid = $sourcetwolink/@target">
            <xsl:value-of select="$sourcetwolink/@source" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No match found</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="sourcethreelinksort">
        <xsl:choose>
          <xsl:when test="$sourcethreeid = $sourcethreelink/@source">
            <xsl:value-of select="$sourcethreelink/@target" />
          </xsl:when>
          <xsl:when test="$sourcethreeid = $sourcethreelink/@target">
            <xsl:value-of select="$sourcethreelink/@source" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No match found</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- find waypoints of links connected to ports connected to splitblock (node-set) -->
          <xsl:variable name="tmptargetonewaypoints">
            <waypoints>
              <xsl:choose>
                <xsl:when test="$targetoneid = $targetonelink/@source">
                  <xsl:for-each select="$targetonelink/mxGeometry/Array/mxPoint">
                    <xsl:sort select="position()" order="descending"/>
                    <xsl:copy-of select="."/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$targetoneid = $targetonelink/@target">
                  <xsl:copy-of select="$targetonelink/mxGeometry/Array/mxPoint" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>No match found</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </waypoints>
          </xsl:variable>
          <xsl:variable name="targetonewaypoints" select="ext:node-set($tmptargetonewaypoints)/waypoints/mxPoint" />

          <xsl:variable name="tmpsourceonewaypoints">
            <waypoints>
              <xsl:choose>
                <xsl:when test="$sourceoneid = $sourceonelink/@target">
                  <xsl:for-each select="$sourceonelink/mxGeometry/Array/mxPoint">
                    <xsl:sort select="position()" order="descending"/>
                    <xsl:copy-of select="."/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$sourceoneid = $sourceonelink/@source">
                  <xsl:copy-of select="$sourceonelink/mxGeometry/Array/mxPoint" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>No match found</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </waypoints>
          </xsl:variable>
          <xsl:variable name="sourceonewaypoints" select="ext:node-set($tmpsourceonewaypoints)/waypoints/mxPoint" />

          <xsl:variable name="tmpsourcetwowaypoints">
            <waypoints>
              <xsl:choose>
                <xsl:when test="$sourcetwoid = $sourcetwolink/@target">
                  <xsl:for-each select="$sourcetwolink/mxGeometry/Array/mxPoint">
                    <xsl:sort select="position()" order="descending"/>
                    <xsl:copy-of select="."/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$sourcetwoid = $sourcetwolink/@source">
                  <xsl:copy-of select="$sourcetwolink/mxGeometry/Array/mxPoint" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>No match found</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </waypoints>
          </xsl:variable>
          <xsl:variable name="sourcetwowaypoints" select="ext:node-set($tmpsourcetwowaypoints)/waypoints/mxPoint" />

      <xsl:call-template name="links">
            <xsl:with-param name="linktype" select="$linktype" />
            <xsl:with-param name="targetonelink" select="$targetonelink" />
            <xsl:with-param name="targetonelinksrcortgt" select="$targetonelinksort" />
            <xsl:with-param name="sourceonelink" select="$sourceonelink" />
            <xsl:with-param name="sourceonelinksrcortgt" select="$sourceonelinksort" />
            <xsl:with-param name="sourcetwolink" select="$sourcetwolink" />
            <xsl:with-param name="sourcetwolinksrcortgt" select="$sourcetwolinksort" />
            <xsl:with-param name="sourcethreelink" select="$sourcethreelink" />
            <xsl:with-param name="sourcethreelinksrcortgt" select="$sourcethreelinksort" />
            <xsl:with-param name="targetonesrcsecondlink" select="$targetonesrcsecondlink" />
            <xsl:with-param name="targetonetgtsecondlink" select="$targetonetgtsecondlink" />
            <xsl:with-param name="sourceonesrcsecondlink" select="$sourceonesrcsecondlink" />
            <xsl:with-param name="sourceonetgtsecondlink" select="$sourceonetgtsecondlink" />
            <xsl:with-param name="sourcetwosrcsecondlink" select="$sourcetwosrcsecondlink" />
            <xsl:with-param name="sourcetwotgtsecondlink" select="$sourcetwotgtsecondlink" />
            <xsl:with-param name="sourcethreesrcsecondlink" select="$sourcethreesrcsecondlink" />
            <xsl:with-param name="sourcethreetgtsecondlink" select="$sourcethreetgtsecondlink" />
            <xsl:with-param name="targetonewaypoints" select="$targetonewaypoints" />
            <xsl:with-param name="sourceonewaypoints" select="$sourceonewaypoints" />
            <xsl:with-param name="sourcetwowaypoints" select="$sourcetwowaypoints" />
            <xsl:with-param name="x" select="$x" />
            <xsl:with-param name="y" select="$y" />
            <xsl:with-param name="parent" select="$parent" />
          </xsl:call-template>
    </xsl:template>

    <xsl:template match="ExplicitInputPort | ExplicitOutputPort | ImplicitInputPort | ImplicitOutputPort | ControlPort | CommandPort">
      <xsl:variable name="parentId" select="@parent" />
      <xsl:variable name="SPLIT" select="/XcosDiagram/mxGraphModel/root/SplitBlock[position() = 1]" />

      <xsl:if test="$parentId != $SPLIT/@id">
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:copy-of select="node()" />
        </xsl:copy>
      </xsl:if>
    </xsl:template>

    <xsl:template match="ExplicitLink | CommandControlLink | ImplicitLink">
      <xsl:variable name="sourceId" select="@source" />
      <xsl:variable name="sourceElement" select="//*[@id = $sourceId]" />
      <xsl:variable name="sourceElemId" select="$sourceElement/@parent" />
      <xsl:variable name="targetId" select="@target" />
      <xsl:variable name="targetElement" select="//*[@id = $targetId]" />
      <xsl:variable name="targetElemId" select="$targetElement/@parent" />
      <xsl:variable name="SPLITID" select="/XcosDiagram/mxGraphModel/root/SplitBlock[position() = 1]/@id" />

      <xsl:if test="$sourceElemId != $SPLITID and $targetElemId != $SPLITID">
        <xsl:variable name="tgtsrcid" select="//*[@id = $targetElement/@source]/@parent" />
        <xsl:variable name="srctgtid" select="//*[@id = $sourceElement/@target]/@parent" />
        <xsl:variable name="srcsrcid" select="//*[@id = $sourceElement/@source]/@parent" />
        <xsl:variable name="tgttgtid" select="//*[@id = $targetElement/@target]/@parent" />

        <xsl:if test="(string-length($tgtsrcid) = 0 or $tgtsrcid != $SPLITID) and (string-length($tgttgtid) = 0 or $tgttgtid != $SPLITID) and (string-length($srctgtid) = 0 or $srctgtid != $SPLITID) and (string-length($srcsrcid) = 0 or $srcsrcid != $SPLITID)">
          <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:copy-of select="node()" />
          </xsl:copy>
        </xsl:if>
      </xsl:if>
    </xsl:template>
</xsl:stylesheet>
