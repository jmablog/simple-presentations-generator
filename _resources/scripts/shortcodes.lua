--[[
  =========================
  QUESTION / ANSWER LINKING
  =========================
  lets question [Q1]{} and answers [A1]{} spans defined with empty bracketed
  spans link to each other
]]
function Span (elem)
  if elem.content[1].text:match '^Q[%d]+$' then
      
      local link = "#" .. elem.content[1].text:gsub("Q", "A")
      local newelem = pandoc.Link(elem.content[1].text, link)
      newelem.identifier = elem.content[1].text
      
      return newelem
      
  elseif elem.content[1].text:match '^A[%d]+$' then
      
      local link = "#" .. elem.content[1].text:gsub("A", "Q")
      local newelem = pandoc.Link(elem.content[1].text, link)
      newelem.identifier = elem.content[1].text
      
      return newelem
      
  else
      return elem
  end
end

--[[
  ==============
  BREAKOUT BOXES
  ==============
  applyies box stylings using Pandoc fenced divs
  e.g. ::: Aside
]]

-- function to check for item in set
-- from https://riptutorial.com/lua/example/13407/search-for-an-item-in-a-list
function Test_set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function Div (elem)

  --[[
    check if elem has a class that matches a given breakout box format
    can add more formats here if desired, just remember to add styles to
    css / latex / word templates as well
  ]]
  local breakout_choices = Test_set { "Aside", "Questions", "Tip", "Warning", "Success", "notes" }
  local breakout_type = elem.classes[1]

  -- match and add styles to elem as appropriate for FORMAT
  if breakout_choices[breakout_type] then
    if FORMAT:match 'docx' then
      elem.attributes['custom-style'] = elem.classes[1]
      return elem
    elseif FORMAT:match 'latex' then
      local drawBox = "\\begin{tcolorbox}[beforeafter skip=1cm, ignore nobreak=true, breakable, colframe=" .. elem.classes[1] .. "-frame, colback=" .. elem.classes[1] .. "-bg, coltext=" .. elem.classes[1] .. "-text, boxsep=2mm, arc=0mm, boxrule=0.5mm]"
      return{
        pandoc.RawBlock('latex', '\\vfill'),
        pandoc.RawBlock('latex', drawBox),
        elem,
        pandoc.RawBlock('latex', '\\end{tcolorbox}')
      }
    else
      return elem
    end
  end

end

--[[
  ===============================
  SLIDE PAGEBREAKS FOR PDF & HTML
  ===============================
  inserts a pagebreak for headers and horizontal rules in pdf
]]

function Header(elem)
  if FORMAT:match 'latex' then
    if elem.level == 1 then
      return {
        pandoc.RawBlock('latex', '\\newpage'),
        pandoc.RawBlock('latex', '\\vspace*{2.5cm}'),
        pandoc.RawBlock('latex', '\\begin{center}'),
        elem,
        pandoc.RawBlock('latex', '\\end{center}')
      }
    else
      return {
        pandoc.RawBlock('latex', '\\newpage'),
        elem
      }
    end
  end
  if FORMAT:match 'html' then
    if elem.level == 1 then
      return {
        pandoc.RawBlock('html', '</div>'),
        pandoc.RawBlock('html', '<div class="slide">'),
        elem
      }
    else
      return {
        pandoc.RawBlock('html', '</div>'),
        pandoc.RawBlock('html', '<div class="slide">'),
        elem
      }
    end
  end
end

function HorizontalRule(elem)
  if FORMAT:match 'latex' then
    return pandoc.RawBlock('latex', '\\newpage')
  end
end

-- Restrict image height to half page height if the target format is LaTeX.
-- Uses the adjustbox package, included in latex.tex template

function Image(elem)
  if FORMAT:match 'latex' then
    return {
      pandoc.RawInline('latex', '\\includegraphics[max height=0.5\\paperheight]{'),
      elem.src,
      pandoc.RawInline('latex', '}')
    }
  end
end

