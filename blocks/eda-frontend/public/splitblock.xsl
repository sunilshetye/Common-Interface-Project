<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ext="http://exslt.org/common"
  exclude-result-prefixes="xsl ext">

  <!-- copy all other nodes {{{1 -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
  <!-- }}}1 -->

  <!-- keys {{{1 -->
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

  <xsl:key name="k-block" match="AfficheBlock | BasicBlock | BigSom | EventInBlock | EventOutBlock | ExplicitInBlock | ExplicitOutBlock | GroundBlock | ImplicitInBlock | ImplicitOutBlock | Product | RoundBlock | SplitBlock | Summation | SuperBlock | TextBlock | VoltageSensorBlock" use="@id" />
  <xsl:key name="k-port" match="ExplicitInputPort | ExplicitOutputPort | ControlPort | CommandPort | ImplicitInputPort | ImplicitOutputPort" use="@id" />
  <!-- }}}1 -->

  <!-- links template {{{1 -->
  <xsl:template name="links">

    <!-- links template parameters {{{ -->
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
    <xsl:param name="targetoneblockx" />
    <xsl:param name="targetoneblocky" />
    <xsl:param name="sourceoneblockx" />
    <xsl:param name="sourceoneblocky" />
    <xsl:param name="sourcetwoblockx" />
    <xsl:param name="sourcetwoblocky" />
    <xsl:param name="sourcethreeblockx" />
    <xsl:param name="sourcethreeblocky" />

    <!-- }}} -->

    <!-- generate new primary link one id {{{ -->
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
    <!-- }}} -->

    <!-- generate new primary link one {{{ -->
    <xsl:if test="$targetonelink/@id != '' and $sourceonelink/@id != ''">
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
          <mxPoint>
            <xsl:attribute name="x">
              <xsl:value-of select="$sourceoneblockx" />
            </xsl:attribute>
            <xsl:attribute name="y">
              <xsl:value-of select="$sourceoneblocky" />
            </xsl:attribute>
            <xsl:attribute name="as">sourcePoint</xsl:attribute>
          </mxPoint>
          <!-- targetPoint added by suchita -->
          <mxPoint>
            <xsl:attribute name="x">
              <xsl:value-of select="$targetoneblockx" />
            </xsl:attribute>
            <xsl:attribute name="y">
              <xsl:value-of select="$targetoneblocky" />
            </xsl:attribute>
            <xsl:attribute name="as">targetPoint</xsl:attribute>
          </mxPoint>
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
    <!-- }}} -->

    <!-- generate new primary link two id {{{ -->
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
    <!-- }}} -->

    <!-- generate new primary link three id {{{ -->
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
    <!-- }}} -->

    <!-- generate new primary link four id {{{ -->
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
    <!-- }}} -->

    <!-- generate new primary link two {{{ -->
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
        <mxPoint>
          <xsl:attribute name="x">
            <xsl:value-of select="$sourcetwoblockx" />
          </xsl:attribute>
          <xsl:attribute name="y">
            <xsl:value-of select="$sourcetwoblocky" />
          </xsl:attribute>
          <xsl:attribute name="as">targetPoint</xsl:attribute>
        </mxPoint>
        <Array as="points">
          <xsl:for-each select="$sourcetwowaypoints">
            <xsl:copy-of select="." />
          </xsl:for-each>
        </Array>
      </mxGeometry>
    </xsl:element>
    </xsl:if>
    <!-- }}} -->

    <!-- change source or target of secondary link: foreach loop, link copy, source change {{{ -->
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
    <!-- }}} -->

  </xsl:template>
  <!-- }}}1 -->

  <!-- SplitBlock template {{{1 -->
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

    <!-- set linktype (value) {{{ -->
    <xsl:variable name="linktype">
      <xsl:choose>
        <xsl:when test="count($InputPort) >= 1 and count($OutputPort) >= 2">ExplicitLink</xsl:when>
        <xsl:when test="count($ControlPort) >= 1 and count($CommandPort) >= 2">CommandControlLink</xsl:when>
        <xsl:when test="count($ImplicitPort) >= 3">ImplicitLink</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!-- }}} -->

    <!-- find ports connected to splitblock (value) {{{ -->
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
    <!-- }}} -->

    <!-- find links connected to ports connected to splitblock (node-set) {{{ -->
    <xsl:variable name="tmptargetonelink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="targetonelink" select="ext:node-set($tmptargetonelink)/links/*" />

    <xsl:variable name="tmpsourceonelink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourceonelink" select="ext:node-set($tmpsourceonelink)/links/*" />

    <xsl:variable name="tmpsourcetwolink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourcetwolink" select="ext:node-set($tmpsourcetwolink)/links/*" />

    <xsl:variable name="tmpsourcethreelink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourcethreelink" select="ext:node-set($tmpsourcethreelink)/links/*" />
    <!-- }}} -->

    <!-- find secondary links connected to links connected to ports connected to splitblock (node-set) {{{ -->
    <xsl:variable name="tmptargetonesrcsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="targetonesrcsecondlink" select="ext:node-set($tmptargetonesrcsecondlink)/links/*" />

    <xsl:variable name="tmptargetonetgtsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="targetonetgtsecondlink" select="ext:node-set($tmptargetonetgtsecondlink)/links/*" />

    <xsl:variable name="tmpsourceonesrcsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourceonesrcsecondlink" select="ext:node-set($tmpsourceonesrcsecondlink)/links/*" />

    <xsl:variable name="tmpsourceonetgtsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourceonetgtsecondlink" select="ext:node-set($tmpsourceonetgtsecondlink)/links/*" />

    <xsl:variable name="tmpsourcetwosrcsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourcetwosrcsecondlink" select="ext:node-set($tmpsourcetwosrcsecondlink)/links/*" />

    <xsl:variable name="tmpsourcetwotgtsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourcetwotgtsecondlink" select="ext:node-set($tmpsourcetwotgtsecondlink)/links/*" />

    <xsl:variable name="tmpsourcethreesrcsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourcethreesrcsecondlink" select="ext:node-set($tmpsourcethreesrcsecondlink)/links/*" />

    <xsl:variable name="tmpsourcethreetgtsecondlink">
      <links>
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
      </links>
    </xsl:variable>
    <xsl:variable name="sourcethreetgtsecondlink" select="ext:node-set($tmpsourcethreetgtsecondlink)/links/*" />
    <!-- }}} -->

    <!-- find other (tgt|src) ports connected to links connected to (src|tgt) ports connected to splitblock (value) {{{ -->
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

    <xsl:variable name="targetonelinkassort">
      <xsl:choose>
        <xsl:when test="$targetoneid = $targetonelink/@source">sourcePoint</xsl:when>
        <xsl:when test="$targetoneid = $targetonelink/@target">targetPoint</xsl:when>
        <xsl:otherwise>
          <xsl:text>No match found</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="targetoneportsort" select="key('k-port', $targetonelinksort)" />
    <xsl:variable name="targetoneblocksort" select="key('k-block', $targetoneportsort/@parent)" />
    <xsl:variable name="targetoneblockx">
      <xsl:choose>
        <xsl:when test="$targetonelink/mxGeometry/mxPoint[@as=$targetonelinkassort]">
          <xsl:value-of select="$targetonelink/mxGeometry/mxPoint[@as=$targetonelinkassort]/@x" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$targetoneblocksort/mxGeometry/@x" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="targetoneblocky" >
        <xsl:choose>
        <xsl:when test="$targetonelink/mxGeometry/mxPoint[@as=$targetonelinkassort]">
          <xsl:value-of select="$targetonelink/mxGeometry/mxPoint[@as=$targetonelinkassort]/@y" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$targetoneblocksort/mxGeometry/@y" />
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

    <xsl:variable name="sourceonelinkassort">
      <xsl:choose>
        <xsl:when test="$sourceoneid = $sourceonelink/@source">sourcePoint</xsl:when>
        <xsl:when test="$sourceoneid = $sourceonelink/@target">targetPoint</xsl:when>
        <xsl:otherwise>
          <xsl:text>No match found</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="sourceoneportsort" select="key('k-port', $sourceonelinksort)" />
    <xsl:variable name="sourceoneblocksort" select="key('k-block', $sourceoneportsort/@parent)" />
    <xsl:variable name="sourceoneblockx">
      <xsl:choose>
        <xsl:when test="$sourceonelink/mxGeometry/mxPoint[@as=$sourceonelinkassort]">
          <xsl:value-of select="$sourceonelink/mxGeometry/mxPoint[@as=$sourceonelinkassort]/@x" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$sourceoneblocksort/mxGeometry/@x" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="sourceoneblocky" >
        <xsl:choose>
        <xsl:when test="$sourceonelink/mxGeometry/mxPoint[@as=$sourceonelinkassort]">
          <xsl:value-of select="$sourceonelink/mxGeometry/mxPoint[@as=$sourceonelinkassort]/@y" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$sourceoneblocksort/mxGeometry/@y" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="sourcetwolinkassort">
      <xsl:choose>
        <xsl:when test="$sourcetwoid = $sourcetwolink/@source">sourcePoint</xsl:when>
        <xsl:when test="$sourcetwoid = $sourcetwolink/@target">targetPoint</xsl:when>
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

    <xsl:variable name="sourcetwoportsort" select="key('k-port', $sourcetwolinksort)" />
    <xsl:variable name="sourcetwoblocksort" select="key('k-block', $sourcetwoportsort/@parent)" />
    <xsl:variable name="sourcetwoblockx">
      <xsl:choose>
        <xsl:when test="$sourcetwolink/mxGeometry/mxPoint[@as=$sourcetwolinkassort]">
          <xsl:value-of select="$sourcetwolink/mxGeometry/mxPoint[@as=$sourcetwolinkassort]/@x" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$sourcetwoblocksort/mxGeometry/@x" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="sourcetwoblocky" >
        <xsl:choose>
        <xsl:when test="$sourcetwolink/mxGeometry/mxPoint[@as=$sourcetwolinkassort]">
          <xsl:value-of select="$sourcetwolink/mxGeometry/mxPoint[@as=$sourcetwolinkassort]/@y" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$sourcetwoblocksort/mxGeometry/@y" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="sourcethreelinkassort">
      <xsl:choose>
        <xsl:when test="$sourcethreeid = $sourcethreelink/@source">sourcePoint</xsl:when>
        <xsl:when test="$sourcethreeid = $sourcethreelink/@target">targetPoint</xsl:when>
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

    <xsl:variable name="sourcethreeportsort" select="key('k-port', $sourcethreelinksort)" />
    <xsl:variable name="sourcethreeblocksort" select="key('k-block', $sourcethreeportsort/@parent)" />
    <xsl:variable name="sourcethreeblockx">
      <xsl:choose>
        <xsl:when test="$sourcethreelink/mxGeometry/mxPoint[@as=$sourcethreelinkassort]">
          <xsl:value-of select="$sourcethreelink/mxGeometry/mxPoint[@as=$sourcethreelinkassort]/@x" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$sourcethreeblocksort/mxGeometry/@x" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="sourcethreeblocky" >
        <xsl:choose>
        <xsl:when test="$sourcethreelink/mxGeometry/mxPoint[@as=$sourcethreelinkassort]">
          <xsl:value-of select="$sourcethreelink/mxGeometry/mxPoint[@as=$sourcethreelinkassort]/@y" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$sourcethreeblocksort/mxGeometry/@y" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- }}} -->

    <!-- find waypoints of links connected to ports connected to splitblock (node-set) {{{ -->
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
    <!-- }}} -->

    <!-- call the template {{{ -->
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
      <xsl:with-param name="targetoneblockx" select="$targetoneblockx" />
      <xsl:with-param name="targetoneblocky" select="$targetoneblocky" />
      <xsl:with-param name="sourceoneblockx" select="$sourceoneblockx" />
      <xsl:with-param name="sourceoneblocky" select="$sourceoneblocky" />
      <xsl:with-param name="sourcetwoblockx" select="$sourcetwoblockx" />
      <xsl:with-param name="sourcetwoblocky" select="$sourcetwoblocky" />
      <xsl:with-param name="sourcethreeblockx" select="$sourcethreeblockx" />
      <xsl:with-param name="sourcethreeblocky" select="$sourcethreeblocky" />

    </xsl:call-template>
    <!-- }}} -->

  </xsl:template>
  <!-- }}}1 -->

  <!-- Port template {{{1 -->
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
  <!-- }}}1 -->

  <!-- Link template {{{1 -->
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
  <!-- }}}1 -->

</xsl:stylesheet>
