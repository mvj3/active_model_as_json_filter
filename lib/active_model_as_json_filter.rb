# encoding: UTF-8

module ::ActiveModel
  module AsJsonFilter

    extend ActiveSupport::Concern

    # 默认公共字段配置
    #
    # 以下是个属性在配置时直接覆盖即可。
    OptionMethods = [:default_only_fields, :default_except_fields, :default_methods_fields]
    mattr_accessor(*OptionMethods)

    mattr_accessor :finalizer_proc
    if not self.finalizer_proc # 避免重载时覆盖
      self.finalizer_proc = lambda {|hash| return hash } 
    end

    # 封装 as_json 参数
    class AsJsonOptions
      OptionFields = [:only, :except, :methods]
      attr_reader(*OptionFields)

      # 不要使用方法污染了方法空间。
      #
      # 比如: 可以在这里返回 键id 为别的非主键的值，以应对客户端刁难的需求。
      # self.as_json_options.finalizer_proc = lambda do |result, item|
      #   result['id']        = item.uuid.hash % 2**31
      #   return result
      # end
      attr_accessor :finalizer_proc

      class SetWithMultiplePush < Set
        undef :add
        def add *args
          Array(args).flatten.compact.each {|i| self << i }
        end
      end

      def initialize
        @only, @except, @methods = SetWithMultiplePush.new, SetWithMultiplePush.new, SetWithMultiplePush.new
        @finalizer_proc = lambda {|hash, item = nil| return hash.merge(Hash.new) }
      end
    end

    included do
      cattr_reader :as_json_options
      self.class_variable_set "@@as_json_options", AsJsonOptions.new

      # 输入配置字段
      OptionMethods.each do |fields|
        reader = fields.to_s.split('_')[1]
        Array(ActiveModel::AsJsonFilter.send(fields)).flatten.compact.each do |v|
          self.as_json_options.send(reader).add v if not self.as_json_options.send(reader).include? v
        end
      end
    end

    # InstanceMethods
    def as_json options = {}
      # 1. 配置参数
      _o = {}
      AsJsonOptions::OptionFields.each do |field|
        _v = Array(self.class.as_json_options.send(field)).flatten.to_a.map(&:to_sym)
        _o[field] = _v if not _v.empty?
      end
      result = super _o.merge(options)
      # 2. 两次全局和局部回调
      result = ActiveModel::AsJsonFilter.finalizer_proc.call(result)
      result = self.class.as_json_options.finalizer_proc.call(result, self)

      return result
    end

  end
end
