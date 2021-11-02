<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:template match='/'>
        <html>
            <!-- Head -->
            <head>
                <title>
                    MATLAB-Doc of <xsl:value-of select="MDirInfo/@dirname"/>
                </title>
                <link rel="stylesheet" type="text/css" href="../mdir_doc.css" />
            </head>
            <body>
                <!-- Navigation -->
                <xsl:apply-templates select="MDirInfo/Context"/>
                <!-- Title -->
                <a name="top"/>
                <h1 class="doc_title">
                    <xsl:choose>
                        <xsl:when test="MDirInfo/@dirtype='class'">
                            class <xsl:value-of select="substring(MDirInfo/@dirname, 2)"/> 
                        </xsl:when>
                        <xsl:otherwise>
                            Directory <xsl:value-of select="MDirInfo/@dirname"/>
                        </xsl:otherwise>
                    </xsl:choose>                    
                </h1>
                <hr></hr>
                <!-- List -->                
                <xsl:apply-templates select="MDirInfo/Subs"/>
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
        
    <xsl:template match="Subs">
         <xsl:call-template name="BriefList"/>
        <xsl:if test="MDirRef[@type='normal']">
            <hr></hr>
            <xsl:call-template name="DetailedList"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="BriefList">
        <xsl:if test="MFileRef">
            <div class="filelist">
                <h2 class="list_title">
                    M-Files (<xsl:value-of select="count(MFileRef)"/>)
                </h2>
                <ul class="list">
                    <xsl:for-each select="MFileRef">
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="@path"/>
                                </xsl:attribute>
                                <xsl:value-of select="@name"/>
                            </a>                            
                            <span class="brief">
                                <xsl:value-of select="document(@path)/MFileInfo/MDoc/MHeadLine"/>
                            </span>
                        </li>                            
                    </xsl:for-each>
                </ul>
            </div>            
        </xsl:if>
        <xsl:if test="MDirRef[@type='class']">
            <div class="classlist">
                <h2 class="list_title">
                    Classes (<xsl:value-of select="count(MDirRef)"/>)
                </h2>
                <ul class="list">
                    <xsl:for-each select="MDirRef[@type='class']">
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="@path"/>
                                </xsl:attribute>
                                <xsl:value-of select="@name"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        <xsl:if test="MDirRef[@type='normal']">
            <div class="dir_list">
                <h2 class="list_title">
                    Sub-Directories (<xsl:value-of select="count(MDirRef[@type='normal'])"/>)                
                </h2>
                <ul class="list">
                    <xsl:for-each select="MDirRef[@type='normal']">
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="@path"/>
                                </xsl:attribute>
                                <xsl:value-of select="@name"/>
                            </a>    
                        </li>                          
                    </xsl:for-each>                             
                </ul>
            </div>            
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="DetailedList">
        <div class="detailed_list">
            <h2>
                Detailed Contents of Sub Directories
            </h2>
            <xsl:for-each select="MDirRef[@type='normal']">
                <xsl:call-template name="ContentList"/>    
            </xsl:for-each>
        </div>        
    </xsl:template>
    
    <xsl:template name="ContentList">
        <div class="content_list">
            <h3>
                Directory
                <a class="content_dir_ref">
                    <xsl:attribute name="href">
                        <xsl:value-of select="@path"/>
                    </xsl:attribute>
                    <xsl:value-of select="@name"/>
                </a>                
            </h3>
            <table class="content_table">
                <xsl:for-each select="MDirRef">
                    <tr>
                        <th>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="@path"/>
                                </xsl:attribute>
                                <xsl:value-of select="@name"/>
                             </a>
                        </th>
                        <td>
                            <xsl:choose>
                                <xsl:when test="@type='class'">
                                    Class <xsl:value-of select="substring(@name, 2)"/> 
                                </xsl:when>
                                <xsl:otherwise>
                                    Sub directory
                                </xsl:otherwise>
                            </xsl:choose>                            
                        </td>
                    </tr>
                </xsl:for-each>
                <xsl:for-each select="MFileRef">
                    <tr>
                        <th>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="@path"/>
                                </xsl:attribute>
                                <xsl:value-of select="@name"/>
                            </a>
                        </th>
                        <td>
                            <xsl:value-of select="document(@path)/MFileInfo/MDoc/MHeadLine"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
            <p class="topref">
                <a href="#top">[Back to Top]</a>
            </p>
        </div>
    </xsl:template>
    
</xsl:stylesheet>

