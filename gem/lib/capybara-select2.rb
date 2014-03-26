require "capybara-select2/version"
require 'rspec/core'

module Capybara
  module Select2
    def select2(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath'" unless options.is_a?(Hash) and [:from, :xpath].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        select2_container = first(:xpath, options[:xpath])
      else
        select_name = options[:from]
        label = first("label", text: select_name)
        if label
          select2_container = label.find(:xpath, '..').find(".select2-container")
        else
          # Check for placeholder
          select2_container = first(".select2-chosen", text: select_name).find(:xpath, "../..")
        end
      end

      if Capybara.current_driver == :selenium
        # trigger not supported by selenium
        page.execute_script("$('##{select2_container[:id]} .select2-choice').trigger('mousedown')")
      else
        select2_container.find(".select2-choice").trigger(:mousedown)
      end

      if options.has_key? :search
        find(:xpath, "//body").find("input.select2-input").set(value)
        page.execute_script(%|$("input.select2-input:visible").keyup();|)
        drop_container = ".select2-results"
      else
        drop_container = ".select2-drop"
      end

      [value].flatten.each do |value|
        # This failed the tests, why?
        #select2_container.find(:xpath, "a[contains(concat(' ',normalize-space(@class),' '),' select2-choice ')] | ul[contains(concat(' ',normalize-space(@class),' '),' select2-choices ')]").click

        find(:xpath, "//body").find("#{drop_container} li.select2-result-selectable", text: value).click
      end
    end
  end
end

RSpec.configure do |c|
  c.include Capybara::Select2
end
