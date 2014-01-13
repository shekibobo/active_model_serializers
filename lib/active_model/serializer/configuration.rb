require 'singleton'

module ActiveModel
  class Serializer
    class GlobalConfiguration
      include Singleton

      class << self
        def default_options
          { embed: :objects, meta_key: :meta }
        end
      end

      attr_accessor :root, :embed, :embed_in_root

      def initialize
        self.class.default_options.each do |name, value|
          send "#{name}=", value
        end
      end

      def method_missing(*)
        nil
      end

      def respond_to?(*)
        true
      end
    end

    class ClassConfiguration
      attr_accessor :parent
      attr_writer :root, :embed, :embed_in_root

      def initialize(parent = GlobalConfiguration.instance, options = {})
        @parent        = parent
        @root          = read_option options, :root
        @embed         = read_option options, :embed
        @embed_in_root = read_option options, :embed_in_root
      end

      def build(options = {})
        self.class.new options, self
      end

      def root
        return_first @root, parent.root
      end

      def embed
        return_first @embed, parent.embed
      end

      def embed_in_root
        return_first @embed_in_root, parent.embed_in_root
      end

      # FIXME: Get rid of this mess.
      def embed_objects=(value)
        @embed = :objects if value
      end

      # FIXME: Get rid of this mess.
      def embed_ids=(value)
        @embed = :ids if value
      end

      def embed_objects
        [:objects, :object].include? embed
      end

      def embed_ids
        [:ids, :id].include? embed
      end

      private

      def read_option(options, name)
        options[name] || false if options.has_key? name
      end

      def return_first(*values)
        values.compact.first
      end
    end

    class InstanceConfiguration < ClassConfiguration
      # FIXME attr_reader :scope needed
      attr_writer :scope, :meta, :meta_key
      attr_accessor :wrap_in_array

      def initialize(parent, options)
        super
        @scope         = options[:scope]
        @meta_key      = read_option options, :meta_key
        @meta          = read_option options, meta_key
        @wrap_in_array = options[:_wrap_in_array]
      end

      def meta_key
        return_first @meta_key, parent.meta_key
      end

      def meta
        return_first @meta, parent.meta
      end
    end

    class ArrayConfiguration
      attr_accessor :each_serializer, :resource_name

      def initialize(parent = GlobalConfiguration.instance, options = {})
        @parent = parent
        @each_serializer = options[:each_serializer]
        @resource_name   = options[:resource_name]
      end
    end
  end
end
