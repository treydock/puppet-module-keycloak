shared_context "keycloak::config" do
  it do
    is_expected.to contain_exec('create-keycloak-admin').with({
      :command => '/opt/keycloak-2.5.4.Final/bin/add-user-keycloak.sh --user admin --password changeme --realm master && touch /opt/keycloak-2.5.4.Final/.create-keycloak-admin',
      :creates => '/opt/keycloak-2.5.4.Final/.create-keycloak-admin',
    })
  end
end
