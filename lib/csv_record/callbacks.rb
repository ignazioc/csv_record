# frozen_string_literal: true

require_relative 'callback'

module CsvRecord::Callbacks
  CALLBACK_TYPES = [
    :after_initialize,
    :after_find,
    :before_validation,
    :after_validation,
    :before_save,
    :after_save,
    :after_destroy,
    :before_destroy,
    :before_create,
    :after_create,
    :before_update,
    :after_update
  ].freeze

  module ClassMethods
    CALLBACK_TYPES.each do |callback_type|
      define_method callback_type do |*args, &block|
        const_variable = "#{callback_type}_callbacks".upcase
        const_set(const_variable, []) unless const_defined? const_variable
        if block
          const_get(const_variable) << CsvRecord::Callback.new(callback_type, block)
        end
      end
    end

    def find(*args)
      result = super
      result.send :run_after_find_callbacks
      result
    end
  end

  module InstanceMethods
    CALLBACK_TYPES.each do |type|
      define_method "run_#{type}_callbacks" do
        const_variable = "#{type}_callbacks".upcase
        if self.class.const_defined? const_variable
          callbacks_collection = self.class.const_get const_variable
          callbacks_collection.each do |callback|
            callback.run_on self
          end
        end
      end
    end

    [:build, :initialize].each do |initialize_method|
      define_method initialize_method do |*args|
        result = super(*args)
        run_after_initialize_callbacks
        result
      end
    end

    def valid?
      run_before_validation_callbacks
      is_valid = super
      run_after_validation_callbacks if is_valid
      is_valid
    end

    def destroy
      run_before_destroy_callbacks
      is_destroyed = super
      run_after_destroy_callbacks if is_destroyed
      is_destroyed
    end

    def save(*args)
      run_before_save_callbacks
      is_saved = super
      run_after_save_callbacks if is_saved
      is_saved
    end

    def append_registry
      run_before_create_callbacks
      is_saved = super
      run_after_create_callbacks if is_saved
      is_saved
    end

    def update_registry
      run_before_update_callbacks
      saved = super
      run_after_destroy_callbacks if saved
      run_after_update_callbacks if saved
      saved
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end
end
