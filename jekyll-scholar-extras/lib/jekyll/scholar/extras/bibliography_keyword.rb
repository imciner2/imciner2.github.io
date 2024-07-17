module Jekyll
  class Scholar

    class BibliographyTagKeyword < Liquid::Tag
      include Scholar::Utilities
      include ScholarExtras::Utilities

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup
        @config_extras = ScholarExtras.extra_defaults.dup

        #puts @config_extras

        #puts @config_extras['parse_extra_fields']

        optparse(arguments)

      end

      def initialize_type_counts()
        @type_counts = Hash[{ :article => 0,
                              :inproceedings => 0,
                              :incollection=> 0,
                              :techreport => 0,
                              :book => 0,
                              :unpublished => 0,
                              :patent => 0,
                              :thesis => 0
                            }]

        @type_counts.keys.each { |t|
          bib = bibliography.query('@*') { |b| b.type == t }
          @type_counts[t] = bib.size
        }
      end

      def get_entries_by_type(keyword, type)
        b = bibliography.query('@*') { |item|
          (get_entry_keywords(item).include?(keyword) && item.type == type)
        }
      end

      def render_keyword(y)
        ys = content_tag "h2", y, { :class => "csl-year-header" }
        ys = content_tag "div", ys, { :class => "csl-year-icon" }
      end

      def entries_keyword(keyword)
        b = bibliography.query('@*') { |a| get_entry_keywords(a).include?(keyword) }
      end

      def initialize_unique_keywords
        # Get an array of keywords and then uniquify them.
        arr = Array.new
        entries.each { |i| get_entry_keywords(i).each { |k| arr.push(k) } }
        @arr_unique = arr.uniq
        @arr_unique.sort!
      end

      def assign_identifiers()
        b = entries.sort_by{ |e| Date.parse(e.year.to_s + '-' + e.month.to_s + '-01' ) }
        b.reverse!

        @entry_id = Hash.new

        b.each{ |e| @entry_id[e.key] = generate_prefix_string(e) }
      end

    def generate_prefix_string(item)
      si = '[' + @prefix_defaults[item.type].to_s + @type_counts[item.type].to_s + ']'
      @type_counts[item.type] = @type_counts[item.type].to_i - 1

      return si
    end

    # Generate the index using csl-index.
    def render_index(item, ref)
      idx_html = content_tag "span", @entry_id[item.key], { :class => "csl-index" }
      return idx_html + ref
    end

    def render(context)
      set_context_to context

      # Initialize the number of each type of interest.
      initialize_type_counts()
      initialize_prefix_defaults()
      initialize_unique_keywords()

      assign_identifiers()

      # Iterate over unique keywords, and produce the bib.
      bibliography = ""

      # Construct the keyword selection box
      options = "\n"
      hide_div = ""
      @arr_unique.each{ |key|
        lowcase_key = key.downcase.gsub(/\s/, '_')
        options << content_tag( "option", key, {:value => lowcase_key} ) << "\n"
        hide_div << "document.getElementById('div-" << lowcase_key << "').style.display = 'none';" << "\n"
      }

      bibliography << "\n\n" << content_tag( "h2", "Topic:") << "\n"
      bibliography << content_tag( "select", options, {:id => "keyword_navigation", :onchange => "keywordSelect(this)"} ) << "\n\n"

      script_contents = "\n"
      script_contents << "function keywordSelect(param) {\n"
      script_contents << hide_div
      script_contents << "document.getElementById('div-' + param.value).style.display = 'block';" << "\n"
      script_contents << "}" << "\n"


      bibliography << content_tag( "script", script_contents, {:type => "text/javascript"} ) << "\n\n"

      first_entry = true

      # Construct each keyword part
      @arr_unique.each { |key|
        key_contents = render_keyword(key)
        items = entries_keyword(key)
        items.sort_by!{ |e| Date.parse(e.year.to_s + '-' + e.month.to_s + '-01' ) }
        items.reverse!
        key_contents << items.each_with_index.map { |entry, index|
          entry.bibtype = 'keyword'
          reference = render_index(entry, bibliography_tag(entry, nil))

          # Content tag is dependent on type of article.
          content_tag "li", reference, { :class => render_ref_img(entry) }
        }.join("\n")

        if first_entry
          style_tag = "display: block;"
          first_entry = false
        else
          style_tag = "display: none;"
        end

        bibliography << content_tag( "div", key_contents, { :id => "div-" + key.downcase.gsub(/\s/, '_'), :style => style_tag } )
      }.join("")
      return content_tag config['bibliography_list_tag'], bibliography, :class => config['bibliography_class']
    end
    end
  end
end

Liquid::Template.register_tag('bibliography_keyword', Jekyll::Scholar::BibliographyTagKeyword)
