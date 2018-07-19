module PuppetX
  module Keycloak
    class ArrayProperty < Puppet::Property
      def insync?(is)
        if is.is_a?(Array) and @should.is_a?(Array)
          is.sort == @should.sort
        else
          is == @should
        end
      end

      def change_to_s(currentvalue, newvalue)
        currentvalue = currentvalue.join(',') if currentvalue != :absent
        newvalue = newvalue.join(',')
        super(currentvalue, newvalue)
      end

      def is_to_s(currentvalue)
        if currentvalue.is_a?(Array)
          currentvalue.join(',')
        else
          currentvalue
        end
      end
      alias :should_to_s :is_to_s
    end
  end
end