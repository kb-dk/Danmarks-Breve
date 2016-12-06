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
    # The following fields can have 3 different "values": They can be nil or [""] or [" "].
    # If either of these is true, then we give the ukendt value, or else we make a sentence of the array values.
    (self.field_has_real_value? :recipient_tesim) ? recipient = doc['recipient_tesim'].to_sentence(:last_word_connector => ' og ') : recipient = "ukendt"
    (self.field_has_real_value? :sender_tesim) ? sender = doc['sender_tesim'].to_sentence(:last_word_connector => ' og ') :sender = "ukendt"
    (self.field_has_real_value? :date_ssim) ? date = doc['date_ssim'].to_sentence() : date = "dato ukendt"
    # We build the title of the letter
    title = " BREV "
    title += "TIL: " + recipient + " "
    title += "FRA: " + sender + " "
    title += " (" + date + ")"

    # Find the volume which belongs in
    volume = Finder.get_doc_by_id(doc['volume_id_ssi']).first
    auth = volume['author_name_tesim'].to_sentence(:two_words_connector => ' og ', :last_word_connector => ' og ')

    # Build the whole reference sentence, with the letter title and volume metadata
    cite = ""
    cite +=  auth.to_s  + ", " unless auth.to_s.blank?
    cite +=  volume['published_date_ssi'] + ". " unless volume['published_date_ssi'].blank?
    cite +=  title
    cite +=  " i: <i>"+volume['volume_title_tesim'].first + "</i>, " unless volume['volume_title_tesim'].blank?
    cite +=  "side "+doc['page_ssi'] + ". " unless doc['page_ssi'].blank?
    cite +=  volume['publisher_name_ssi'] + ", " unless volume['publisher_name_ssi'].blank?
    cite +=  volume['published_place_ssi'] + ". " unless volume['published_place_ssi'].blank?

    cite.html_safe

  end

  # Check if a field exists or has a "real" value
  def field_has_real_value? field
    real_value = false
    if self.key? field # if the field exists in the document
      if !(self.fetch field).first.blank? # if its value is not empty nor whitespace
        real_value =  true # only then the key has a real value
      end
    end
    return real_value
  end

end
