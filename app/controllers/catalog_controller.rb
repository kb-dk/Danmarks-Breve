# frozen_string_literal: true
class CatalogController < ApplicationController

  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller

  include Blacklight::Catalog

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
        :qt => 'search',
        :rows => 10,
        :fq => '!cat_ssi:text',
        :hl => 'true',
        :'hl.snippets' => '3',
        :'hl.simple.pre' => '<em class="highlight" >',
        :'hl.simple.post' => '</em>'
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1
    #  # q: '{!term f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'volume_title_tesim'
    config.index.display_type_field = 'cat_ssi'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'cat_ssi', :label => I18n.t('blacklight.search.categori'), helper_method: :translate_model_names
    config.add_facet_field 'sender_ssim', :label => "Afsender"
    config.add_facet_field 'recipient_ssim', :label => "Modtager"
    config.add_facet_field 'year_itsi', label: 'Afsendelsesdato',
                           range: {
                               num_segments: 10,
                               assumed_boundaries: [1900, Time.now.year + 2],
                               segments: true,
                               maxlength: 4
                           }
   

    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['cat_ssi', 'language_facet']
    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #    :years_5 => { label: 'within 5 Years', fq: "published_date_ssi:[#{Time.zone.now.year - 5 } TO *]" },
    #    :years_10 => { label: 'within 10 Years', fq: "published_date_ssi:[#{Time.zone.now.year - 10 } TO *]" },
    #    :years_25 => { label: 'within 25 Years', fq: "published_date_ssi:[#{Time.zone.now.year - 25 } TO *]" }
    # }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'author_name_tesim', :label => 'Forfatter'
    config.add_index_field 'publisher_name_ssi', :label => 'Udgiver'
    config.add_index_field 'published_place_ssi', :label => 'Udgivelsessted'
    config.add_index_field 'published_date_ssi', :label => 'Udgivelsesdato'

    # this adds basic highlighting to index results
    config.add_index_field 'text_tesim', :highlight => true, :label => I18n.t('blacklight.search.index.in_text'), helper_method: :present_snippets, short_form: true

    # Letter specific metadata
    config.add_index_field 'volume_title_tesim', :label => I18n.t('blacklight.search.part_of'), helper_method: :show_volume_link
    config.add_index_field 'sender_location_tesim', :label =>  I18n.t('blacklight.search.senders_location')
    config.add_index_field 'recipient_location_tesim', :label => I18n.t('blacklight.search.recipients_location')

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display

    # Letter specific metadata
    config.add_show_field 'sender_tesim', :label => I18n.t('blacklight.search.sender'), :separator_options => {:last_word_connector => ' '+I18n.t('blacklight.and')+' '}
    config.add_show_field 'recipient_tesim', :label => I18n.t('blacklight.search.recipient'), :separator_options => {:last_word_connector => ' '+I18n.t('blacklight.and')+' '}
    config.add_show_field 'sender_location_tesim', :label =>  I18n.t('blacklight.search.senders_location')
    config.add_show_field 'recipient_location_tesim', :label => I18n.t('blacklight.search.recipients_location')
    config.add_show_field 'author_name_tesim', :label => 'Forfatter'
    config.add_show_field 'date_ssim', :label => I18n.t('blacklight.date')
    config.add_show_field 'publisher_name_ssi', :label => 'Udgiver'
    config.add_show_field 'published_date_ssi', :label => 'Udgivelsesdato'
    config.add_show_field 'published_place_ssi', :label => 'Udgivelsessted'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field(I18n.t('blacklight.search.all_fields')) do |field|

    end


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field( I18n.t('blacklight.search.sender')) do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :fq => 'cat_ssi:letter' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
          qf: '$sender_qf',
          pf: '$sender_pf'
      }
    end

    config.add_search_field( I18n.t('blacklight.search.recipient')) do |field|
      field.solr_parameters = { :fq => 'cat_ssi:letter' }
      field.solr_local_parameters = {
          qf: '$recipient_qf',
          pf: '$recipient_pf'
      }
    end

    config.add_search_field( I18n.t('blacklight.search.senders_location')) do |field|
      field.solr_parameters = { :fq => 'cat_ssi:letter' }
      field.solr_local_parameters = {
          qf: '$sender_location_qf',
          pf: 'sender_location_pf'
      }
    end

    config.add_search_field( I18n.t('blacklight.search.recipients_location')) do |field|
      field.solr_parameters = { :fq => 'cat_ssi:letter' }
      field.solr_local_parameters = {
          qf: '$recipient_location_qf',
          pf: '$recipient_location_pf'
      }
    end



    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
    #   field.qt = 'search'
    #   field.solr_local_parameters = {
    #     qf: '$subject_qf',
    #     pf: '$subject_pf'
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # # except in the relevancy case).
    config.add_sort_field 'score desc', label: I18n.t('blacklight.search.form.sort.relevance')
    config.add_sort_field 'sortby_sender_ssi asc', label: I18n.t('blacklight.search.form.sort.sender')
    config.add_sort_field 'sortby_recipient_ssi asc', label: I18n.t('blacklight.search.form.sort.recipient')
    config.add_sort_field 'year_itsi asc', label: I18n.t('blacklight.search.form.sort.year')

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'

    config.index.document_presenter_class = LetterIndexPresenter
    config.show.document_presenter_class = LetterShowPresenter

    # Overwriting this method to enable pdf generation using WickedPDF
    # Unfortunately the additional_export_formats method was quite difficult t
    # to use for this use case.
    def show
      @response, @document = fetch URI.unescape(params[:id])
      respond_to do |format|
        format.html { setup_next_and_previous_documents }
        format.json { render json: { response: { document: @document } } }
        format.pdf { send_pdf(@document, 'text') }
        additional_export_formats(@document, format)
      end
    end

    def facsimile
      @response, @document = fetch URI.unescape(params[:id])
      respond_to do |format|
        format.pdf { send_pdf(@document, 'image') }
      end
    end

    # common method for rendering pdfs based on wicked_pdf
    # cache files in the public folder based on their id
    # perhaps using the Solr document modified field
    def send_pdf(document, type)
      name = document['work_title_tesim'].first.strip rescue document.id
      path = Rails.root.join('public', 'pdfs', "#{document.id.gsub('/', '_')}_#{type}.pdf")
      solr_timestamp = Time.parse(document.to_hash['timestamp'])
      file_mtime = File.mtime(path) if File.exist? path.to_s
      # display the cached pdf if solr doc timestamp is older than the file's modified date
      if File.exist? path.to_s and ((type == 'text' and solr_timestamp < file_mtime) or type == 'image')
        send_file path.to_s, type: 'application/pdf', disposition: :inline, filename: name+".pdf"
      else
        render pdf: name, footer: { right: '[page] af [topage] sider' },
        save_to_file: path
      end
    end


  end

  # This overwrites the default blacklight sms_mappings so that
  # the sms tool is not shown.
  def sms_mappings
    {}
  end


end