--[[
  ==========================================================
  pagebreak – convert raw LaTeX page breaks to other formats
  ==========================================================

  Copyright © 2017-2020 Benct Philip Jonsson, Albert Krewinkel

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]

local stringify_orig = (require 'pandoc.utils').stringify

local function stringify(x)
  return type(x) == 'string' and x or stringify_orig(x)
end

--- Pagebreaks for each output format
local pagebreak = {
  asciidoc = '<<<\n\n',
  context = '\\page',
  epub = '<p style="page-break-after: always;"> </p>',
  html = '<div style="page-break-after: always;"></div>',
  latex = '\\newpage{}',
  ms = '.bp',
  ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
  odt = '<text:p text:style-name="Pagebreak"/>'
}

local function pagebreaks_from_config (meta)
  local html_class =
    (meta.newpage_html_class and stringify(meta.newpage_html_class))
    or os.getenv 'PANDOC_NEWPAGE_HTML_CLASS'
  if html_class and html_class ~= '' then
    pagebreak.html = string.format('<div class="%s"></div>', html_class)
  end

  local odt_style =
    (meta.newpage_odt_style and stringify(meta.newpage_odt_style))
    or os.getenv 'PANDOC_NEWPAGE_ODT_STYLE'
  if odt_style and odt_style ~= '' then
    pagebreak.odt = string.format('<text:p text:style-name="%s"/>', odt_style)
  end
end

--- Return a block element causing a page break in the given format.
local function newpage(format)
  if format:match 'asciidoc' then
    return pandoc.RawBlock('asciidoc', pagebreak.asciidoc)
  elseif format == 'context' then
    return pandoc.RawBlock('context', pagebreak.context)
  elseif format == 'docx' then
    return pandoc.RawBlock('openxml', pagebreak.ooxml)
  elseif format:match 'epub' then
    return pandoc.RawBlock('html', pagebreak.epub)
  elseif format:match 'html.*' then
    return pandoc.RawBlock('html', pagebreak.html)
  elseif format:match 'latex' then
    return pandoc.RawBlock('tex', pagebreak.latex)
  elseif format:match 'ms' then
    return pandoc.RawBlock('ms', pagebreak.ms)
  elseif format:match 'odt' then
    return pandoc.RawBlock('opendocument', pagebreak.odt)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function is_newpage_command(command)
  return command:match '^\\newpage%{?%}?$'
    or command:match '^\\pagebreak%{?%}?$'
end

--[[
  ======================
  WORD TABLE OF CONTENTS
  ======================
  adds a table of contents in Word formats if \wordtoc string found
]]

-- Word ToC shortcode in XML
local toccode = {
  ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p><w:sdt><w:sdtPr><w:docPartObj><w:docPartGallery w:val="Table of Contents" /><w:docPartUnique /></w:docPartObj></w:sdtPr><w:sdtContent><w:p><w:pPr><w:pStyle w:val="TOCHeading" /></w:pPr><w:r><w:t>Contents</w:t></w:r></w:p><w:p><w:r><w:fldChar w:fldCharType="begin" w:dirty="true" /><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText><w:fldChar w:fldCharType="separate" /><w:fldChar w:fldCharType="end" /></w:r></w:p></w:sdtContent></w:sdt><w:p><w:r><w:br w:type="page"/></w:r></w:p>'
}

--- Function that returns a block element that inserts a Word ToC field
local function wordtoc(format)
  if format:match 'docx' then
    return pandoc.RawBlock('openxml', toccode.ooxml)
  elseif format:match 'latex' then
    return pandoc.RawBlock('latex', '')
  end
end

--- Function to check for \wordtoc string in document
local function is_wordtoc_command(command)
  return command:match '^\\wordtoc%{?%}?$'
end

--[[
  ===============
  RAWBLOCK FILTER
  ===============
  Filter function called on each LaTeX RawBlock element, that
  then actually applies either the wordtoc or pagebreak
  functions from above.
]]

function RawBlock (el)
  -- check that the block is TeX or LaTeX and contains
  -- only \wordtoc and return code for word toc
  if el.format:match 'tex' and is_wordtoc_command(el.text) then
    return wordtoc(FORMAT)
  -- check that the block is TeX or LaTeX and contains
  -- only \newpage or pagebreak, and return code for 
  -- pagebreak for format
  elseif el.format:match 'tex' and is_newpage_command(el.text) then
    return newpage(FORMAT)
  end
  -- otherwise, leave the block unchanged
  return el
end

return {
  {RawBlock = RawBlock, Div = Div, Span = Span, Header = Header, HorizontalRule = HorizontalRule, Image = Image}
}