# frozen_string_literal: true

module TenantRealm
  class Helpers
    class << self
      def wrap_array(data)
        return [] if data.blank?

        data.is_a?(Array) ? data : [data]
      end

      def dev_log(message)
        p message if Rails.env.development?
      end

      def raise_if_not_proc(source, name)
        raise Error, "#{name} must be a Proc" unless source.is_a?(Proc)
      end
    end
  end
end
