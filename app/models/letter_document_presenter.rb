class LetterDocumentPresenter < Blacklight::DocumentPresenter
  def document_heading
    type = @document.first(:cat_ssi).to_s
    title = 'Ingen titel'
    if (type == 'letter')
      recipient = @document.first(:recipient_ssim).to_s
      sender = @document.first(:sender_ssim).to_s
      date = @document.first(:date_ssim).to_s
      title = "BREV "
      recipient.first.present? ? title += "TIL: " + recipient : title = 'TIL: ukendt'
      sender.first.present? ? title += " FRA: " + sender : title += ' FRA: ukendt'
      date.first.present? ? title += " DATO: " + date : title += ' DATO: ukendt'
    end
    if (type == 'letterbook')
      title = @document.first(:volume_title_ssim)
    end
    title
  end

  def render_document_index_label(field, opts = {})
    document_heading
  end
end