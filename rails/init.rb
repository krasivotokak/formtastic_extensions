require 'milk'

ActionView::Base.send :include, Formtastic::SemanticFormHelper
Formtastic::SemanticFormHelper.builder = Milk::SemanticFormBuilder
I18n.load_path.unshift(*Milk.locale_files)
