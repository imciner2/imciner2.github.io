module Jekyll
  class Scholar

    class BibliographyTagByType < Liquid::Tag
      include Scholar::Utilities
      include ScholarExtras::Utilities 

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup
        
        optparse(arguments)
      end

      def initialize_type_labels()
        @type_labels =
          Hash[{ "@article" => "Peer-reviewed Journal Articles",
                 "@inproceedings" => "Peer-reviewed Conference and Workshop Papers",
                 "@incollection" => "Book Chapters",
                 "@techreport" => "Technical Reports",
                 "@book" => "Books",
                 "@thesis" => "Thesis",
                 "@patent" => "Patents",
                 "@unpublished" => "Preprints"
               }]
      end


      def set_type_counts(tc)
        @type_counts = tc
      end

      def render_index(item, ref)
        si = '[' + @prefix_defaults[item.type].to_s + @type_counts.to_s + ']'
        @type_counts = @type_counts - 1
        
        idx_html = content_tag "div", si, { :class => "csl-index"}
        return idx_html + ref
      end

      def render_header(y)
        ys = content_tag "h2", y, { :class => "csl-year-header" }
        ys = content_tag "div", ys, { :class => "csl-year-icon" }
      end

      def render(context)
        set_context_to context

        # Only select items that are public.
        items = entries.select { |e| entry_is_public(e) }

        initialize_prefix_defaults()
        initialize_type_labels()
        set_type_counts(items.size())

        if cited_only?
          items =
            if skip_sort?
              cited_references.uniq.map do |key|
              items.detect { |e| e.key == key }
            end
            else entries.select  do |e|
              cited_references.include? e.key
            end
            end
        end

        items = items[offset..max] if limit_entries?

        if items.size() == 0
          return
        end

        bibliography = render_header(@type_labels[query])
        bibliography << items.each_with_index.map { |entry, index|
          reference = render_index(entry, bibliography_tag(entry, nil))

          if generate_details?
            reference << link_to(details_link_for(entry), config['details_link'],
                                 :class => config['details_link_class'])
          end

          if entry.field?(:award)
            # TODO: Awkward -- Find position to insert it. Before the last </div>
            ts = content_tag "div", entry.award.to_s, { :class => "csl-award" }
            reference_position = reference.rindex('</div>')
            if reference_position.nil?
              puts "NILL"
            else 
              reference.insert(reference.rindex('</div>'), ts.to_s)
            end 
          end
          
          content_tag config['bibliography_item_tag'], reference
          content_tag "li", reference, { :class => render_ref_img(entry) }
        }.join("\n")


        content_tag config['bibliography_list_tag'], bibliography, :class => config['bibliography_class']
        
      end
    end

  end
end

Liquid::Template.register_tag('bibliography_bytype', Jekyll::Scholar::BibliographyTagByType)
