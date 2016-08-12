# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Corele
  use_extension(Blacklight::Document::DublinCore)

  def export_as_apa_citation_txt
    doc = self.to_hash
    cite = ""
    volume = Finder.get_doc_by_id(doc['volume_id_ssi']).first
    cite +=  volume['author_name_tesim'].to_sentence(:last_word_connector => ' og ') + ", " unless volume['author_name_tesim'].blank?
    cite +=  volume['published_date_ssi'] + ", " unless volume['published_date_ssi'].blank?
    cite +=  "<i>"+volume['volume_title_tesim'].first + "</i>, " unless volume['volume_title_tesim'].blank?
    cite +=  "side "+doc['page_ssi'] + ", " unless doc['page_ssi'].blank?
    cite +=  volume['published_place_ssi'] + ": " unless volume['published_place_ssi'].blank?
    cite +=  volume['publisher_name_ssi'] + " " unless volume['publisher_name_ssi'].blank?
    cite.html_safe
  end
end
