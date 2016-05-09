module AccountHelper
  ## Helpers available to accounts.
  ## FIXME - Move to
  ### Setup item status
  ITEM_STATUS = begin
                  YAML.load_file("#{Rails.root}/config/voyager_item_status.yml")
                rescue
                  {}
                end

  def item_status_to_label(item)
    ITEM_STATUS[item['statusCode'].to_i]
  end

  def format_date(raw_date)
    raw_date.to_time.in_time_zone.strftime('%B %e %Y at %l:%M %p')
  end

  def format_block_statement(block_message)
    if block_message == "odue_recall_limit_patron"
      I18n.t('blacklight.account.overdue_block')
    end
  end

  def format_hold_cancel(item)
    "item-#{item['itemID']}:holdrecall-#{item['holdRecallID']}:type-#{item['holdType']}"
  end

  def format_renew_string(item)
    (item['itemId']).to_s
  end

  def display_account_balance(fine_fee)
    (fine_fee['balanceTotal']).to_s.strip.gsub(/\n\s+/, ' ')
  end

  def message_status(item)
    unless item[:messages].nil?
      content_tag(:span, (item[:messages]['message']).to_s, class: "message")
    end
  end

  def renew_status(item)
    unless item[:renew_status].nil?
      content_tag(:b, (item[:renew_status]['status']).to_s)
    end
  end

  def renew_state(item)
    unless item[:renew_status].nil?
      if item[:renew_status]["status"] == 'Renewed'
        "success"
      else
        "danger"
      end
    end
  end

  def charged_item_callnum(item)
    if !item["callNumber"].empty?
      item["callNumber"]
    elsif item["locationCode"] == 'bdirect'
      "Borrow Direct"
    end
  end
end
