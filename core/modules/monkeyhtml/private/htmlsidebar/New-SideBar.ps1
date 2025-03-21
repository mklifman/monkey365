# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function New-SideBar{
    <#
        .SYNOPSIS

        .DESCRIPTION

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: New-SideBar
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    Param (
        [Parameter(Mandatory = $true, HelpMessage = 'Matched items')]
        [Object]$items
    )
    Begin{
        $sidebar = [xml] '<div class="vertical-nav" id="sidebar"></div>'
        $menu_items = $items | Select-Object -ExpandProperty serviceName -Unique | Sort-Object
        ######Create ul and li elements ########
        $ul_attributes = @{
            class = 'nav-item';
        }
        $ul_element = @{
            tagname = 'ul';
            attributes = $ul_attributes;
            innerText = $null;
            own_template = $sidebar;
        }
        #Create UL element
        $unit_ul = New-HtmlTag @ul_element
        #Create LI element
        $unit_li = New-HtmlTag -tagname "li" -own_template $sidebar
        #Create a href
        $a_menu_attributes = @{
            href = $null;
            class = 'nav-link collapsed';
            'data-bs-toggle' = 'collapse';
            'aria-expanded' = $false;
        }
        $a_menu_element = @{
            tagname = 'a';
            attributes = $a_menu_attributes;
            appendObject = $null;
            own_template = $sidebar;
        }
        #########End elements###################
        #Create header info
        $head_attributes = @{
            class = 'header';
        }
        $head_element = @{
            tagname = 'div';
            attributes = $head_attributes;
            innerText = $null;
            own_template = $sidebar;
        }
        $div = New-HtmlTag @head_element
        #Create IMG
        $img_attributes = @{
            src = 'assets/inc-monkey/logo/MonkeyLogo.png';
            alt = 'monkey365';
        }
        $img_element = @{
            tagname = 'img';
            attributes = $img_attributes;
            innerText = $null;
            own_template = $sidebar;
        }
        $img = New-HtmlTag @img_element
        #create span element
        $span_attributes = @{
            class = 'align-middle me-3';
        }
        $span_element = @{
            tagname = 'span';
            innerText = "Monkey365";
            attributes = $span_attributes;
            own_template = $sidebar;
        }
        #Create a element and combine with H4
        $span = New-HtmlTag @span_element
        #Create a href
        $a_attributes = @{
            href = "javascript:show('monkey-main-dashboard')";
            class = 'sidebar-brand';
        }
        $a_element = @{
            tagname = 'a';
            attributes = $a_attributes;
            own_template = $sidebar;
        }
        #Create a element and combine with H4
        $a_href = New-HtmlTag @a_element
        #Add image and span to a href
        [void]$a_href.AppendChild($img)
        [void]$a_href.AppendChild($span)
        #Append to header
        [void]$div.AppendChild($a_href)
        #Create P element
        $p = $sidebar.CreateElement("p")
        [void]$p.SetAttribute('class','text-gray fw-bold text-uppercase px-3 small pb-1 mb-0')
        $p.InnerText = "Resources"
        #Add header and p elements to main div
        [void]$sidebar.div.AppendChild($div)
        [void]$sidebar.div.AppendChild($p)
    }
    Process{
        foreach($item in $menu_items){
            #Create UL element
            $ul = $unit_ul.clone()
            #Create LI element
            $li = $unit_li.clone()
            #Create I element
            $i = $sidebar.CreateElement("i")
            $icon = ("{0} nav-icon" -f (Get-FabricIcon -Icon $item))
            [void]$i.SetAttribute('class',$icon)
            #[void]$i.SetAttribute('class','bi bi-box-arrow-down-right nav-icon')

            #Create a href and append i element
            $random_item = ("menu_{0}" -f ([System.Guid]::NewGuid().Guid.Replace('-','')))
            $a_menu_attributes.href = ('#{0}' -f $random_item)
            $a_menu_element.appendObject = $i
            $a = New-HtmlTag @a_menu_element
            #Add text
            [void]$a.AppendChild($sidebar.CreateTextNode($item))

            #Append a to li element
            [void]$li.AppendChild($a)
            #Get Subitems
            $subitems = $items | Where-Object {$_.serviceName -eq $item} | Select-Object -ExpandProperty serviceType -Unique
            #Create UL
            $sub_ul = $sidebar.CreateElement("ul")
            [void]$sub_ul.SetAttribute('class','nav-submenu collapse')
            [void]$sub_ul.SetAttribute('id',$random_item)
            foreach($subitem in $subitems){
                #Create li element
                $sub_li = $sidebar.CreateElement("li")
                #Create span element
                $span = $sidebar.CreateElement("span")
                [void]$span.SetAttribute('class','asset')
                #Create img element
                $img = $sidebar.CreateElement("img")
                [void]$img.SetAttribute('class','manImg')
                [void]$img.SetAttribute('src',(Get-HtmlIcon -icon_name $subitem))
                #Append to span element
                [void]$span.AppendChild($img)
                #Create a element
                $a = $sidebar.CreateElement("a")
                [void]$a.SetAttribute('href',("javascript:show('{0}')" -f $subitem.ToLower().Replace(' ','-')))
                #Combine elements
                [void]$a.AppendChild($span)
                #Add text
                [void]$a.AppendChild($sidebar.CreateTextNode($subitem))
                #Append to li element
                [void]$sub_li.AppendChild($a)
                #Add to UL element
                [void]$sub_ul.AppendChild($sub_li)
            }
            #Add to li element
            [void]$li.AppendChild($sub_ul)
            #Close i tags
            $i = $li.SelectNodes("//i")
            $i | ForEach-Object {$_.InnerText = [string]::Empty}
            #Add to first UL element
            [void]$ul.AppendChild($li)
            #Add to sidebar
            [void]$sidebar.div.AppendChild($ul)
        }
    }
    End{
        return $sidebar
    }
}


