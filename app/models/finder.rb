# This class should be called statically to execute common Solr queries
class Finder

  def self.get_num_of_letters(lb_id)
    solr_q = "volume_id_ssi:\"#{lb_id}\""
    solr = RSolr.connect :url => "#{Rails.application.config_for(:blacklight)["url"]}"
    response = solr.get 'select', :params => {:q => solr_q, :fq => 'cat_ssi:letter'}
    return response['response']['numFound']
  end

end
