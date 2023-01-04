# frozen_string_literal: true
class Orangelight::SearchBarComponent < Blacklight::SearchBarComponent
  def search_fields
    @search_fields ||= blacklight_config.search_fields.values
                                        .reject { |field_def| field_def&.include_in_simple_select == false }
                                        .collect do |field_def|
      [field_def.dropdown_label || field_def.label,
       field_def.key,
       { 'data-placeholder' => (field_def.placeholder_text || t('blacklight.search.form.search.placeholder')) }]
    end
  end

  def before_render
    super
    return if @search_field

    @search_field = if params[:model] == Orangelight::CallNumber
                      'browse_cn'
                    elsif params[:model] == Orangelight::Name
                      'browse_name'
                    elsif params[:model] == Orangelight::NameTitle
                      'name_title'
                    elsif params[:model] == Orangelight::Subject
                      'browse_subject'
                    end
  end
end
