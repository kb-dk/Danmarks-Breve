module ApplicationHelper

  def translate_model_names(name)
    I18n.t("models.#{name}")
  end

  # Helper method to show the volume title at the letter index
  def show_volume_link args
    # Find the id of the volume in the letter's metadata
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    # Use the Finder to get the document and its title
    title = Finder.get_doc_by_id(id).first['volume_title_ssim'].first
    # Make a link with the volume title as a label that redirects you to the volume landing page
    link_to title, solr_document_path(id)
    # In case we have no volume data we rescue
    rescue
  end

  # Helper method to show link to the location on the google map for Afsendelsessted and Modtagelsessted
  def google_map_link args
    # Find the field value and convert array to a comma separated string
    location = args[:value].join(', ')
    return unless location.present?
    # Make a link to google map in a new tab/window
    link_to location, "https://www.google.dk/maps/place/"+location, :target => "_blank"
  end

  def present_snippets args
    val = args[:value]
    return unless val.present?
    term_freq = args[:document]['termfreq(text_tesim, $q)']
    snippets = ('...' + val.join('...'))
    "<strong>#{term_freq}</strong> #{snippets}".html_safe
  end

end
