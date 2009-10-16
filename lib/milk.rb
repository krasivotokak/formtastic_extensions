require 'validation_reflection'
require 'formtastic'
require 'milk/semantic_form_builder'

module Milk
  def self.locale_files
    Dir[File.join(File.dirname(__FILE__), 'milk', 'locales', '*')]
  end
end
