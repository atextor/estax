<?xml version="1.0" encoding="UTF-8"?>
<!-- Estax (Easy Static XML) Version 1.0            -->
<!-- Andreas Textor <textor.andreas@googlemail.com> -->
<!-- See http://kantico.de/texray/estax.xhtml       -->

<xsl:stylesheet
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:redirect="http://xml.apache.org/xalan/redirect"
		xmlns:dt="http://xsltsl.org/date-time"
		xmlns:str="http://xsltsl.org/string"
		extension-element-prefixes="dt str redirect"
		version="1.0">
	<!-- XSLT Standard library -->
	<xsl:import href="string.xsl"/>
	<xsl:import href="date-time.xsl"/>

	<!-- Set output options -->
	<xsl:output
			method="xml"
			version="1.0"
			indent="yes"
			encoding="UTF-8"
			doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
			doctype-public="-//W3C//DTD XHTML 1.1//EN"/>

	<xsl:param name="outdir"/>

	<xsl:key name="distinctTags" match="//@tag" use="."/>
	<xsl:key name="distinctLanguages" match="//@language" use="."/>

	<!-- ############################################# -->
	<!-- Static Templates                              -->
	<!-- ############################################# -->

	<!-- Creates the filename to write for a tag -->
	<xsl:template name="tagOutFilename">
		<xsl:param name="tag"/>
		<xsl:value-of select="concat($outdir,'/',$tag,'.xhtml')"/>
	</xsl:template>

	<!-- Creates the filename to link for a tag -->
	<xsl:template name="tagFilename">
		<xsl:param name="tag"/>
		<xsl:value-of select="concat($tag,'.xhtml')"/>
	</xsl:template>

	<!-- Creates an XHTML page for a tag. -->
	<xsl:template name="buildPage">
		<xsl:param name="tag"/>
		<xsl:param name="title"/>
		<xsl:param name="site"/>
		<xsl:variable name="filename">
			<xsl:call-template name="tagOutFilename">
				<xsl:with-param name="tag" select="$tag"/>
			</xsl:call-template>
		</xsl:variable>

		<redirect:write select="$filename">
			<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de">
				<head>
					<xsl:if test="$site/@stylesheet">
						<xsl:element name="link">
							<xsl:attribute name="type">text/css</xsl:attribute>
							<xsl:attribute name="rel">stylesheet</xsl:attribute>
							<xsl:attribute name="href">
								<xsl:value-of select="$site/@stylesheet"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$site//listing">
						<xsl:element name="link">
							<xsl:attribute name="type">text/css</xsl:attribute>
							<xsl:attribute name="rel">stylesheet</xsl:attribute>
							<xsl:attribute name="href">
								<xsl:value-of select="concat('sh_', $site/@codestyle, '.css')"/>
							</xsl:attribute>
						</xsl:element>
						<xsl:element name="script">
							<xsl:attribute name="type">text/javascript</xsl:attribute>
							<xsl:attribute name="src">sh_main.js</xsl:attribute>
							<xsl:text> </xsl:text>
						</xsl:element>
						<xsl:for-each select="$site//@language[generate-id() = generate-id(key('distinctLanguages',.))]">
							<xsl:element name="script">
								<xsl:attribute name="type">text/javascript</xsl:attribute>
								<xsl:attribute name="src">
									<xsl:value-of select="concat('sh_', ., '.js')"/>
								</xsl:attribute>
								<xsl:text> </xsl:text>
							</xsl:element>
						</xsl:for-each>
					</xsl:if>
					<xsl:element name="meta">
						<xsl:attribute name="name">Description</xsl:attribute>
						<xsl:attribute name="content">
							<xsl:value-of select="$site/@description"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="meta">
						<xsl:attribute name="name">Keywords</xsl:attribute>
						<xsl:attribute name="content">
							<xsl:value-of select="$site/@keywords"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:if test="$site/@favicon">
						<xsl:element name="link">
							<xsl:attribute name="rel">shortcut icon</xsl:attribute>
							<xsl:attribute name="type">image/x-icon</xsl:attribute>
							<xsl:attribute name="href">
								<xsl:value-of select="$site/@favicon"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:if>
					<meta name="MSSmartTagsPreventParsing" content="TRUE" />
					<meta http-equiv="imagetoolbar" content="no" />
					<meta http-equiv="Content-Type" content="application/xhtml+xml;charset=UTF-8" />
					<title>
						<xsl:value-of select="$title"/>
					</title>
				</head>
				<body>
					<xsl:if test="$site//listing">
						<xsl:attribute name="onload">
							<xsl:text>sh_highlightDocument();</xsl:text>
						</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="$site/header"/>
					<xsl:apply-templates select="$site/menu">
						<xsl:with-param name="tag" select="$tag"/>
					</xsl:apply-templates>
					<div id="content">
						<xsl:call-template name="siteContent">
							<xsl:with-param name="tag">
								<xsl:value-of select="$tag"/>
							</xsl:with-param>
							<xsl:with-param name="site" select="$site"/>
						</xsl:call-template>
					</div>
					<xsl:apply-templates select="$site/footer"/>
				</body>
			</html>
		</redirect:write>
	</xsl:template>

	<!-- Creates a tag cloud. -->
	<xsl:template name="tagcloud">
		<xsl:param name="site"/>
		<xsl:variable name="totaltags">
			<xsl:value-of select="count($site//@tag)"/>
		</xsl:variable>

		<xsl:for-each select="$site//@tag[generate-id() = generate-id(key('distinctTags',.))]">
			<xsl:sort data-type="text" order="ascending"/>
			<xsl:variable name="thistag">
				<xsl:value-of select="."/>
			</xsl:variable>
			<xsl:variable name="filename">
				<xsl:call-template name="tagFilename">
					<xsl:with-param name="tag" select="."/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="occurences">
				<xsl:value-of select="count($site//box//tag[@tag = $thistag]/@tag)"/>
			</xsl:variable>
			<xsl:variable name="sze">
				<xsl:value-of select="ceiling(($occurences div $totaltags * 30) + 1)"/>
			</xsl:variable>
			<xsl:variable name="size">
				<xsl:choose>
					<xsl:when test="$sze &lt;= 10">
						<xsl:value-of select="$sze"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="10"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:element name="a">
				<xsl:attribute name="class">
					<xsl:value-of select="concat('cloudtag',$size)"/>
				</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="$filename"/>
					</xsl:attribute>
					<xsl:value-of select="."/>
			</xsl:element>
			<xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:template>

	<!-- Creates the actual content for a site, based on the site tag -->
	<xsl:template name="siteContent">
		<xsl:param name="tag"/>
		<xsl:param name="site"/>
		<xsl:for-each select="$site//box[@id or ./tag/@tag=$tag]">
			<xsl:sort select="@date" order="descending"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>

	<!-- This removes tabs in listings, so that no additional leading
		tabs appear in the resulting <pre> elements. Tabs that are part of the
		listing itself won't be modified. -->
	<xsl:template name="tab-replace">
		<xsl:param name="word"/>
		<!-- Generate to string to be replaced by concatenating the tab entity
			(length of path to this node) - 1 times. -->
		<xsl:variable name="cr">
			<xsl:text>&#x0A;</xsl:text>
			<xsl:call-template name="str:generate-string">
				<xsl:with-param name="text">
					<xsl:text>&#x09;</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="count" select="count(ancestor::node()) - 1"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($word,$cr)">
				<xsl:value-of select="substring-before($word,$cr)"/>
				<xsl:text>&#x0A;</xsl:text>
				<xsl:call-template name="tab-replace">
					<xsl:with-param name="word" select="substring-after($word,$cr)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$word"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ############################################# -->
	<!-- Dynamic Templates                             -->
	<!-- ############################################# -->

	<!-- Keep XHTML tags from the source xml -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()|text()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Builds the div for a box -->
	<xsl:template match="box">
		<xsl:variable name="box" select="."/>

		<xsl:element name="div">
			<xsl:attribute name="class">box</xsl:attribute>
			<xsl:if test="$box/@id">
				<xsl:attribute name="id">
					<xsl:value-of select="@id"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="@title">
				<div class="boxtitle">
					<span class="title">
						<xsl:value-of select="@title"/>
					</span>
					<xsl:if test="@date">
						<span class="date">
							<xsl:call-template name="dt:format-date-time">
								<xsl:with-param name="year" select="substring(@date,1,4)"/>
								<xsl:with-param name="month" select="substring(@date,6,2)"/>
								<xsl:with-param name="day" select="substring(@date,9,2)"/>
								<xsl:with-param name="format">
									<xsl:choose>
										<xsl:when test="../@dateformat">
											<xsl:value-of select="../@dateformat"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="'%Y-%m-%d'"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:call-template>
						</span>
					</xsl:if>
				</div>
			</xsl:if>

			<xsl:apply-templates select="content"/>

			<xsl:if test="not(@hidetags = 'true') and count(./tag) >= 1">
				<div class="boxtags">
					<xsl:text>Tags: </xsl:text>
					<xsl:for-each select="$box/tag">
						<xsl:sort select="./@tag" data-type="text" order="ascending"/>
						<xsl:variable name="tag" select="./@tag"/>
						<xsl:variable name="filename">
							<xsl:call-template name="tagFilename">
								<xsl:with-param name="tag" select="$tag"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:element name="span">
							<xsl:attribute name="class">
								<!--<xsl:value-of select="concat('tag-',$tag)"/>-->
								<xsl:text>tag</xsl:text>
							</xsl:attribute>
							<xsl:element name="a">
								<xsl:attribute name="href">
									<xsl:value-of select="$filename"/>
								</xsl:attribute>
							<xsl:value-of select="@tag"/>
							</xsl:element>
						</xsl:element>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</div>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- Copies the content of boxes, including transformation of contained tags -->
	<xsl:template match="content">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Root template for the site element. Calls the buildPage template for
		 each distinct tag found in the site. -->
	<xsl:template match="site">
		<xsl:variable name="site" select="."/>
		<xsl:for-each select="//@tag[generate-id() = generate-id(key('distinctTags',.))]">
			<xsl:sort data-type="text" order="ascending"/>
			<xsl:call-template name="buildPage">
				<xsl:with-param name="tag" select="."/>
				<xsl:with-param name="title">
					<xsl:value-of select="$site/@title"/>
					<xsl:text> - </xsl:text>
					<xsl:call-template name="str:capitalise">
						<xsl:with-param name="text" select="."/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="site" select="$site"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Create the footer -->
	<xsl:template match="footer">
		<div id="footer">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<!-- Create the header -->
	<xsl:template match="header">
		<div id="header">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<!-- Quote text -->
	<xsl:template match="q">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<!-- Create a space -->
	<xsl:template match="space">
		<xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
	</xsl:template>

	<!-- Creates a tag cloud -->
	<xsl:template match="tagcloud">
		<xsl:call-template name="tagcloud">
			<xsl:with-param name="site" select="/"/>
		</xsl:call-template>
	</xsl:template>

	<!-- Generate a listing, with leading tabs (from the markup formatting,
		not those that are part of the actual listing) removed -->
	<xsl:template match="listing">
		<pre>
			<xsl:if test="@language">
				<xsl:attribute name="class">
					<xsl:text>sh_</xsl:text>
					<xsl:value-of select="@language"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="tab-replace">
			<xsl:with-param name="word" select="."/>
			</xsl:call-template>
		</pre>
	</xsl:template>

	<!-- Create a link to a tag page -->
	<xsl:template match="link">
		<xsl:param name="tag"/>
		<xsl:param name="depth"/>
		<xsl:element name="a">
			<xsl:attribute name="href">
				<xsl:variable name="filename">
					<xsl:call-template name="tagFilename">
						<xsl:with-param name="tag" select="@tag"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$filename"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="@caption">
					<xsl:value-of select="@caption"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="str:capitalise">
						<xsl:with-param name="text" select="@tag"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<!-- Build possible submenu -->
		<xsl:if test="./menu">
			<xsl:apply-templates select="menu">
				<xsl:with-param name="depth" select="$depth"/>
				<xsl:with-param name="tag" select="$tag"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<!-- Create the link menu -->
	<xsl:template match="menu">
		<xsl:param name="tag"/>
		<xsl:param name="depth"/>

		<xsl:element name="div">
			<xsl:attribute name="class">
				<xsl:text>menu</xsl:text>
				<xsl:if test="$depth">
					<xsl:value-of select="$depth"/>
				</xsl:if>
			</xsl:attribute>

			<ul class="menulist">
				<xsl:for-each select="link">
					<xsl:element name="li">
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test=".//@tag = $tag">
									<xsl:text>selected</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>unselected</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:apply-templates select=".">
							<xsl:with-param name="depth">
								<xsl:choose>
									<xsl:when test="$depth">
										<xsl:value-of select="$depth + 1"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="0"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="tag" select="$tag"/>
						</xsl:apply-templates>
					</xsl:element>
				</xsl:for-each>
			</ul>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>

