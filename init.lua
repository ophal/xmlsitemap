local _M = {
  sitemaps = nil,
}
ophal.modules.xmlsitemap = _M

local seawolf = require 'seawolf'.__build('contrib')
local seawolf_table = seawolf.contrib.seawolf_table
local url, format_date, time = url, format_date, os.time
local config = settings.xmlsitemap or {}

function _M.init()
  local result = module_invoke_all('xmlsitemap')
  _M.sitemaps = seawolf_table(result)
end

--[[ Implements hook route().
]]
function _M.route()
  local items = {}

  items['sitemaps/index.xml'] = {
    page_callback = 'index',
    format = 'xmlsitemap_index',
  }

  _M.sitemaps:each(function(name, sitemap)
    items['sitemaps/' .. name .. '.xml'] = {
      page_callback = {sitemap.callback, module = sitemap.module},
      format = 'xmlsitemap',
    }
  end)

  return items
end

--[[ Implements hook xmlsitemap().
]]
function _M.xmlsitemap()
  local sitemaps = {}

  sitemaps['homepage'] = {
    callback = 'homepage',
  }

  if config.example then
    sitemaps['example'] = {
      callback = 'homepage',
    }
  end

  return sitemaps
end

function _M.index()
  local output = seawolf_table{
    '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
  }

  _M.sitemaps:each(function(name, sitemap)
    output:append(([[
 <sitemap>
    <loc>%s</loc>
    <lastmod>%s</lastmod>
 </sitemap>
    ]]):format(url('sitemaps/' .. name .. '.xml', {absolute = true}), format_date(time(), '!%Y-%m-%dT%H:%M:%SZ')))
  end)

  output:append '</sitemapindex>'

  return output:concat()
end

function _M.homepage()
  return {
    -- list of paths and their attributes
    {'', changed = time(),  freq = 'hourly', priority = '1.0'},
  }
end

function theme.xmlsitemap_index(variables)
  local content = variables.content or ''
  local output = '<?xml version="1.0" encoding="UTF-8"?>' .. content

  header('content-type', 'text/xml; charset=utf-8')
  header('content-length', (output or ''):len())
  return output
end

function theme.xmlsitemap(variables)
  local content
  local output = seawolf_table{[[<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ]]}

  if not variables.status then
    output:append '<error>'
    output:append(variables.content)
    output:append '</error>'
  else
    content = seawolf_table(variables.content or {})
    content:each(function (k, v)
      output:append [[<url>]]
      output:insert_multiple{'<loc>', url(v[1], {absolute = true}), '</loc>'}
      if v.changed then
        output:insert_multiple{'<lastmod>', format_date(v.changed, '!%Y-%m-%dT%H:%M:%SZ'), '</lastmod>'}
      end
      if v.freq then
        output:insert_multiple{'<changefreq>', v.freq, '</changefreq>'}
      end
      if v.priority then
        output:insert_multiple{'<priority>', v.priority, '</priority>'}
      end
      output:append [[</url>]]
    end)
  end

  output:append '</urlset>'

  output = output:concat()

  header('content-type', 'text/xml; charset=utf-8')
  header('content-length', (output or ''):len())

  theme_print(output)
end

return _M
