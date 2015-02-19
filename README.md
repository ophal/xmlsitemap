## XML Sitemap

Generate XML sitemaps from Ophal content. It automatically creates an XML Sitemap
index (/sitemaps/index.xml) for each declared sitemap.


### Usage

Enable this module and implement hook xmlsitemap().


### Configuration

The only configuration available at the moment allows to enable/disable(default)
the example sitemap:

    settings.xmlsitemap.example = true


### Example

The following example creates a dummy XML sitemap at sitemaps/example.xml:

    --[[ Implements hook xmlsitemap().
    ]]
    function _M.xmlsitemap()
      local sitemaps = {}
    
      sitemaps['example'] = {
        callback = 'example',
      }
    
      return sitemaps
    end
    
    function _M.example()
      return {
        -- list of paths and their attributes
        {'', changed = time(),  freq = 'hourly', priority = '1.0'},
      }
    end


### TODO

- Database back-end and integration with core's content module,
- Configuration panel,
- Split xmlsitemaps by a configurable number of items.
