# frozen_string_literal: true
module Requests
  module RequestHelper
    def parse_json(data)
      JSON.parse(data).with_indifferent_access
    end

    def current_user_status(current_user)
      ## Expect that the host app can provide you a devise current_user object
      if current_user.cas_provider? # || current_user.barcode_provider?
        content_tag(:div, class: "flash_messages-user") do
          content_tag(:div, I18n.t('requests.account.pul_auth', current_user_name: current_user.uid), class: "flash-alert")
        end
      elsif current_user.guest?
        content_tag(:div) do
          concat link_to I18n.t('blacklight.login.netid_login_msg'), '/users/auth/cas', role: 'menuitem', class: 'btn btn-primary', id: 'cas-login' # , current_user_name: current_user.uid)
        end
      else
        I18n.t('requests.account.unauthenticated')
      end
    end

    # No longer used
    # def active_user current_user
    #   if current_user.cas_provider? || current_user.barcode_provider?
    #     link_to "#{I18n.t('requests.account.logged_in')}#{current_user.uid}", '/users/sign_out'
    #   else
    #     link_to "PUL Users Sign In to Request", '/users/auth/cas'
    #   end
    # end

    def pul_patron_name(patron)
      return "" if patron.last_name.blank? && patron.first_name.blank?
      "#{patron.first_name} #{patron.last_name}"
    end

    def request_title
      if @mode == 'trace'
        I18n.t('requests.trace.form_title')
      else
        I18n.t('requests.default.form_title')
      end
    end

    ### FIXME. This should come directly as a sub-property from the request object holding property.
    # def render_mfhd_message requestable_list
    #   mfhd_services = []
    #   requestable_list.each do |requestable|
    #     requestable.services.each do |service|
    #       mfhd_services << service
    #     end
    #   end
    #   mfhd_services.uniq!
    #   if mfhd_services.include? 'paging'
    #     content_tag(:div, class: 'flash_mesages-mfhd flash-notice') do
    #       concat content_tag(:div, I18n.t('requests.paging.status').html_safe)
    #       concat content_tag(:div, I18n.t('requests.paging.message').html_safe)
    #     end
    #   end
    # end

    def return_message(submission)
      link_to "Return to Record", return_url(submission.id), class: 'btn btn-secondary icon-moveback', title: 'Return to Record' unless submission.source.nil?
    end

    def login_url(request)
      url = "/requests/#{request.bib_id}?"
      params = []
      params.push("mfhd=#{request.mfhd}") unless request.mfhd.nil?
      params.push("source=#{request.source}") unless request.source.nil?
      url += params.join("&")

      url
    end

    def return_url(id)
      "/catalog/#{id}"
    end

    def zero_results_link(query_params, search_field)
      if Flipflop.reshare_for_borrow_direct?
        reshare_link(query_params, search_field)
      else
        borrow_direct_path(q: query_params)
      end
    end

    def reshare_link(query_params, search_field)
      if query_params
        "https://borrowdirect.reshare.indexdata.com/Search/Results?lookfor=#{query_params}&type=#{reshare_type(search_field)}"
      else
        "https://borrowdirect.reshare.indexdata.com/Search/Results"
      end
    end

    def reshare_type(search_field)
      case search_field
      when 'all_fields'
        'AllFields'
      when 'author'
        'Author'
      when 'subject'
        'Subject'
      when 'title'
        'Title'
      else
        'AllFields'
      end
    end
  end
end
