module ApplicationHelper

  def translate_model_names(name)
    I18n.t("models.#{name}")
  end

end
