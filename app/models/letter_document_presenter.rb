class  LetterDocumentPresenter < Blacklight::DocumentPresenter
  def render_document_index_label(field, opts={})
    type  = @document.first(:cat_ssi)
    title = 'Ingen titel'
    if (type == 'letter')
      title = "Brev fra "+@document.first(:sender_ssim).to_s + " til " + @document.first(:receiver_ssim).to_s
    end
    if (type == 'letterbook')
      title = @document.first(:volume_title_ssim)
    end
    title
  end
end