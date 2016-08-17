class LetterShowPresenter < Blacklight::ShowPresenter
  def html_title
    type = @document.first(:cat_ssi).to_s
    node = @document.first(:type_ssi).to_s
    title = 'Ingen titel'
    if (type == 'letter')
      recipient = @document.first(:recipient_tesim).to_s
      sender = @document.first(:sender_tesim).to_s
      date = @document.first(:date_ssim).to_s
      title = "BREV "
      recipient.first.present? ? title += "TIL: " + recipient : title = 'TIL: ukendt'
      sender.first.present? ? title += " FRA: " + sender : title += ' FRA: ukendt'
      date.first.present? ? title += " (" + date + ")" : title += ' (dato ukendt)'
    end
    if (type == 'letterbook')
      title = @document.first(:volume_title_ssim).to_s
    end
    if (type == 'text' and node=='trunk')
      title = @document.first(:text_tesim).to_s[0..35] + "... "
    end
    if (type == 'person')
      title = @document.first(:given_name_ssi) +' '+ @document.first(:family_name_ssi)
    end
    title
  end

  def heading
    html_title
  end
end
