<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xs" version="2.0" xmlns="http://www.w3.org/2002/07/owl#"
    xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
    <xsl:output indent="yes" method="html" encoding="us-ascii"/>

    <xd:doc type="stylesheet"> The purpose of this stylesheet is to transform an OWL file to HTML in
        a format that was requested by Prof Howard Hotson in May 2014. The structure of the
        resulting HTML file is as follows: List of classes present in the file together with their
        definition. The list is divided into categories: * Activity - classes that are defined as
        subclasses of prov:Activity * Role - classes that are defined as subclasses of prov:Role *
        Other - other classes defined in the file The list is nested to reflect the organisation of
        the classes in the OWL file. A nested item has an 'is a' relationship to its parent item.
        Relationship assertions that exist in the data model by way of the object properties are
        provided below the corresponding class definition. </xd:doc>




    <xd:doc>
        <xd:short> Main template Defines HTML page Include ontology file annotation e.g. title and
            comment Define structure of file: * Activity * Role * Other </xd:short>
        
        
        <xd:detail>
            <templateName></templateName>
            <templatesCalled>
                <template>other</template>
                <template>SubClassOf</template>
            </templatesCalled>
        </xd:detail>
    </xd:doc>

    <xsl:template match="/">
        <xhtml>
            <head>
                <link rel="stylesheet" href="style.css"/>
            </head>
            <body>
                <h1>
                    <xsl:value-of
                        select="/owl:Ontology/owl:Annotation[owl:AnnotationProperty/@IRI='http://purl.org/dc/terms/title']/owl:Literal"
                    />
                </h1>
                <h2>
                    <xsl:value-of select="/owl:Ontology/@xml:base"/>
                </h2>
                <div class="FileDescription">
                    <p>
                        <xsl:value-of
                            select="/owl:Ontology/owl:Annotation[owl:AnnotationProperty/@abbreviatedIRI='rdfs:comment']/owl:Literal"
                        />
                    </p>
                </div>
                <div class="list">
                    <h2>Activity </h2>
                    <ol>
                        <xsl:apply-templates mode="SubClassOf"
                            select="/owl:Ontology/owl:SubClassOf[owl:Class[2]/@IRI='http://www.w3.org/ns/prov#Activity']"
                        />
                    </ol>
                    <h2>Role</h2>
                    <ol>
                        <xsl:apply-templates mode="SubClassOf"
                            select="/owl:Ontology/owl:SubClassOf[owl:Class[2]/@IRI='http://www.w3.org/ns/prov#Role']"
                        />
                    </ol>
                    <h2>Other</h2>
                    <ol>
                        <xsl:apply-templates mode="other"
                            select="/owl:Ontology/owl:Declaration[owl:Class/@IRI!='']"/>
                    </ol>
                </div>
            </body>
        </xhtml>
    </xsl:template>






    <xd:doc>
       
        <xd:short>Template to display classes that are not types of prov:Activity or
            prov:Role</xd:short>

        

        <xd:detail>
            <templateName>other</templateName>
            <templatesCalled>
                <template>DeclarationClass</template>
                <template>SubClassOf</template>
            </templatesCalled>
            <matching>
                <Declaration>
                    <Class IRI="Religion"/>
                </Declaration> and ... <SubClassOf>
                    <Class IRI="EcclesiasticalOrganisation"/>
                    <Class IRI="http://xmlns.com/foaf/0.1/Organization"/>
                </SubClassOf> and ... <SubClassOf>
                    <Class IRI="http://vocab.ox.ac.uk/camelot/Role#Resident"/>
                    <Class IRI="BiographicalLocationRole"/>
                </SubClassOf>
            </matching>
        </xd:detail>

    </xd:doc>

    <xsl:template mode="other" match="owl:Declaration">


        <xsl:variable name="declarationClass" select="owl:Class"/>
        <xsl:variable name="iri" select="owl:Class/@IRI"/>



        <xsl:choose>

            <!-- when this class is a w3c ontology class e.g. prov or org - do not display -->
            <xsl:when test="contains($iri, 'http://www.w3.org/ns/') = true()"/>


            <!-- when this class is defined as being a subclass of something else -->
            <xsl:when test="/owl:Ontology/owl:SubClassOf/owl:Class[1][@IRI=$iri]">

                <!-- loop through corresponding subclass declarations  -->
                <xsl:for-each select="/owl:Ontology/owl:SubClassOf[owl:Class[1]/@IRI=$iri]">
                    <!-- assign owl:SubClassOf node to the variable $cl -->
                    <xsl:variable name="cl" select="."/>

                    <!-- if the class is a subclass of an externally defined class that is not a prov:activity or prov:role
                            then 
                            * add a list item 
                            * call the DeclarationClass template
                            * add an ordered list
                            * call the SubClassOf template with all owl:SubClassOf nodes that have a superclass that matches the current node
                                * this will display subclasses of the current class as nested elements                    
                    -->
                    <xsl:if
                        test="(contains($cl/owl:Class[2]/@IRI , ':') = true()) and (contains($cl/owl:Class[2]/@IRI , 'http://www.w3.org/ns/prov#Activity') = false()) and (contains($cl/owl:Class[2]/@IRI , 'http://www.w3.org/ns/prov#Role') = false())">
                       
                            <xsl:apply-templates mode="DeclarationClass" select="$declarationClass"
                            />
                        
                        <ol>
                            <xsl:apply-templates mode="SubClassOf"
                                select="/owl:Ontology/owl:SubClassOf[owl:Class[2]/@IRI=$iri]"/>
                        </ol>
                    </xsl:if>

                </xsl:for-each>
            </xsl:when>


            <!-- otherwise  add list item and call DeclarationClass template -->
            <xsl:otherwise>
                
                    <xsl:apply-templates mode="DeclarationClass" select="$declarationClass"/>
                
                <!-- * call the SubClassOf template with all owl:SubClassOf nodes that have a superclass that matches the current node
                                * this will display subclasses of the current class as nested elements   -->
                <ol>
                    <xsl:apply-templates mode="SubClassOf"
                        select="/owl:Ontology/owl:SubClassOf[owl:Class[2]/@IRI=$iri]"/>
                </ol>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>





    <xd:doc>
        
        <xd:short>Template to display class definition and call same template to display subclasses. 
            Also calls templates to display assertions.</xd:short>
        
        
        
        <xd:detail>
            <templateName>SubClassOf</templateName>
            <templatesCalled>
                <template>domain</template>
                <template>range2</template>
                <template>DeclarationClass</template>
                <template>SubClassOf</template>
            </templatesCalled>
            <matching>
                <SubClassOf>
                    <Class IRI="Baptism"/>
                    <Class IRI="http://www.w3.org/ns/prov#Activity"/>
                </SubClassOf>
                
                <SubClassOf>
                    <Class IRI="http://vocab.ox.ac.uk/camelot/Role#Resident"/>
                    <Class IRI="BiographicalLocationRole"/>
                </SubClassOf>
            </matching>
            <SubClassOf>
                <Class IRI="EcclesiasticalAdministrativeOffice"/>
                <Class IRI="EcclesiasticalOffice"/>
            </SubClassOf>
        </xd:detail>
        
    </xd:doc>

    <xsl:template mode="SubClassOf" match="owl:SubClassOf">
          
        <xsl:variable name="iri" select="owl:Class[1]/@IRI"/>
        

        <xsl:choose>
            <!-- when a class declaration does not exist in the ontology file, ie this is an external class
                    add a list item and call DeclarationClass template to display class definition
            
            -->
            <xsl:when test="exists(/owl:Ontology/owl:Declaration/owl:Class[@IRI = $iri]) = false()">    
                    <xsl:apply-templates mode="DeclarationClass" select="./owl:Class[1]"/>
            </xsl:when>
            
            <!-- call the DeclarationClass template with any Class declarations that matches the current SubclassOf node's first class IRI  -->
            <xsl:otherwise>
                    <xsl:apply-templates mode="DeclarationClass"
                        select="/owl:Ontology/owl:Declaration/owl:Class[@IRI = $iri]"/>
                
            </xsl:otherwise>
        </xsl:choose>

        <!-- add an ordered list and call the SubClassOf template with any subclasses of this particular class
  -->
        <ol>
            <xsl:apply-templates mode="SubClassOf"
                select="/owl:Ontology/owl:SubClassOf[owl:Class[2]/@IRI=$iri]"/>
        </ol>


    </xsl:template>



   
    
    
    <xd:doc>
        
        <xd:short>Template to display class definition and corresponding assertions that exist in the data model</xd:short>
        
        <xd:detail>
            <templateName>DeclarationClass</templateName>
            <templatesCalled>
                <template>AnnotationAssertion</template>
                <template>domain</template>
                <template>range2</template>
            </templatesCalled>
            <matching>
                <Declaration>
                    <Class IRI="Baptism"/>
                </Declaration>
            </matching>
            
        </xd:detail>
        
    </xd:doc>
    
    <xsl:template mode="DeclarationClass" match="owl:Class">

        <xsl:variable name="iri" select="@IRI"/>
        
        <!-- if IRI contains hash, remove the substring before and including # for display-->
        <xsl:variable name="iri2display"
            select="if (contains(@IRI, '#')= true()) then (substring-after(@IRI, '#')) else @IRI"/>

        <xsl:variable name="httpIRI" select="if (contains(@IRI, ':')= true()) then ( concat('(defined at: ', $iri, ')')) else ''"/>

        <!-- display class definition -->
        <li><p>
            <em>
                <xsl:value-of select="$iri2display"/>
                <sup><xsl:value-of select="$httpIRI"/></sup>
            </em>
            <xsl:apply-templates mode="AnnotationAssertion"
                select="//owl:AnnotationAssertion[owl:AnnotationProperty/@abbreviatedIRI='rdfs:comment' and owl:IRI = $iri]"/>
        </p>
        </li>
        <!-- display any assertions present in the OWL file that include this class -->
        <ul class="assertion">
            <xsl:apply-templates mode="Domain"
                select="//owl:ObjectPropertyDomain[owl:Class/@IRI = $iri]"/>
            <xsl:apply-templates mode="Range"
                select="//owl:ObjectPropertyRange[owl:Class/@IRI = $iri]"/>
        </ul>
        
    </xsl:template>








    <xd:doc>
        
        <xd:short>Template to display assertions that are the result of object property domain definitions</xd:short>
        
        <xd:detail>
            <templateName>Domain</templateName>
            <templatesCalled>
                <template>Range4ObjectProperty</template>
            </templatesCalled>
            <matching>
                <ObjectPropertyDomain>
                    <ObjectProperty IRI="receivesLetterFrom"/>
                    <Class IRI="http://vocab.ox.ac.uk/camelot/Role#LetterRecipient"/>
                </ObjectPropertyDomain>
            </matching>
            
        </xd:detail>
        
    </xd:doc>


    <xsl:template mode="Domain" match="owl:ObjectPropertyDomain">
        
        <!-- IRI for the class that is the domain of this object property -->
        <xsl:variable name="iri" select="owl:Class/@IRI"/>
        <!-- IRI for the object property, or relation  -->
        <xsl:variable name="objectPropertyIri" select="owl:ObjectProperty/@IRI"/>

        <!-- if IRI for class contains # remove this and substring before -->
        <xsl:variable name="iri2display"
            select="if (contains(owl:Class/@IRI, '#')= true()) then (substring-after(owl:Class/@IRI, '#')) else owl:Class/@IRI"/>
        <!-- if IRI for object property contains # remove this and substring before -->
        <xsl:variable name="opiri2display"
            select="if (contains(owl:ObjectProperty/@IRI, '#')= true()) then (substring-after(owl:ObjectProperty/@IRI, '#')) else owl:ObjectProperty/@IRI"/>

        <!-- add list item and display class name and then object property -->
        <li>{<xsl:value-of select="$iri2display"/>}<xsl:text> </xsl:text>
            <xsl:value-of select="$opiri2display"/>
            <xsl:text> </xsl:text>
            
            <!-- call range template to display all classes that are in the range of this object property -->
            <xsl:apply-templates mode="RangeOrDomain4ObjectProperty"
                select="//owl:ObjectPropertyRange[owl:ObjectProperty/@IRI = $objectPropertyIri]"
            /></li>

    </xsl:template>


    <xd:doc>
        
        <xd:short>Template to display class names that are in the range or domain of a selected object property</xd:short>
        
        <xd:detail>
            <templateName>RangeOrDomain4ObjectProperty</templateName>
            
            <matching>
                <ObjectPropertyDomain>
                    <ObjectProperty IRI="receivesLetterFrom"/>
                    <Class IRI="http://vocab.ox.ac.uk/camelot/Role#LetterRecipient"/>
                </ObjectPropertyDomain>
                or ...
                <ObjectPropertyRange>
                    <ObjectProperty IRI="http://vocab.ox.ac.uk/camelot/Role#senderOfLetter"/>
                    <Class IRI="Letter"/>
                </ObjectPropertyRange>
            </matching>
            
        </xd:detail>   
    </xd:doc>

    <xsl:template mode="RangeOrDomain4ObjectProperty" match="*">
        <!-- modify IRI for display if it contains a # -->
        <xsl:variable name="iri"
            select="if (contains(owl:Class/@IRI, '#')= true()) then (substring-after(owl:Class/@IRI, '#')) else owl:Class/@IRI"
        /> {<xsl:value-of select="$iri"/>} </xsl:template>



   



    <xsl:template mode="Range" match="owl:ObjectPropertyRange">
        <!-- IRI for the class that is the domain of this object property -->
        <xsl:variable name="iri" select="owl:Class/@IRI"/>
        <!-- IRI for the object property, or relation  -->
        <xsl:variable name="objectPropertyIri" select="owl:ObjectProperty/@IRI"/>
        
        <!-- if IRI for class contains # remove this and substring before -->
        <xsl:variable name="iri2display"
            select="if (contains(owl:Class/@IRI, '#')= true()) then (substring-after(owl:Class/@IRI, '#')) else owl:Class/@IRI"/>
        <!-- if IRI for object property contains # remove this and substring before -->
        <xsl:variable name="opiri2display"
            select="if (contains(owl:ObjectProperty/@IRI, '#')= true()) then (substring-after(owl:ObjectProperty/@IRI, '#')) else owl:ObjectProperty/@IRI"/>
        
        <li><xsl:apply-templates mode="RangeOrDomain4ObjectProperty"
                select="//owl:ObjectPropertyDomain[owl:ObjectProperty/@IRI = $objectPropertyIri]"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$opiri2display"/> {<xsl:value-of select="$iri2display"/>}</li>


    </xsl:template>


   
    <xd:doc>
        
        <xd:short>Template to display annotations for a selected item in the owl file </xd:short>
        
        <xd:detail>
            <templateName>AnnotationAssertion</templateName>
            
            <matching>
                <AnnotationAssertion>
                    <AnnotationProperty abbreviatedIRI="rdfs:comment"/>
                    <IRI>Baptism</IRI>
                    <Literal>The Christian religious rite of sprinkling water on to a person’s forehead or of immersing them in water, symbolizing purification or regeneration and admission to the Christian Church. In many denominations, baptism is performed on young children and is accompanied by name-giving.</Literal>
                </AnnotationAssertion>
            </matching>
            
        </xd:detail>   
    </xd:doc>

 
    <xsl:template mode="AnnotationAssertion" match="owl:AnnotationAssertion">
         <xsl:value-of select="owl:Literal"/>
    </xsl:template>



</xsl:stylesheet>
