module Jekyll
  class ScholarExtras

     module Utilities
    # Return the extra configurations for parsing.
    def extra_parse_fields
      return @config_extras['parse_extra_fields']
    end

    # Generate the index using csl-index.
    def render_index(item, ref)
      si = '[' + @prefix_defaults[item.type].to_s + @type_counts[item.type].to_s + ']'
      @type_counts[item.type] = @type_counts[item.type].to_i - 1
      
      idx_html = content_tag "span", si, { :class => "csl-index" }
      return idx_html + ref
    end

    def get_entry_keywords(entry)
      if entry.field?(:keywords)
        key_arr = entry.keywords.split(',')
        key_arr.each{ |key| key.strip! }
        return key_arr
      else
        return []
      end
    end

    # Generate the publication type images.
    def render_ref_img(item)
      css_points = Hash[{
                          :article => "csl-point-journal-icon",
                          :unpublished => "csl-point-journal-icon",
                          :inproceedings => "csl-point-conference-icon",
                          :incollection=> "csl-point-bookchapter-icon",
                          :techreport => "csl-point-techreport-icon",
                          :patent => "csl-point-techreport-icon",
                          :book => "csl-point-book-icon",
                          :thesis => "csl-point-book-icon"
                        }]

      s = css_points[item.type]
      return s
    end

    # Look at the defaults for prefixes.
    # TODO: Should move this to defaults.
    def initialize_prefix_defaults() 
      @prefix_defaults = Hash[{
                                :article => "J",
                                :inproceedings => "C",
                                :incollection=> "BC",
                                :techreport => "TR",
                                :book => "B",
                                :thesis => "T",
                                :unpublished => "PP",
                                :patent => "PA"
                              }]
    end

    # Generate a link if an ACM PDF link exists.
    def render_acmpdf_link(entry)
      pdflink =""
      if entry.field?(:acmpdflink)
        pdflink = "<div class=\"pure-button csl-pdf\"><a href=\"" + entry.acmpdflink.to_s + "\">PDF</a></div>"
      end
      
      return pdflink
    end

    # Generate a SLIDES link. 
    def repository_slides_link_for(entry, base = base_url)
      links = repository[entry.key + "_slides"]
      url = links['pdf'] || links['pptx']
      return unless url

      File.join(base, url)
    end

    # Generate a BibTeX link. 
    def bibtex_link_for(entry, base = base_url)
      url=entry.key.to_s + ".bib"
      return base_url.to_s + "/" + repository_path.to_s + "/" + url.to_s
    end
    
    def split_reference(reference)
      #puts "## " + reference.to_s
#     # puts "\n"
      if !reference.nil? 
        xml = Nokogiri::HTML(reference.to_s)
        #puts "====B======"
 #       puts xml.css("div.csl-index")
        xml.css("div.csl-block.csl-title").each do |node|
          puts "==> " + node.text
        end
        #puts "====E====="
      end
    end

  end 
  end 

end 
