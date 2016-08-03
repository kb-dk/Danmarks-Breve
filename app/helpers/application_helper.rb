module ApplicationHelper

  def translate_model_names(name)
    I18n.t("models.#{name}")
  end

  # Helper method to show the volume title at the letter index
  def show_volume_link args
    # Find the id of the volume in the letter's metadata
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    # MAke a direct search request to Solr with the volume id
    volume_url = Net::HTTP.get(URI("#{Rails.application.config_for(:blacklight)["url"]}/select?q="+URI.escape(id)+"&wt=json&indent=true"))
    # Parse the response as JSON
    volume_record_json = JSON.parse(volume_url)
    # Find the volume title in the JSON
    title = volume_record_json['response']['docs'].first['volume_title_ssim'].first
    # Make a link with the volume title as a label that redirects you to the volume landing page
    link_to title, solr_document_path(id)
  end

end
