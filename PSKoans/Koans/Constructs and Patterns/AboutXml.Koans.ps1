using module PSKoans
[Koan(Position = 312)]
param()
<#
    XML, or eXtensible Markup Language, is one of the more common text-based formats for serialized data.

    With a number of specialised commands  and the  the .NET framework available PowerShell is very capable
    of working with XML documents and XML data in general.

    PowerShell can treat an XML document as a series of nested objects. This is referred to as "XML as an object"
    in the examples which follow, distinguishing the approach from reliance on XPath.
#>
Describe 'About XML' {
    BeforeAll {
        $script:path = Join-Path $TestDrive -ChildPath document.xml
    }

    Context 'XML as an object' {

        It 'can cast a string to an XML document' {
            <#
                Perhaps the most widely used way of working with XML is to treat an XML document as a object.

                This makes use of the [Xml] type accelerator which provides a quick way of accessing the
                [System.Xml.XmlDocument] type.
            #>

            $xml = [Xml]'<documentRoot><element>Hello world</element></documentRoot>'

            # Each element is presented as a property.
            '____' | Should -Be $xml.DocumentRoot.element
        }

        It 'can convert output from Get-Content to an XML document' {
            <#
                It is often desirable to read an XML file to work with in PowerShell.

                Get-Content is often used to read XML content in as text.
            #>

            Set-Content -Path $path -Value @'
<documentRoot>
    <element>A short XML file</element>
</documentRoot>
'@

            # The output from Get-Content can be cast to Xml, even when the document has more than one line.
            $xml = [Xml](Get-Content -Path $path)

            $rootElement = '____'

            $xml.$rootElement.Element | Should -BeExactly 'A short XML file'
        }

        It 'is much faster to use the Load method of XmlDocument for large files' {
            Set-Content -Path $path -Value @'
<documentRoot>
    <element>This is still a short XML file</element>
</documentRoot>
'@

            $xml = [Xml]::new()
            <#
                .NET methods need a fully-qualified path. A relative PowerShell path will resolve to a path relative to
                the working directory for the PowerShell process; often the System32 directory.

                The commands Get-Item, Join-Path, and Resolve-Path can all be used to get the full path to a file using
                the FullName property. For example:

                    $path = (Get-Item file.xml).FullName
            #>
            $xml.Load($path)

            $xml.____.____ | Should -Be 'This is still a short XML file'
        }

        It 'can only contain text' {
            # All values in XML documents are strings. Values which represent other types must be converted.
            $xml = [Xml]'<root><element>1</element></root>'

            [____] | Should -Be $xml.root.element.GetType()
        }

        It 'can expand arrays in a similar way to PowerShell' {
            # If a document contains an array it can be expanded in a similar manner to any other PowerShell object.
            $xml = [Xml]@'
<root>
    <element>1</element>
    <element>2</element>
    <element>3</element>
    <element>4</element>
    <element>5</element>
</root>
'@

            $xml.____.____ | Should -Be '1', '2', '3', '4', '5'
        }

        It 'does not differentiate between elements and attributes' {
            # The value of an attribute can also be retrieved using dot-notation.

            $xml = [Xml]@'
<documentRoot>
    <element attributeName="Attribute value" />
</documentRoot>
'@

            '____' | Should -Be $xml.element.attributeName
        }
    }

    Context 'About Select-Xml' {
        <#
            Treating XML as any other object makes XML documents easy to work with, and offers tremendous convenience.
            For larger documents the above approach can be slow. This is where XPath, a query language for XML, becomes important.

            The Select-Xml command can work with a path to an XML file, a path, or an XML document object.
        #>

        It 'can select XML elements from a string' {
            $xmlContent = @'
<root>
    <someElement>
        <aNestedElement>value</aNestedElement>
    </someElement>
</root>
'@

            # In an XPath expression, //Name can be used to find all elements called Name, anywhere in the document
            $result = Select-Xml -Content $xmlContent -XPath '//aNestedElement'

            '____' | Should -Be $result.Node.'#text'
        }

        It 'returns a different object than the XML as an object approach' {
            <#
                Getting the aNestedElement element like this introduces a difference between the XML-as-an-object approach
                and XPath.
            #>

            $xmlContent = @'
<root>
    <someElement>
        <aNestedElement>value</aNestedElement>
    </someElement>
</root>
'@

            $ExpectedType = [____]

            ([Xml]$xmlContent).root.someElement.aNestedElement | Should -BeOfType $ExpectedType

            <#
                When using Select-Xml and XPath, the XML element is returned, not just the value. This is why the #text
                property is required to access the value within the element.
            #>

            $ExpectedType = [____]

            <#
                Queries using // do not have a defined depth. They are slow on large documents as every element must be
                tested.
            #>
            $result = Select-Xml -Content $xmlContent -XPath '//aNestedElement'
            $result.Node | Should -BeOfType $ExpectedType
        }

        It 'can select XML elements from a file' {
            Set-Content -Path $path -Value @'
<drives>
    <drive>
        <letter>C:</letter>
    </drive>
    <drive>
        <letter>D:</letter>
    </drive>
</drives>
'@

            <#
                Letting Select-Xml read the file is more efficient than reading the file with Get-Content, especially
                for larger files.

                Clearly defined XPath queries will execute faster.
            #>
            $result = Select-Xml -Path $path -XPath '/drives/drive'

            __ | Should -Be $result.Count
        }
    }

    Context 'About SelectSingleNode and SelectNodes' {
        <#
            When performing more extensive operations on a document, the SelectSingleNode and SelectNodes methods of
            the XmlDocument type (the type created by [Xml]) can be useful.
        #>

        It 'can use SelectSingleNode if a single value is required' {
            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
        <size>100</size>
    </drive>
    <drive>
        <letter>D:</letter>
        <size>50</size>
    </drive>
</drives>
'@

            # The value in [ ] defines a condition in the XPath expression.
            $element = $xml.SelectSingleNode('/drives/drive[letter="C:"]/size')

            '____' | Should -Be $element.'#text'
        }

        It 'can use SelectNodes to get more than one matching node' {
            $xml = [Xml]@'
<drives>
    <drive fileSystem="NTFS">
        <letter>C:</letter>
    </drive>
    <drive fileSystem="NTFS">
        <letter>D:</letter>
    </drive>
    <drive fileSystem="FAT32">
        <letter>G:</letter>
    </drive>
</drives>
'@

            # The @ character is required in front of a label when testing the value of an attribute.
            $elements = $xml.SelectNodes('/drives/drive[@fileSystem="NTFS"]/letter')

            @('____', '____') | Should -Be $elements.'#text'
        }

        It 'always returns a list when using SelectNodes' {
            $xml = [Xml]@'
<drives>
    <drive fileSystem="NTFS">
        <letter>C:</letter>
    </drive>
    <drive fileSystem="FAT32">
        <letter>G:</letter>
    </drive>
</drives>
'@

            $element = $xml.SelectNodes('/drives/drive[@fileSystem="FAT32"]/letter')

            $ExpectedType = [____]

            $element.GetType() | Should -Be $ExpectedType
        }
    }

    Context 'Writing XML documents in PowerShell' {
        # .NET offers the XmlWriter type to create XML content from scratch.

        It 'can create an XML file' {
            $xmlWriter = [System.Xml.XmlWriter]::Create($path)

            # A root element can be added to the document
            $xmlWriter.WriteStartElement('drives')

            <#
                When the XML document is complete, the buffer can be flushed, ensuring all content has been written
                to the stream. Then the document can be closed, allowing other processes to use the file.
            #>
            $xmlWriter.Flush()
            $xmlWriter.Close()

            $ExpectedContent = '____'

            $path | Should -FileContentMatch $ExpectedContent
        }

        It 'has configurable settings' {
            <#
                By default the XmlWriter will create an XML declaration and all content will be written to a single
                line.

                XmlWriterSettings can be provided to change this and other behaviours. Settings cannot be modified
                after the XmlWriter has been created.
            #>

            # If Indent is set to $true, line breaks will be added. By default two-spaces are used to indent content.
            $settings = [System.Xml.XmlWriterSettings]@{
                OmitXmlDeclaration = $true
                Indent             = $true
            }
            $xmlWriter = [System.Xml.XmlWriter]::Create($path, $settings)

            $xmlWriter.WriteStartElement('drives')
            $xmlWriter.WriteStartElement('drive')

            # Closing the document will automatically add missing end elements.
            $xmlWriter.Flush()
            $xmlWriter.Close()

            $content = Get-Content $path

            '____' | Should -Be $content[0]
            '____' | Should -Be $content[1]
            '____' | Should -be $content[2]
        }

        It 'can create an XmlWriter using a StringBuilder' {
            # Creating a StringBuilder is useful when an XML string is required instead of a file.
            $stringBuilder = [System.Text.StringBuilder]::new()
            $xmlWriter = [System.Xml.XmlWriter]::Create($stringBuilder)

            $xmlWriter.WriteStartElement('drives')
            $xmlWriter.WriteStartElement('drive')
            <#
                The XmlWriter includes methods to write each of the different possible value types to a document.
                Get-Member can be used to list the different methods:

                    $xmlWriter | Get-Member

                Alternatively, the .NET framework documentation can be reviewed:

                    https://docs.microsoft.com/en-us/dotnet/api/system.xml.xmlwriter?view=netframework-4.8
            #>
            $xmlWriter.WriteElementString('letter', 'C:')

            $xmlWriter.Flush()
            $xmlWriter.Close()

            # The StringBuilder now contains the generated document.
            $xml = [Xml]$stringBuilder.ToString()

            '____' | Should -Be $xml.drives.drive.letter
        }

        It 'expects the user to write end elements in a complex document' {
            $stringBuilder = [System.Text.StringBuilder]::new()
            $xmlWriter = [System.Xml.XmlWriter]::Create($stringBuilder)

            $xmlWriter.WriteStartElement('drives')

            $xmlWriter.WriteStartElement('drive')
            $xmlWriter.WriteElementString('letter', 'C:')
            # If WriteEndElement is missing, the next element will be added as a sibling of <letter>C:</letter>.
            $xmlWriter.WriteEndElement()

            $xmlWriter.WriteStartElement('drive')
            $xmlWriter.WriteElementString('letter', 'D:')

            $xmlWriter.Flush()
            $xmlWriter.Close()

            $xml = [Xml]$stringBuilder.ToString()

            @('____', '____') | Should -Be $xml.drives.drive.letter
        }
    }

    Context 'Modifying XML documents' {
        It 'can remove the content of selected elements from a document' {
            <#
                The content of an element can be removed from a document once they are selected.

                The RemoveAll method used below removes content only, not the element itself.
            #>

            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
    </drive>
    <drive>
        <letter>D:</letter>
    </drive>
</drives>
'@

            $element = $xml.SelectSingleNode('/drives/drive[letter="D:"]')

            <#
                The RemoveAll method will remove the content of the current element.

                When working with file content, the change will be held in memory until the
                Save method is called.
            #>
            $element.RemoveAll()

            '____' | Should -Be $xml.drives.drive.letter
        }

        It 'can remove a node with children using RemoveAll and XML as an object' {
            # The RemoveAll method can also be used when using XML as an object.

            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
    </drive>
    <drive>
        <letter>D:</letter>
    </drive>
</drives>
'@

            $element = $xml.drives.drive | Where-Object letter -eq 'C:'

            # Removes the drive node where the letter is C:
            $element.RemoveAll()

            '____' | Should -Be $xml.drives.drive.letter

            # The content has been removed, but the element remains.

            __ | Should -Be $xml.drives.drive.Count
        }

        It 'can use the RemoveChild method to completely remove an element from a document' {
            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
    </drive>
    <drive>
        <letter>D:</letter>
    </drive>
</drives>
'@

            <#
                The child to be removed element must be selected before it can be removed.

                The element to remove can be selected using either the SelectSingleNode method or by using
                XML as an object.
            #>

            $child = $xml.drives.drive | Where-Object letter -eq 'D:'

            # The RemoveChild method is called on the parent node.
            $xml.drives.RemoveChild($child)

            '____' | Should -Be $xml.drives.drive.letter

            # The element has been completely removed.

            __ | Should -Be $xml.SelectNodes('/drives/drive').Count
        }

        It 'can modify values in an existing node using XML as an object' {
            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
        <size>1</size>
    </drive>
</drives>
'@

            <#
                New values can be assigned directly to leaf value. That is, an element or an attribute which
                does not have children.
            #>

            $xml.drives.drive.size = '5'

            '____' | Should -Be $xml.drives.drive.size
        }

        It 'can assign new values to #text when searching' {
            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
        <size>100</size>
    </drive>
    <drive>
        <letter>D:</letter>
        <size>0</size>
    </drive>
</drives>
'@

            <#
                When searching for a node using SelectSingleNode or SelectNodes, new values must be assigned using the
                #text property.
            #>

            $xml.SelectSingleNode('/drives/drive[letter="D:"]/size').'#text' = '50'

            '____' | Should -Be $xml.SelectSingleNode('/drives/drive[letter="D:"]/size').'#text'
        }

        <#
            There are several different ways to add new elements to an XML document. The easiest method should be used
            depending on the situation.
        #>

        It 'can create new elements using the CreateElement method' {
            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
    </drive>
</drives>
'@

            # The CreateElement method is executed on the document.
            $newNode = $xml.CreateElement('size')
            # A new value can be set using the InnerText property.
            $newNode.InnerText = '50'
            # The new element can added to the document using the AppendChild method the parent element.
            $xml.drives.drive.AppendChild($newNode)

            '____' | Should -Be $xml.drives.drive.size
        }

        It 'can create new elements using CreateDocumentFragment' {
            # A document fragment is an empty XML document which can be added to the current document.

            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
    </drive>
</drives>
'@

            # The CreateDocumentFragment is executed on the document.
            $newNode = $xml.CreateDocumentFragment()
            # The desired XML content is assigned to the InnerXml property.
            $newNode.InnerXml = '<drive><letter>D:</letter></drive>'
            # The new element can added to the document using the AppendChild method the parent element.
            $xml.drives.AppendChild($newNode)

            @('____', '____') | Should -Be $xml.drives.drive.letter
        }

        It 'can import elements from a different XML file' {
            # Elements from other XML documents can be copied but those elements must be imported first.

            $existingXml = [Xml]'<root><localNode>Existing Value</localNode></root>'
            $otherXml = [Xml]'<root><otherNode>New Value</otherNode></root>'

            # A child of another document can be selected to import.
            $nodeToCopy = $otherXml.SelectSingleNode('/root/otherNode')
            # The node can be imported either as a shallow or a deep copy.
            $importedNode = $existingXml.ImportNode($nodeToCopy, $true)
            # Once imported, the node can be added to the existing document.
            $existingXml.root.AppendChild($importedNode)

            '____' | Should -Be $existingXml.root.otherNode
        }

        It 'can add elements before or after a specific element' {
            <#
                The order elements appear in an XML document is often important. An XmlDocument has tweo
                methods which can be used to add content in a specific place.

                    * InsertBefore
                    * InsertAfter
            #>

            $xml = [Xml]@'
<list>
    <item>1</item>
    <item>2</item>
    <item>4</item>
    <item>5</item>
</list>
'@

            <#
                First select the which appears before or after the desired position.

                The XPath expression below uses . to refer to the value of the current element.
            #>
            $previousElement = $xml.SelectSingleNode('/list/item[.="2"]')
            # The new element must be created and given a value.
            $newElement = $xml.CreateElement('item')
            $newElement.InnerText = '3'

            # Then the element can be inserted into the document
            $xml.list.InsertAfter($newElement, $previousElement)

            @('__', '__', '__', '__', '__') | Should -Be $xml.list.item
        }

        It 'can add attributes to an existing element' {
            <#
                New attributes may be added using the SetAttribute method of an XML Element.

                The SetAttribute method may also be used to modify existing attributes.
            #>

            $xml = [Xml]@'
<drives>
    <drive>
        <letter>C:</letter>
    </drive>
</drives>
'@

            $xml.drives.drive.SetAttribute('fileSystem', 'NTFS')

            '<drive fileSystem="____"><letter>C:</letter></drive>' | Should -Be $xml.drives.InnerXml
        }
    }

    Context 'Working with namespaces' {
        <#
            Namespaces are most often used when a document is written to conform to an XML schema.

            The URI used for a namespace is often made-up, it does not have to exist on the Internet. The namespace
            must be unique within the document. XML parsers require namespace URIs to be unique, but do not use the
            value to retrieve information.

            The default namespace for a document is described using an xmlns attribute on the root node. For example:

                <root xmlns="http://someuri/default.xsd">
                    ...
                </root>

            XML documents may declare more than one namespace. Additional namespaces are declared with a prefix.

                <root xmlns="http://someuri/default.xsd" xmlns:prefix="http://someuri/prefix.xsd">
                    ...
                </root>

            The prefix name is arbitrary but must be consistent within a document.
        #>

        It 'does not change how XML as an object finds values' {
            # The document below does not use a default namespace.

            $xml = [Xml]@'
<drives xmlns:prefix="http://someuri/prefix.xsd">
    <prefix:drive>
        <prefix:letter>C:</prefix:letter>
    </prefix:drive>
</drives>
'@

            '____' | Should -Be $xml.drives.drive.letter
        }

        It 'must be listed in the Namespace parameter when using Select-Xml' {
            # The document below uses a default namespace.

            $xml = [Xml]@'
<drives xmlns="http://someuri/id.xsd">
    <drive>
        <letter>C:</letter>
    </drive>
</drives>
'@

            <#
                Select-Xml uses a hashtable to describe the namespaces used in a document.

                The default namespace must be listed, and must be given a prefix. The name used for the prefix is
                made up.
            #>

            $result = Select-Xml -Xml $xml -XPath '//anything:letter' -Namespace @{
                'anything' = 'http://someuri/id.xsd'
            }
            '____' | Should -Be $result.Node.'#text'
        }

        It 'must use an XmlNamespaceManager when using SelectNodes or SelectSingleNode' {
            <#
                The document below uses both a default and an additional namespace.

                The drives element belongs to the default namespace. Each drive element to the additional namespace.
            #>

            $xml = [Xml]@'
<drives xmlns="http://someuri/default.xsd" xmlns:named="http://someuri/named.xsd">
    <named:drive>
        <named:letter>C:</named:letter>
    </named:drive>
</drives>
'@

            <#
                The SelectSingleNode (and SelectNodes) methods include overloads which accept an XmlNamespaceManager
                as an argument as shown below:

                    System.Xml.XmlNode SelectSingleNode(string xpath, System.Xml.XmlNamespaceManager nsmgr)
                    System.Xml.XmlNodeList SelectNodes(string xpath, System.Xml.XmlNamespaceManager nsmgr)

                The namespace manager requires a NameTable. The nametable property of the XML document can be used.

                The namespaces used by the document must still be added to the namespace manager.
            #>

            $xmlNamespaceManager = [System.Xml.XmlNamespaceManager]::new($xml.NameTable)

            <#
                Each namespace used, including the default, must be added to the namespace manager.

                The prefix names do not have to match the names used in the original document.
            #>

            $xmlNamespaceManager.AddNamespace('d', 'http://someuri/default.xsd')
            $xmlNamespaceManager.AddNamespace('n', 'http://someuri/named.xsd')

            # Elements in the default namespace must be given the made-up prefix names

            $result = $xml.SelectSingleNode('/d:drives/n:drive/n:letter', $xmlNamespaceManager)

            '____' | Should -Be $result.'#text'
        }

        It 'should use appropriate namespace references when modifying a document' {
            <#
                Namespaces must be consistently used when updating a document. Methods such as CreateElement
                must be told about the namespace any elements it creates.
            #>

            $xml = [Xml]@'
<drives xmlns="http://someuri/default.xsd" xmlns:named="http://someuri/named.xsd">
    <named:drive>
        <named:letter>C:</named:letter>
    </named:drive>
</drives>
'@

            <#
                The name of the prefix must match the name used in the original document. If a different value is
                used, a new xmlns attribute will be created in the document on the newly created "size" element.

                The overload for CreateElement expects the prefix name, the element name, and the namespace URI.
            #>
            $newNode = $xml.CreateElement('named', 'size', 'http://someuri/named.xsd')
            $newNode.InnerText = '50'
            $xml.drives.drive.AppendChild($newNode)

            # Now to test the value has been set.
            $xmlNamespaceManager = [System.Xml.XmlNamespaceManager]::new($xml.NameTable)
            $xmlNamespaceManager.AddNamespace('d', 'http://someuri/default.xsd')
            $xmlNamespaceManager.AddNamespace('n', 'http://someuri/named.xsd')
            $result = $xml.SelectNodes('/d:drives/n:drive/n:size', $xmlNamespaceManager)

            '____' | Should -Be $result.'#text'
        }
    }
}
