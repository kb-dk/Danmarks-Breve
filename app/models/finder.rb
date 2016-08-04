# This class should be called statically to execute common Solr queries
class Finder

  def self.get_solr
     return RSolr.connect :url => "#{Rails.application.config_for(:blacklight)["url"]}"
  end

  # Function that returns the number of letters that are included in a volume/letterbook
  def self.get_num_of_letters(lb_id)
    solr_q = "volume_id_ssi:\"#{lb_id}\""
    response = get_solr.get 'select', :params => {:q => solr_q, :fq => 'cat_ssi:letter'}
    return response['response']['numFound']
  end

  # Function to return the solr document by id
  def self.get_doc_by_id(id)
    response = get_solr.get 'select', :params => {:q => id}
    return response['response']['docs']
  end

end
