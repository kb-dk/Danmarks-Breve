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

  # This function is used both for the citation where we need the url, and for the pdf footer
  # where we don't need it. So the default value is set to nil and we make a check inside for nil.
  def export_as_apa_citation_txt(url = nil)
    doc = self
    url = url[0, url.index('/citation')] unless url.nil? # Cut the citation part of the URL
    retrieved_date = Time.now # The current date of the citation
    # The following fields can have 3 different "values": They can be nil or [""] or [" "].
    # If either of these is true, then we give the ukendt value, or else we make a sentence of the array values.
    (doc.field_has_real_value? :recipient_tesim) ? recipient = doc['recipient_tesim'].to_sentence(:last_word_connector => ' og ') : recipient = "ukendt"
    (doc.field_has_real_value? :sender_tesim) ? sender = doc['sender_tesim'].to_sentence(:last_word_connector => ' og ') :sender = "ukendt"
    (doc.field_has_real_value? :date_ssim) ? date = doc['date_ssim'].to_sentence() : date = "dato ukendt"
    # We build the title of the letter
    title = " BREV "
    title += "TIL: " + recipient + " "
    title += "FRA: " + sender + " "
    title += " (" + date + ")"

    # Construct the whole citation
    cite = ""
    cite += "<i>" + title + "</i>, " + I18n.t('blacklight.application_name') + ". "
    cite += "Set d. " + retrieved_date.strftime("%d/%m-%Y")
    url.nil? ? cite += "." : cite += ", " + "URL: " + url

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
