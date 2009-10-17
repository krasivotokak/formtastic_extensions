require 'validation_reflection'
require 'formtastic'
require 'formtastic_extensions/semantic_form_builder'

module FormtasticExtensions
  def self.locale_files
    Dir[File.join(File.dirname(__FILE__), 'milk', 'locales', '*')]
  end
end
