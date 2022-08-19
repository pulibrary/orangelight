# frozen_string_literal: true
def press_element(selector)
  find(selector).native.send_keys(:return)
end
