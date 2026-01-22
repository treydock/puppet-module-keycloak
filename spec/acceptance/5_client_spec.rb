# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'keycloak_client define:', if: RSpec.configuration.keycloak_full do
  context 'when creates client' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'foo on test': ensure => 'present' }
      keycloak_client { 'test.foo.bar':
        realm                                    => 'test',
        root_url                                 => 'https://test.foo.bar',
        redirect_uris                            => ['https://test.foo.bar/test1'],
        default_client_scopes                    => ['address'],
        secret                                   => 'foobar',
        login_theme                              => 'keycloak',
        backchannel_logout_url                   => 'https://test.foo.bar/logout',
        backchannel_logout_session_required      => 'true',
        backchannel_logout_revoke_offline_tokens => 'true',
        authorization_services_enabled           => false,
        service_accounts_enabled                 => true,
        browser_flow                             => 'foo',
        roles                                    => ['bar_role', 'other_bar_role'],
      }
      keycloak_client { 'test.foo.baz':
        realm                                    => 'test',
        root_url                                 => 'https://test.foo.bar',
        redirect_uris                            => ['https://test.foo.bar/test1'],
        default_client_scopes                    => ['address'],
        secret                                   => 'foobar',
        login_theme                              => 'keycloak',
        backchannel_logout_url                   => 'https://test.foo.baz/logout',
        backchannel_logout_session_required      => 'false',
        backchannel_logout_revoke_offline_tokens => 'false',
        authorization_services_enabled           => false,
        service_accounts_enabled                 => true,
        browser_flow                             => 'foo',
      }
      keycloak_client { 'saml.foo.bar':
        realm                                   => 'test',
        root_url                                => 'https://saml.foo.bar/root',
        admin_url                               => 'https://saml.foo.bar/admin',
        base_url                                => 'https://saml.foo.bar',
        redirect_uris                           => ['https://saml.foo.bar/test1'],
        default_client_scopes                   => ['role_list'],
        protocol                                => 'saml',
        saml_name_id_format                     => 'transient',
        saml_artifact_binding_url               => 'https://saml.foo.bar/mellon/artifactResponse',
        saml_single_logout_service_url_redirect => 'https://saml.foo.bar/mellon/logout',
        saml_assertion_consumer_url_post        => 'https://saml.foo.bar/mellon/postResponse',
        saml_encrypt                            => 'true',
        saml_assertion_signature                => 'true',
        saml_client_signature                   => 'true',
        saml_signing_certificate                => 'MIIDQzCCAiugAwIBAgIUNALBnAmwcPKLdBer4e0i22JiEd0wDQYJKoZIhvcNAQELBQAwMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjAgFw0yMjAzMTgyMjU1MTNaGA8yMTIyMDIyMjIyNTUxM1owMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPKEr/vAExQ9LxF9oiiyz7JNdHgB8wxGEd5SN7YF6UOToLH2lQL5PelGnsVD13y9/ZN2qr3xl54zz8IT8EimT8YXc0k7JEDLnKrvkz/xGSKnSFnudNM7B6i2VgM7uMbCCKKbOlULALUUnUmOAsKjRyTjcue4D1tULnha+ph+h/1T9Oc0VmDf6BV54lEwOe7m7teOZCTnrM2Ll2dsZV2tgMywt87r9/yQWt3rbMjaVsLUsgV/SBd4RU6WDrsae6P7ccOWeoFyQ4fP7i7Z+Wpa8Y9pdnNraqBNmkKb4pNkW+sJkkfA47YHafAtQO4E1cOnlsKJo0fXeMgiViCoDLVYPwcCAwEAAaNTMFEwHQYDVR0OBBYEFMuSde+sXzqeWtZPfY7Bsun3h3fzMB8GA1UdIwQYMBaAFMuSde+sXzqeWtZPfY7Bsun3h3fzMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAF+KdjMVaLGJmbBpV+mw6G9QVZ8DkiMKKz5+K2usCMCVf9XWVIyYXExsTBACk1FObHjXfHkk1A9nXOEFqgPBVS8CgSspVfQjIGhDy1lwhPkDvtyuIKIDb2kf52xTru/bsAWuSEXcjbKqszN6l78AaR93n6sZKUkIsnDpvi/mG4xXBumiluJyedbQw9yj/NsYouALGWWQeHDwNJGcAxDxiLvIZjXkAo6IXRQ85n29TiLFCbF5hPmiBlUNfo5reuobvhd+qDZOssiJ4q4VrSkHZ/u4Ri623+dgyZbDqwQ20NigfuoRaxbFWxbjl5T/lg30r7sqy/YOW2wevA0wSqyxMfw=',
        saml_encryption_certificate             => 'MIIDSTCCAjGgAwIBAgIUbJ6dLiM4/T9uLT4gd13tuD469lkwDQYJKoZIhvcNAQELBQAwMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjAgFw0yMjAzMTgyMjU1NDlaGA8yMTIyMDIyMjIyNTU0OVowMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKmzbda8/vwS3vn1OflWhcquzhh+FphTCA4PoRsqT2/AE5cbEPqVdPQxIUVXNL+l4LM7Kl4H0vSoi3gHlH1SQCc/772gXDtByxHP0QYg+FaEIG+LbsFYeB1jJMhGblf+0xOH3uPtN9jzjkz8Xhzpcq/xgTOJDyQPfSamzW0xUtK3iXd8B7K9nNdmOm9uLPZ1p2JLhvOJu6I6dapjLDoWgJnSnaYMgRuxShktTafWU3wolyo6c6+wago/CaoEdlrcwO7VvOd/gdhAuYUhYypD7t+1mWisEBWxLo2omflr2rm2nWQX5EKx4U1lhEPxxlo0AkCCj/7hQyJt5jMzg/4QGNUCAwEAAaNTMFEwHQYDVR0OBBYEFMNcZ9lzmttxhrdVXLm+deYLJyjeMB8GA1UdIwQYMBaAFMNcZ9lzmttxhrdVXLm+deYLJyjeMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAEeYMFSGUGeWkgNKTmPL3l445ai4zMWUi92+vHeta44GlBKUAbNvC8Ab4mdVFCZF0lvKqUVfeKtTDD9wSko5XjjuhblLci7oa/gOFpp3dfb5d5xtNsSoVD9ndPopApYugGlKEJI9qL39FyP9Js+rm13gsHNrMGXIfBE+FSFXu0sp0NRBnbqvz5cB8jSRb40v67tGmFVadYhomIpFsES2FuM3bY6YbD0hJ4ozLczgpfPOYw41xIAGSgbB6rwRsu+VwV7L2DW3wtq6CHksLYoiNDmdZXz0HDqmfHcMKlpUPpAkY/8q6xaO/QNEzohI60TfMRklpCLP/25n4ao3VqrHdZo=',
        saml_signing_private_key                => 'MIIEpAIBAAKCAQEAtzXe4xaXsz5KdSQdz/4+jMdO1HiBNBuL2dIQ4b+DSP5IhSU+VPQP26G49fBWkN2ZSGMhOfvfxbcGjudIl7RRKRN1XqTgada/irqhU80Z8FTYWgl6A5px87nL1peCm8f2w6N220KLdoYI/KapdNP1CUXR6iBJOrEZ3lV3CtZR5DkeOvdMEsmyhP5ajI4PMKU15ANmq8S7vPd2q/OGSQziAj467gDFDTXTWVVo1vV1HWSz9an2wdIU7XdgrzRbuuCvgb5LLpbdyy+3j3RieoQAiDAiabKZqSMhiYc6mx21tD7ppN+H6RqzRulj/7WLdxckEJ736s1xSk8boOQhEqPoIQIDAQABAoIBAQCn3aQrTjgQ87IlQsJOIRYOx09jPkakB9lL6z2sml0gNF0eIdHK5RTimHtwXJX0hhY8TRfUmQOflONdbG0HEyCKElooLcmxMCKwafAHaJWrrxHM7YHua0SdnE84f/ob4kwnVU9B9ubx4j25wLrjYJHTvTVo38w5Cqw5GvXH6DeAc4gg0xtl1kYy53xO+3ybZDZy7EpEKFbgSLNZIryrIk3v1v2uWQWj30Gb2OqppTRt2X+zSSph5MUqPIfKUweL3Ow2MbCBdNESp8QifdUld1RWEgVbZWSvcZmfYpr9w/rU+JVrVydmCBx0k8VWJmBobZydr4niVLhkhuzY8DvfLyJBAoGBAOFijou/Mh2B4mRdycwOxBcJUeL318K5MR6ondidP5SEcHpTavaQjqE9N+I0W0GPsJhzuBiUHq60TjC5GV3OYTp/G+4M4ibVYyR9UG3CrHAlgu9asakVfcOHhOJmyyD1FtI4BlNNI+nv4Ds7nHahv3yFSF/pes9VaAKm9k5ZTzmXAoGBANAYwOW8obHCLmHcrJyHcZX9icJAXP+GvmpsJpZaBSE2bs/K2cwLZnBoiUX1jH+7wWtUV2CfATMAD2UASocaYrSSF91bZAJNe3D9QliRC10IZ6SBn1Pw7u3uYVHb7JE6z4IGIrn503En5ncZcxfoc0JE9bNIM3tyEygetS/EifMHAoGAAp0Z+hTlh+IRtghAZtVlAL9i67bkEaYEI87gxbpNGnPOuhxtiR50CPqkw0LILCJ2cc4lvGM7V9tPbNE4shXKmtsOf9w2YyzmUW4CmMNBLKvCsPPkS4msQ7A2okl+4Yr2EMoFiMHEQNo/R3CRh+6oQdFp3XLfsbfT1PQKty3h9VECgYEAn6euL1R21fO+NDTjdcBww/veelt5Pk65vtq1DDuKnf2uLNxcFzFT6cA6OaN3pPR/JAJ0e1vixqcwKHR9uYPj4NgJWTpp015w67JS+bJmfn0ZT1xnyjYaig+POQe7S31MgVyFvhvPPoy3Q/8Rj3E3JMvVmjQ102slCW3t4vUuRXcCgYAkfbK84PXNvDWXQFR27fWJsLwLzORYxnk0l4oFOOJy926m/WMOfw33pVhsJInHK+iRKwPv33zo5YkB1BeGWedvM/gAgq5eSo+eqSkKn5M+eaDTlvWFrDK5tW21m49wtYOKDGo99tjgfaoJDDhGkX0NdKZ23BEvW1AInhCPNyE5rg==',
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a client' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar -r test' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test.foo.bar')
        expect(data['clientId']).to eq('test.foo.bar')
        expect(data['defaultClientScopes']).to eq(['address'])
        expect(data['rootUrl']).to eq('https://test.foo.bar')
        expect(data['redirectUris']).to eq(['https://test.foo.bar/test1'])
        expect(data['attributes']['login_theme']).to eq('keycloak')
        expect(data['authorizationServicesEnabled']).to eq(nil)
        expect(data['serviceAccountsEnabled']).to eq(true)
        expect(data['authenticationFlowBindingOverrides']['browser']).to eq('foo-test')
        expect(data['attributes']['backchannel_logout_url']).to eq('https://test.foo.bar/logout')
        expect(data['attributes']['backchannel_logout_session_required']).to eq(true)
        expect(data['attributes']['backchannel_logout_revoke_offline_tokens']).to eq(true)
      end
    end

    it 'has created a client2' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.baz -r test' do
        data = JSON.parse(stdout)
        expect(data['authenticationFlowBindingOverrides']['browser']).to eq('foo-test')
        expect(data['attributes']['backchannel_logout_url']).to eq('https://test.foo.baz/logout')
        expect(data['attributes']['backchannel_logout_session_required']).to eq(false)
        expect(data['attributes']['backchannel_logout_revoke_offline_tokens']).to eq(false)
      end
    end

    it 'has set the client secret' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/client-secret -r test' do
        data = JSON.parse(stdout)
        expect(data['value']).to eq('foobar')
      end
    end

    it 'has updated roles settings for client' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/roles -r test' do
        data = JSON.parse(stdout)
        expected_roles = ['bar_role', 'other_bar_role']
        client_roles = []
        data.each do |d|
          unless d['composite']
            client_roles.push(d['name'])
          end
        end
        expect(expected_roles - client_roles).to eq([])
      end
    end

    it 'has not updated roles settings for client2' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.baz/roles -r test' do
        data = JSON.parse(stdout)
        expect(data).to eq([])
      end
    end

    it 'has created SAML client' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/saml.foo.bar -r test' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('saml.foo.bar')
        expect(data['clientId']).to eq('saml.foo.bar')
        expect(data['defaultClientScopes']).to eq(['role_list'])
        expect(data['rootUrl']).to eq('https://saml.foo.bar/root')
        expect(data['adminUrl']).to eq('https://saml.foo.bar/admin')
        expect(data['baseUrl']).to eq('https://saml.foo.bar')
        expect(data['redirectUris']).to eq(['https://saml.foo.bar/test1'])
        expect(data['attributes']['saml_name_id_format']).to eq('transient')
        expect(data['attributes']['saml_artifact_binding_url']).to eq('https://saml.foo.bar/mellon/artifactResponse')
        expect(data['attributes']['saml_single_logout_service_url_redirect']).to eq('https://saml.foo.bar/mellon/logout')
        expect(data['attributes']['saml_assertion_consumer_url_post']).to eq('https://saml.foo.bar/mellon/postResponse')
        expect(data['attributes']['saml.encrypt']).to eq('true')
        expect(data['attributes']['saml.assertion.signature']).to eq('true')
        expect(data['attributes']['saml.client.signature']).to eq('true')
        expect(data['attributes']['saml.signing.certificate']).to eq('MIIDQzCCAiugAwIBAgIUNALBnAmwcPKLdBer4e0i22JiEd0' \
          'wDQYJKoZIhvcNAQELBQAwMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjAgFw0yMjAzMTgyMjU1M' \
          'TNaGA8yMTIyMDIyMjIyNTUxM1owMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjCCASIwDQYJKoZ' \
          'IhvcNAQEBBQADggEPADCCAQoCggEBAPKEr/vAExQ9LxF9oiiyz7JNdHgB8wxGEd5SN7YF6UOToLH2lQL5PelGnsVD13y9/ZN2qr3xl54zz' \
          '8IT8EimT8YXc0k7JEDLnKrvkz/xGSKnSFnudNM7B6i2VgM7uMbCCKKbOlULALUUnUmOAsKjRyTjcue4D1tULnha+ph+h/1T9Oc0VmDf6BV' \
          '54lEwOe7m7teOZCTnrM2Ll2dsZV2tgMywt87r9/yQWt3rbMjaVsLUsgV/SBd4RU6WDrsae6P7ccOWeoFyQ4fP7i7Z+Wpa8Y9pdnNraqBNm' \
          'kKb4pNkW+sJkkfA47YHafAtQO4E1cOnlsKJo0fXeMgiViCoDLVYPwcCAwEAAaNTMFEwHQYDVR0OBBYEFMuSde+sXzqeWtZPfY7Bsun3h3f' \
          'zMB8GA1UdIwQYMBaAFMuSde+sXzqeWtZPfY7Bsun3h3fzMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAF+KdjMVaLGJm' \
          'bBpV+mw6G9QVZ8DkiMKKz5+K2usCMCVf9XWVIyYXExsTBACk1FObHjXfHkk1A9nXOEFqgPBVS8CgSspVfQjIGhDy1lwhPkDvtyuIKIDb2k' \
          'f52xTru/bsAWuSEXcjbKqszN6l78AaR93n6sZKUkIsnDpvi/mG4xXBumiluJyedbQw9yj/NsYouALGWWQeHDwNJGcAxDxiLvIZjXkAo6IX' \
          'RQ85n29TiLFCbF5hPmiBlUNfo5reuobvhd+qDZOssiJ4q4VrSkHZ/u4Ri623+dgyZbDqwQ20NigfuoRaxbFWxbjl5T/lg30r7sqy/YOW2w' \
          'evA0wSqyxMfw=')
        expect(data['attributes']['saml.encryption.certificate']).to eq('MIIDSTCCAjGgAwIBAgIUbJ6dLiM4/T9uLT4gd13tuD46' \
          '9lkwDQYJKoZIhvcNAQELBQAwMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjAgFw0yMjAzMT' \
          'gyMjU1NDlaGA8yMTIyMDIyMjIyNTU0OVowMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjCC' \
          'ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKmzbda8/vwS3vn1OflWhcquzhh+FphTCA4PoRsqT2/AE5cbEPqVdPQxIUVXNL+l4L' \
          'M7Kl4H0vSoi3gHlH1SQCc/772gXDtByxHP0QYg+FaEIG+LbsFYeB1jJMhGblf+0xOH3uPtN9jzjkz8Xhzpcq/xgTOJDyQPfSamzW0xUtK3' \
          'iXd8B7K9nNdmOm9uLPZ1p2JLhvOJu6I6dapjLDoWgJnSnaYMgRuxShktTafWU3wolyo6c6+wago/CaoEdlrcwO7VvOd/gdhAuYUhYypD7t' \
          '+1mWisEBWxLo2omflr2rm2nWQX5EKx4U1lhEPxxlo0AkCCj/7hQyJt5jMzg/4QGNUCAwEAAaNTMFEwHQYDVR0OBBYEFMNcZ9lzmttxhrdV' \
          'XLm+deYLJyjeMB8GA1UdIwQYMBaAFMNcZ9lzmttxhrdVXLm+deYLJyjeMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAE' \
          'eYMFSGUGeWkgNKTmPL3l445ai4zMWUi92+vHeta44GlBKUAbNvC8Ab4mdVFCZF0lvKqUVfeKtTDD9wSko5XjjuhblLci7oa/gOFpp3dfb5' \
          'd5xtNsSoVD9ndPopApYugGlKEJI9qL39FyP9Js+rm13gsHNrMGXIfBE+FSFXu0sp0NRBnbqvz5cB8jSRb40v67tGmFVadYhomIpFsES2Fu' \
          'M3bY6YbD0hJ4ozLczgpfPOYw41xIAGSgbB6rwRsu+VwV7L2DW3wtq6CHksLYoiNDmdZXz0HDqmfHcMKlpUPpAkY/8q6xaO/QNEzohI60Tf' \
          'MRklpCLP/25n4ao3VqrHdZo=')
        expect(data['attributes']['saml.signing.private.key']).to eq('MIIEpAIBAAKCAQEAtzXe4xaXsz5KdSQdz/4+jMdO1HiBNBu' \
          'L2dIQ4b+DSP5IhSU+VPQP26G49fBWkN2ZSGMhOfvfxbcGjudIl7RRKRN1XqTgada/irqhU80Z8FTYWgl6A5px87nL1peCm8f2w6N220KLd' \
          'oYI/KapdNP1CUXR6iBJOrEZ3lV3CtZR5DkeOvdMEsmyhP5ajI4PMKU15ANmq8S7vPd2q/OGSQziAj467gDFDTXTWVVo1vV1HWSz9an2wdI' \
          'U7XdgrzRbuuCvgb5LLpbdyy+3j3RieoQAiDAiabKZqSMhiYc6mx21tD7ppN+H6RqzRulj/7WLdxckEJ736s1xSk8boOQhEqPoIQIDAQABA' \
          'oIBAQCn3aQrTjgQ87IlQsJOIRYOx09jPkakB9lL6z2sml0gNF0eIdHK5RTimHtwXJX0hhY8TRfUmQOflONdbG0HEyCKElooLcmxMCKwafA' \
          'HaJWrrxHM7YHua0SdnE84f/ob4kwnVU9B9ubx4j25wLrjYJHTvTVo38w5Cqw5GvXH6DeAc4gg0xtl1kYy53xO+3ybZDZy7EpEKFbgSLNZI' \
          'ryrIk3v1v2uWQWj30Gb2OqppTRt2X+zSSph5MUqPIfKUweL3Ow2MbCBdNESp8QifdUld1RWEgVbZWSvcZmfYpr9w/rU+JVrVydmCBx0k8V' \
          'WJmBobZydr4niVLhkhuzY8DvfLyJBAoGBAOFijou/Mh2B4mRdycwOxBcJUeL318K5MR6ondidP5SEcHpTavaQjqE9N+I0W0GPsJhzuBiUH' \
          'q60TjC5GV3OYTp/G+4M4ibVYyR9UG3CrHAlgu9asakVfcOHhOJmyyD1FtI4BlNNI+nv4Ds7nHahv3yFSF/pes9VaAKm9k5ZTzmXAoGBANA' \
          'YwOW8obHCLmHcrJyHcZX9icJAXP+GvmpsJpZaBSE2bs/K2cwLZnBoiUX1jH+7wWtUV2CfATMAD2UASocaYrSSF91bZAJNe3D9QliRC10IZ' \
          '6SBn1Pw7u3uYVHb7JE6z4IGIrn503En5ncZcxfoc0JE9bNIM3tyEygetS/EifMHAoGAAp0Z+hTlh+IRtghAZtVlAL9i67bkEaYEI87gxbp' \
          'NGnPOuhxtiR50CPqkw0LILCJ2cc4lvGM7V9tPbNE4shXKmtsOf9w2YyzmUW4CmMNBLKvCsPPkS4msQ7A2okl+4Yr2EMoFiMHEQNo/R3CRh' \
          '+6oQdFp3XLfsbfT1PQKty3h9VECgYEAn6euL1R21fO+NDTjdcBww/veelt5Pk65vtq1DDuKnf2uLNxcFzFT6cA6OaN3pPR/JAJ0e1vixqc' \
          'wKHR9uYPj4NgJWTpp015w67JS+bJmfn0ZT1xnyjYaig+POQe7S31MgVyFvhvPPoy3Q/8Rj3E3JMvVmjQ102slCW3t4vUuRXcCgYAkfbK84' \
          'PXNvDWXQFR27fWJsLwLzORYxnk0l4oFOOJy926m/WMOfw33pVhsJInHK+iRKwPv33zo5YkB1BeGWedvM/gAgq5eSo+eqSkKn5M+eaDTlvW' \
          'FrDK5tW21m49wtYOKDGo99tjgfaoJDDhGkX0NdKZ23BEvW1AInhCPNyE5rg==')
      end
    end
  end

  context 'when updates client' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_client { 'test.foo.bar':
        realm                          => 'test',
        root_url                       => 'https://test.foo.bar/test',
        redirect_uris                  => ['https://test.foo.bar/test2'],
        default_client_scopes          => ['profile', 'email'],
        secret                         => 'foobar2',
        authorization_services_enabled => true,
        service_accounts_enabled       => true,
        roles                          => ['bar_role'],
      }
      keycloak_client { 'test.foo.baz':
        realm                          => 'test',
        root_url                       => 'https://test.foo.bar',
        redirect_uris                  => ['https://test.foo.bar/test1'],
        default_client_scopes          => ['address'],
        secret                         => 'foobar',
        login_theme                    => 'keycloak',
        authorization_services_enabled => false,
        service_accounts_enabled       => true,
        browser_flow                   => 'browser',
        roles                          => ['baz_role'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a client' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar -r test' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test.foo.bar')
        expect(data['clientId']).to eq('test.foo.bar')
        expect(data['defaultClientScopes']).to eq(['profile', 'email'])
        expect(data['rootUrl']).to eq('https://test.foo.bar/test')
        expect(data['redirectUris']).to eq(['https://test.foo.bar/test2'])
        expect(data['attributes']['login_theme']).to be_nil
        expect(data['authorizationServicesEnabled']).to eq(true)
        expect(data['serviceAccountsEnabled']).to eq(true)
        expect(data['authenticationFlowBindingOverrides']).to eq({})
      end
    end

    it 'has updated a client flow' do
      browser_id = nil
      on hosts, "/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows -r test --fields 'id,alias'" do
        data = JSON.parse(stdout)
        data.each do |d|
          if d['alias'] == 'browser'
            browser_id = d['id']
            break
          end
        end
      end
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.baz -r test' do
        data = JSON.parse(stdout)
        expect(data['authenticationFlowBindingOverrides']['browser']).to eq(browser_id)
      end
    end

    it 'has set the same client secret' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/client-secret -r test' do
        data = JSON.parse(stdout)
        expect(data['value']).to eq('foobar2')
      end
    end

    it 'has updated client roles settings' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/roles -r test' do
        data = JSON.parse(stdout)
        expected_roles = ['bar_role']
        client_roles = []
        data.each do |d|
          unless d['composite']
            client_roles.push(d['name'])
          end
        end
        expect(expected_roles - client_roles).to eq([])
      end
    end

    it 'has updated client2 roles settings' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.baz/roles -r test' do
        data = JSON.parse(stdout)
        expected_roles = ['baz_role']
        client_roles = []
        data.each do |d|
          unless d['composite']
            client_roles.push(d['name'])
          end
        end
        expect(expected_roles - client_roles).to eq([])
      end
    end

    it 'manages authorization services properly' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_client { 'test.foo.bar':
        realm                          => 'test',
        root_url                       => 'https://test.foo.bar/test/authorization',
        redirect_uris                  => ['https://test.foo.bar/test2'],
        default_client_scopes          => ['profile', 'email'],
        secret                         => 'foobar2',
        authorization_services_enabled => true,
        service_accounts_enabled       => true,
        roles                          => ['bar_role'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has not disabled authorization services due to unrelated property change' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar -r test' do
        data = JSON.parse(stdout)
        expect(data['authorizationServicesEnabled']).to eq(true)
      end
    end
  end
end
