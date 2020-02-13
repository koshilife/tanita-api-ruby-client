# frozen_string_literal: true

module Tanita
  module Api
    module Client
      class ClassBuilder
        def self.load
          return if loaded

          create_class('Result', %i[birth_date height sex items])
          base_properties = %i[measured_at registered_at model]
          [Innerscan, Sphygmomanometer, Pedometer, Smug].each do |klass|
            klass_name = klass.to_s.split('::')[-1] + 'Item'
            properties = base_properties + klass.properties.keys
            create_class(klass_name, properties)
          end
          @loaded = true
        end

        def self.loaded
          @loaded || false
        end
        private_class_method :loaded

        def self.create_class(class_name, property_names = [])
          super_klass = Class.new(BaseEntity)
          klass = Tanita::Api::Client.const_set(class_name, super_klass)
          define_properties_reader(klass)
          property_names.each do |property_name|
            klass.properties << property_name if klass.respond_to?(:properties)
            define_getter_and_setter(klass, property_name)
          end
          klass.properties.freeze if klass.respond_to?(:properties)
        end
        private_class_method :create_class

        def self.define_properties_reader(klass)
          klass.class_eval do
            def self.properties
              @properties = [] if @properties.nil?
              @properties
            end
          end
        end
        private_class_method :define_properties_reader

        def self.define_getter_and_setter(klass, property_name)
          klass.class_eval do
            define_method(property_name.to_sym) do
              @cached_property_values[property_name.to_sym]
            end
            define_method("#{property_name}=".to_sym) do |value|
              @cached_property_values[property_name.to_sym] = value
            end
          end
        end
        private_class_method :define_getter_and_setter
      end
    end
  end
end
