shared_context "keycloak::service" do
  it do
    is_expected.to contain_service('keycloak').only_with({
      :ensure      => 'running',
      :enable      => 'true',
      :name        => 'keycloak',
      :hasstatus   => 'true',
      :hasrestart  => 'true',
    })
  end
end
