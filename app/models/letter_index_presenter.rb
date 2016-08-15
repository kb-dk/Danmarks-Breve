class LetterIndexPresenter < Blacklight::IndexPresenter
  def label(field_or_string_or_proc, opts = {})
    type = @document.first(:cat_ssi).to_s
    title = 'Ingen titel'
    if (type == 'letter')
      recipient = @document.first(:recipient_tesim).to_s
      sender = @document.first(:sender_etsim).to_s
      date = @document.first(:date_ssim).to_s
      title = "BREV "
      recipient.first.present? ? title += "TIL: " + recipient : title = 'TIL: ukendt'
      sender.first.present? ? title += " FRA: " + sender : title += ' FRA: ukendt'
      date.first.present? ? title += " DATO: " + date : title += ' DATO: ukendt'
    end
    if (type == 'letterbook')
      title = @document.first(:volume_title_ssim).to_s
    end
    if (type == 'person')
      title = @document.first(:given_name_ssi) +' '+ @document.first(:family_name_ssi)
    end
    title
  end
end