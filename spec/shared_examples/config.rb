shared_context "keycloak::config" do
  it do
    is_expected.to contain_exec('create-keycloak-admin').with({
      :command => '/opt/keycloak-3.0.0.Final/bin/add-user-keycloak.sh --user admin --password changeme --realm master && touch /opt/keycloak-3.0.0.Final/.create-keycloak-admin-h2',
      :creates => '/opt/keycloak-3.0.0.Final/.create-keycloak-admin-h2',
    })
  end
end
