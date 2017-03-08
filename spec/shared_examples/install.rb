shared_context "keycloak::install" do
  it do
    is_expected.to contain_user('keycloak').only_with({
      :ensure     => 'present',
      :name       => 'keycloak',
      :forcelocal => 'true',
      :shell      => '/sbin/nologin',
      :gid        => 'keycloak',
      :home       => '/var/lib/keycloak',
      :managehome => 'true',
    })
  end
end
