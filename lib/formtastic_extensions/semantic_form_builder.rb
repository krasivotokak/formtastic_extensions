module FormtasticExtensions
  class SemanticFormBuilder < Formtastic::SemanticFormBuilder
    @@all_fields_required_by_default = false
    @@i18n_lookups_by_default = true
    @@input_class = 'b_field'
    @@inputs_class = 'b_fields_set'
    @@buttons_class = 'b_buttons_set'
    cattr_accessor :input_class, :inputs_class, :butons_class

    def input(method, options = {})
      options[:required] = method_required?(method) unless options.key?(:required)
      options[:as]     ||= default_input_type(method)

      html_class = [ options[:as], (options[:required] ? :required : :optional) ]
      html_class << 'error' if @object && @object.respond_to?(:errors) && @object.errors[method.to_sym]

      wrapper_html = options.delete(:wrapper_html) || {}
      wrapper_html[:id]  ||= generate_html_id(method)
      wrapper_html[:class] = "#{@@input_class} #{(html_class << wrapper_html[:class]).flatten.compact.map{ |klass| "#{@@input_class}-#{klass}" }.join(' ')}"

      if [:boolean_select, :boolean_radio].include?(options[:as])
        ::ActiveSupport::Deprecation.warn(":as => :#{options[:as]} is deprecated, use :as => :#{options[:as].to_s[8..-1]} instead", caller[3..-1])
      end

      if options[:input_html] && options[:input_html][:id]
        options[:label_html] ||= {}
        options[:label_html][:for] ||= options[:input_html][:id]
      end

      input_parts = @@inline_order.dup
      input_parts.delete(:errors) if options[:as] == :hidden

      list_item_content = input_parts.map do |type|
        send(:"inline_#{type}_for", method, options)
      end.compact.join("\n")

      return template.content_tag(:li, list_item_content, wrapper_html)
    end

    def inputs(*args, &block)
      html_options = args.extract_options!
      html_options[:class] ||= @@inputs_class

      if html_options[:for]
        inputs_for_nested_attributes(args, html_options, &block)
      elsif block_given?
        field_set_and_list_wrapping(html_options, &block)
      else
        if @object && args.empty?
          args  = @object.class.reflections.map { |n,_| n if _.macro == :belongs_to }
          args += @object.class.content_columns.map(&:name)
          args -= %w[created_at updated_at created_on updated_on lock_version]
          args.compact!
        end
        contents = args.map { |method| input(method.to_sym) }

        field_set_and_list_wrapping(html_options, contents)
      end
    end

    def buttons(*args, &block)
      html_options = args.extract_options!
      html_options[:class] ||= @@buttons_class

      if block_given?
        field_set_and_list_wrapping(html_options, &block)
      else
        args = [:commit] if args.empty?
        contents = args.map { |button_name| send(:"#{button_name}_button") }
        field_set_and_list_wrapping(html_options, contents)
      end
    end

    def save_or_create_button_text(prefix = 'Submit')
      if @object
        prefix = @object.new_record? ? 'Create' : 'Save'
        object_name = @object.class.name.underscore
        i18n_prefix = prefix.downcase
      else
        object_name = @object_name.to_s.underscore
      end

      i18n_prefix = prefix.downcase
      I18n.t("formtastic.buttons.#{object_name}.#{i18n_prefix}",
             :default => [
               :"formtastic.buttons.#{i18n_prefix}",
               prefix])
    end
  end
end

