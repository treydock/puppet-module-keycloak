# frozen_string_literal: true

module PuppetX # rubocop:disable Style/ClassAndModuleChildren
  module Keycloak # rubocop:disable Style/ClassAndModuleChildren
    # Module for shared type configs
    module Type
      def add_autorequires(realm = true)
        autorequire(:keycloak_conn_validator) do
          requires = []
          catalog.resources.each do |resource|
            if resource.class.to_s == 'Puppet::Type::Keycloak_conn_validator'
              requires << resource.name
            end
          end
          requires
        end

        autorequire(:file) do
          ['kcadm-wrapper.sh']
        end

        if realm # rubocop:disable Style/GuardClause
          autorequire(:keycloak_realm) do
            [self[:realm]]
          end
        end
      end
    end
  end
end
