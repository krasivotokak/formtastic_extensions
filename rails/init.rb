require 'formtastic_extensions'

ActionView::Base.send :include, Formtastic::SemanticFormHelper
Formtastic::SemanticFormHelper.builder = FormtasticExtensions::SemanticFormBuilder
I18n.load_path.unshift(*FormtasticExtensions.locale_files)
