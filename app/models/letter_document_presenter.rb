class  LetterDocumentPresenter < Blacklight::DocumentPresenter
  def document_heading
    type  = @document.first(:cat_ssi).to_s
    title = 'Ingen titel'
    if (type == 'letter')
      title = "Brev fra "+@document.first(:sender_ssim).to_s + " til " + @document.first(:recipient_ssim).to_s
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