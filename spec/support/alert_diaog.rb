def accept_alert
  page.within_window(page.driver.window_handles.last).accept
#  page.driver.browser.switch_to.alert.accept
end
