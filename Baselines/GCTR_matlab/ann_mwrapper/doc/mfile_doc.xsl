<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:template match="/">
        <html>
            <!-- Header -->
            <head>
                <title>
                    MATLAB-Doc of <xsl:value-of select="MFileInfo/@mname"/>
                </title>
                <link rel="stylesheet" type="text/css" href="../mfile_doc.css" /> 
            </head>
            <!-- Body  -->
            <body>                
                <!-- Navigation -->
                <xsl:apply-templates select="MFileInfo/Context"/>
                <!-- Title -->
                <h1 class="mname"><xsl:value-of select="MFileInfo/@mname"/></h1>                
                <!-- Document -->                
                <xsl:apply-templates select="MFileInfo/MDoc"/>                
                <!-- Foot Node -->
                <hr></hr>
                <p>Generated with the Matlab Doc Parser and XSLT designed by Dahua Lin, 2007.</p>
            </body>            
        </html>        
    </xsl:template>
    
    <xsl:template match="Context">
        <div class="context_nav">
            <xsl:if test="Prev">
                <div class="context_link prev">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="Prev/@path"/>
                        </xsl:attribute>
                        Prev
                    </a>
                </div>
            </xsl:if>
            <xsl:if test="Next">
                <div class="context_link next">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="Next/@path"/>
                        </xsl:attribute>
                        Next
                    </a>
                </div>
            </xsl:if> 
            <xsl:if test="Root">
                <div class="context_link root">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="Root/@path"/>
                        </xsl:attribute>
                        Home
                    </a>
                </div>
            </xsl:if>
            <xsl:if test="Parent">
                <div class="context_link parent">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="Parent/@path"/>
                        </xsl:attribute>
                        Upper
                    </a>
                </div>
            </xsl:if>
        </div>               
    </xsl:template>
    
    <xsl:template match="MDoc">
        <!-- Head line -->
        <xsl:if test="MHeadLine">
            <p class="mheadline"><xsl:value-of select="MHeadLine"/></p>
        </xsl:if>
        <hr></hr>
        <!-- Sections -->
        <xsl:apply-templates select="MSection"/>
    </xsl:template>
    
    <xsl:template name="contents">
        <xsl:apply-templates select="MList|MTermList|MParagraph|MTable|MCodeBlock|MFormulaLine"/>
    </xsl:template>
    
    <xsl:template match="MSection">
        <div class="section">
            <xsl:attribute name="id" select="@name"></xsl:attribute>
            <!-- Section name -->
            <xsl:if test="@name and string-length(@name) > 0">
                <!-- Captalize the section name -->
                <h2 class="section_name">                    
                    <xsl:value-of select="@name"/>
                </h2>            
            </xsl:if>
            <!-- Contents -->            
            <xsl:call-template name="contents"/>
        </div>        
    </xsl:template>
    
    <xsl:template match="MParagraph">
        <div class="mparagraph"><xsl:value-of select="."/></div>
    </xsl:template>
    
    <xsl:template match="MList">
        <xsl:choose>
            <xsl:when test="@listtype='unordered'">
                <ul class="mlist">
                    <xsl:for-each select="MListItem">
                        <li class="mlist_item"><xsl:call-template name="contents"/></li>
                    </xsl:for-each>
                </ul>                
            </xsl:when>
            <xsl:when test="@listtype='ordered'">
                <ol class="mlist">
                    <xsl:for-each select="MListItem">
                        <li class="mlist_item"><xsl:call-template name="contents"/></li>
                    </xsl:for-each>
                </ol>                
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="MTermList">
        <div class="mterm_div">
            <table class="mtermlist">
                 <xsl:for-each select="MTermEntry">
                      <tr>
                          <th><xsl:value-of select="@term"/></th>
                          <td><xsl:call-template name="contents"/></td>                           
                        </tr>
                    </xsl:for-each>               
            </table> 
        </div>        
    </xsl:template>
    
    <xsl:template match="MTable">
        <div class="mtable_div">
            <table class="mtable">
                <xsl:if test="@title">
                    <caption><xsl:value-of select="@title"/></caption>
                </xsl:if>
                <xsl:for-each select="MTableRow">
                    <tr class="mtable_row">
                        <xsl:for-each select="MTableCell">
                            <xsl:choose>
                                <xsl:when test="@celltype and @celltype='head'">
                                    <th class="mtable_headcell">
                                        <xsl:call-template name="contents"/>
                                    </th>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td class="mtable_cell">
                                        <xsl:call-template name="contents"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>                        
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </table>
        </div>        
    </xsl:template>
    
    <xsl:template match="MCodeBlock">
        <blockquote class="mcodeblock">
            <xsl:for-each select="Line">
                <pre><xsl:value-of select="."/></pre>
            </xsl:for-each>
        </blockquote>        
    </xsl:template>
    
    <xsl:template match="MFormulaLine">
        <blockquote class="mformula_line">
            <xsl:value-of select="."/>
        </blockquote>
    </xsl:template>
        
</xsl:stylesheet>
