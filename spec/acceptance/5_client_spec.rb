require 'spec_helper_acceptance'

describe 'keycloak_client define:', if: RSpec.configuration.keycloak_full do
  context 'creates client' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'foo on test': ensure => 'present' }
      keycloak_client { 'test.foo.bar':
        realm                                   => 'test',
        root_url                                => 'https://test.foo.bar',
        redirect_uris                           => ['https://test.foo.bar/test1'],
        default_client_scopes                   => ['address'],
        secret                                  => 'foobar',
        login_theme                             => 'keycloak',
        backchannel_logout_url                  => 'https://test.foo.bar/logout',
        authorization_services_enabled          => false,
        service_accounts_enabled                => true,
        browser_flow                            => 'foo',
        roles                                   => ['bar_role', 'other_bar_role'],
        saml_name_id_format                     => 'transient',
        saml_artifact_binding_url               => 'https://test.foo.bar/mellon/artifactResponse',
        saml_single_logout_service_url_redirect => 'https://test.foo.bar/mellon/logout',
        saml_assertion_consumer_url_post        => 'https://test.foo.bar/mellon/postResponse',
        saml_encrypt                            => 'true',
        saml_assertion_signature                => 'true',
        saml_signing_certificate                => 'MIIDQzCCAiugAwIBAgIUNALBnAmwcPKLdBer4e0i22JiEd0wDQYJKoZIhvcNAQELBQAwMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjAgFw0yMjAzMTgyMjU1MTNaGA8yMTIyMDIyMjIyNTUxM1owMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPKEr/vAExQ9LxF9oiiyz7JNdHgB8wxGEd5SN7YF6UOToLH2lQL5PelGnsVD13y9/ZN2qr3xl54zz8IT8EimT8YXc0k7JEDLnKrvkz/xGSKnSFnudNM7B6i2VgM7uMbCCKKbOlULALUUnUmOAsKjRyTjcue4D1tULnha+ph+h/1T9Oc0VmDf6BV54lEwOe7m7teOZCTnrM2Ll2dsZV2tgMywt87r9/yQWt3rbMjaVsLUsgV/SBd4RU6WDrsae6P7ccOWeoFyQ4fP7i7Z+Wpa8Y9pdnNraqBNmkKb4pNkW+sJkkfA47YHafAtQO4E1cOnlsKJo0fXeMgiViCoDLVYPwcCAwEAAaNTMFEwHQYDVR0OBBYEFMuSde+sXzqeWtZPfY7Bsun3h3fzMB8GA1UdIwQYMBaAFMuSde+sXzqeWtZPfY7Bsun3h3fzMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAF+KdjMVaLGJmbBpV+mw6G9QVZ8DkiMKKz5+K2usCMCVf9XWVIyYXExsTBACk1FObHjXfHkk1A9nXOEFqgPBVS8CgSspVfQjIGhDy1lwhPkDvtyuIKIDb2kf52xTru/bsAWuSEXcjbKqszN6l78AaR93n6sZKUkIsnDpvi/mG4xXBumiluJyedbQw9yj/NsYouALGWWQeHDwNJGcAxDxiLvIZjXkAo6IXRQ85n29TiLFCbF5hPmiBlUNfo5reuobvhd+qDZOssiJ4q4VrSkHZ/u4Ri623+dgyZbDqwQ20NigfuoRaxbFWxbjl5T/lg30r7sqy/YOW2wevA0wSqyxMfw=',
        saml_encryption_certificate             => 'MIIDSTCCAjGgAwIBAgIUbJ6dLiM4/T9uLT4gd13tuD469lkwDQYJKoZIhvcNAQELBQAwMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjAgFw0yMjAzMTgyMjU1NDlaGA8yMTIyMDIyMjIyNTU0OVowMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKmzbda8/vwS3vn1OflWhcquzhh+FphTCA4PoRsqT2/AE5cbEPqVdPQxIUVXNL+l4LM7Kl4H0vSoi3gHlH1SQCc/772gXDtByxHP0QYg+FaEIG+LbsFYeB1jJMhGblf+0xOH3uPtN9jzjkz8Xhzpcq/xgTOJDyQPfSamzW0xUtK3iXd8B7K9nNdmOm9uLPZ1p2JLhvOJu6I6dapjLDoWgJnSnaYMgRuxShktTafWU3wolyo6c6+wago/CaoEdlrcwO7VvOd/gdhAuYUhYypD7t+1mWisEBWxLo2omflr2rm2nWQX5EKx4U1lhEPxxlo0AkCCj/7hQyJt5jMzg/4QGNUCAwEAAaNTMFEwHQYDVR0OBBYEFMNcZ9lzmttxhrdVXLm+deYLJyjeMB8GA1UdIwQYMBaAFMNcZ9lzmttxhrdVXLm+deYLJyjeMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAEeYMFSGUGeWkgNKTmPL3l445ai4zMWUi92+vHeta44GlBKUAbNvC8Ab4mdVFCZF0lvKqUVfeKtTDD9wSko5XjjuhblLci7oa/gOFpp3dfb5d5xtNsSoVD9ndPopApYugGlKEJI9qL39FyP9Js+rm13gsHNrMGXIfBE+FSFXu0sp0NRBnbqvz5cB8jSRb40v67tGmFVadYhomIpFsES2FuM3bY6YbD0hJ4ozLczgpfPOYw41xIAGSgbB6rwRsu+VwV7L2DW3wtq6CHksLYoiNDmdZXz0HDqmfHcMKlpUPpAkY/8q6xaO/QNEzohI60TfMRklpCLP/25n4ao3VqrHdZo=',
        saml_signing_private_key                => 'MIIEpAIBAAKCAQEAtzXe4xaXsz5KdSQdz/4+jMdO1HiBNBuL2dIQ4b+DSP5IhSU+VPQP26G49fBWkN2ZSGMhOfvfxbcGjudIl7RRKRN1XqTgada/irqhU80Z8FTYWgl6A5px87nL1peCm8f2w6N220KLdoYI/KapdNP1CUXR6iBJOrEZ3lV3CtZR5DkeOvdMEsmyhP5ajI4PMKU15ANmq8S7vPd2q/OGSQziAj467gDFDTXTWVVo1vV1HWSz9an2wdIU7XdgrzRbuuCvgb5LLpbdyy+3j3RieoQAiDAiabKZqSMhiYc6mx21tD7ppN+H6RqzRulj/7WLdxckEJ736s1xSk8boOQhEqPoIQIDAQABAoIBAQCn3aQrTjgQ87IlQsJOIRYOx09jPkakB9lL6z2sml0gNF0eIdHK5RTimHtwXJX0hhY8TRfUmQOflONdbG0HEyCKElooLcmxMCKwafAHaJWrrxHM7YHua0SdnE84f/ob4kwnVU9B9ubx4j25wLrjYJHTvTVo38w5Cqw5GvXH6DeAc4gg0xtl1kYy53xO+3ybZDZy7EpEKFbgSLNZIryrIk3v1v2uWQWj30Gb2OqppTRt2X+zSSph5MUqPIfKUweL3Ow2MbCBdNESp8QifdUld1RWEgVbZWSvcZmfYpr9w/rU+JVrVydmCBx0k8VWJmBobZydr4niVLhkhuzY8DvfLyJBAoGBAOFijou/Mh2B4mRdycwOxBcJUeL318K5MR6ondidP5SEcHpTavaQjqE9N+I0W0GPsJhzuBiUHq60TjC5GV3OYTp/G+4M4ibVYyR9UG3CrHAlgu9asakVfcOHhOJmyyD1FtI4BlNNI+nv4Ds7nHahv3yFSF/pes9VaAKm9k5ZTzmXAoGBANAYwOW8obHCLmHcrJyHcZX9icJAXP+GvmpsJpZaBSE2bs/K2cwLZnBoiUX1jH+7wWtUV2CfATMAD2UASocaYrSSF91bZAJNe3D9QliRC10IZ6SBn1Pw7u3uYVHb7JE6z4IGIrn503En5ncZcxfoc0JE9bNIM3tyEygetS/EifMHAoGAAp0Z+hTlh+IRtghAZtVlAL9i67bkEaYEI87gxbpNGnPOuhxtiR50CPqkw0LILCJ2cc4lvGM7V9tPbNE4shXKmtsOf9w2YyzmUW4CmMNBLKvCsPPkS4msQ7A2okl+4Yr2EMoFiMHEQNo/R3CRh+6oQdFp3XLfsbfT1PQKty3h9VECgYEAn6euL1R21fO+NDTjdcBww/veelt5Pk65vtq1DDuKnf2uLNxcFzFT6cA6OaN3pPR/JAJ0e1vixqcwKHR9uYPj4NgJWTpp015w67JS+bJmfn0ZT1xnyjYaig+POQe7S31MgVyFvhvPPoy3Q/8Rj3E3JMvVmjQ102slCW3t4vUuRXcCgYAkfbK84PXNvDWXQFR27fWJsLwLzORYxnk0l4oFOOJy926m/WMOfw33pVhsJInHK+iRKwPv33zo5YkB1BeGWedvM/gAgq5eSo+eqSkKn5M+eaDTlvWFrDK5tW21m49wtYOKDGo99tjgfaoJDDhGkX0NdKZ23BEvW1AInhCPNyE5rg==',
      }
      keycloak_client { 'test.foo.baz':
        realm                                   => 'test',
        root_url                                => 'https://test.foo.bar',
        redirect_uris                           => ['https://test.foo.bar/test1'],
        default_client_scopes                   => ['address'],
        secret                                  => 'foobar',
        login_theme                             => 'keycloak',
        backchannel_logout_url                  => 'https://test.foo.baz/logout',
        authorization_services_enabled          => false,
        service_accounts_enabled                => true,
        browser_flow                            => 'foo',
        saml_name_id_format                     => 'username',
        saml_artifact_binding_url               => 'https://test.foo.baz/mellon/artifactResponse',
        saml_single_logout_service_url_redirect => 'https://test.foo.baz/mellon/logout',
        saml_assertion_consumer_url_post        => 'https://test.foo.baz/mellon/postResponse',
        saml_encrypt                            => 'false',
        saml_assertion_signature                => 'false',
        saml_signing_certificate                => 'MIIDQzCCAiugAwIBAgIUBltTHWJph2xvgwAFpPHINnRRwxgwDQYJKoZIhvcNAQELBQAwMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhejAgFw0yMjAzMTgyMjU2MTVaGA8yMTIyMDIyMjIyNTYxNVowMDEuMCwGA1UEAwwlc2FtbF9zaWduaW5nX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhejCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN4/dvpihR0jagkqjKut7cjFFf8YJPJPALiSJ+lDpS6WvbXf0Kn59XuAo+NmjQ65rX5+rU0LxRj2YuSbiDJ9qW7WD/6mglzJJbGqyHDOlkYsYl7KVwwXvwepT4SfvWBNQ6uuN3LIrtJCEQZp698uJD2prQVOkRhkumAuJ7Clx7kG4Qbmm1J42rNIk65CeAlzW4Dq/S87dIrdhPPkJR8JdOuj5e0phl/5Ff9QrdJX2TLZrlTyw6jQ48MMzQ3cz/nb4pNmBp5FteuxoQnmTw8nUaenGMaP+W8OV/l2WfuLYRRKIgai2imqbow5+LnMnqAg68V1hn7jlFPQ7VlPENlyA6sCAwEAAaNTMFEwHQYDVR0OBBYEFGwNfO/XkVDr6/34bQioevk7ISXlMB8GA1UdIwQYMBaAFGwNfO/XkVDr6/34bQioevk7ISXlMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAFBcgX05kQoTnFTuMdkjZCU1CuXGLLs5oyNgX0MjJM11TALPnK7l1qDupabnws0pUML1lL3FuktJJF/PT34iuRBwxN75NuIgVYnvARRIOsZlr8n1VGWKv6qyyQRP6ulYcFx1+Ah6SAxIKf7ONUegkYK4ZUJPNU8jgRTbeOfuJwZb/b5WMmEwK79vWwp1rDDvgOysjc3vdO9CZSRqPx5pGF134EpPWszR7KB7kRvqOTB/vdo3xXx4K2WsBskRZkmpvbFquqcNC65yoy9iVRl1CbetQB8X2R7oj7PyXgVEVpNcy2xCyjOcbGmVFe/q+op2KnSNbr+ldptUpeOB/agDb4M=',
        saml_encryption_certificate             => 'MIIDSTCCAjGgAwIBAgIUc4yGC3Jnn0KDEPqYi9ODZcUrXPIwDQYJKoZIhvcNAQELBQAwMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhejAgFw0yMjAzMTgyMjU2MzBaGA8yMTIyMDIyMjIyNTYzMFowMzExMC8GA1UEAwwoc2FtbF9lbmNyeXB0aW9uX2NlcnRpZmljYXRlLXRlc3QuZm9vLmJhejCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ018hDfB/AA69Q4jbq0FX5aTY7H8/pSzyjeWIUVwPAfJGIWP6+mWOhtDIErVyA6gdHrMG1xOsw0Igqky5w/ugIOz0Zeqi3OgCSmH6c2SDNTIkJrmSssxdOkv4AKZqUnhbCu/JQ9TyFzA+T99Uc0QlJwdy+ipHHOHzkuBK7r2X0ozzAxVsRrWrSNhIUSDefynazErX+B04c6avNUa4IIOlTBtLwz/HYSX0HP3ZFcN/7zzjB8SGRPeLr2+eCV22tfx7PLfsQbPX6IPcmxR633wV0Qt8Ht32gadHEQp64ZQAAcbjMBvqh7KQKZz9Tkk707GPn3LEgAP8e7V2hLfsWBd+UCAwEAAaNTMFEwHQYDVR0OBBYEFPxlPo/Q0ntSIya10XZmUbZ3LQHaMB8GA1UdIwQYMBaAFPxlPo/Q0ntSIya10XZmUbZ3LQHaMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAFMhat4EWTRbdLwW4n6GE/Ke1f7rW9t91MZYKmtND+DoWLAKovrAIKVQjqq5Q/dsSXClZdFI9dcbCnF037GZv9cZNRFiT+rxGB4g2+p6h8XxeeUQjr6Iw0ABkzv9EhkGbXfLdgaGRFU1gUugBg0Hp/s2SovXU9Tf2u+5+lQSiulkwj8guhNuFz/PAr00r4843knuLm/PjZHTRjJFJ7lm42lZwL45DVyhRZdtUgRMb1Q49hC1p+SEHocMtbhpUj/V4mzqbOU6GC6swVKiIkToIa7oxwF9Hhcu8U6/co3ltKI3l/k/n7my7HSt7YYHprYg13smcggEq4YPPYgb+J1nwQs=',
        saml_signing_private_key                => 'MIIEpAIBAAKCAQEArQY2GCZ7bIfbm9Z9T6iM4f2f2HYxRrCZK9f8AUWvtYJpgdzJooM+0YQ6sJENxeuTbLmIN7Ps9sEXrL/u50fEYlxKzUCkHRYLv2VqZ4TwL/XO2Y9XlBhFzDI244UOv+UBP66nvfeuDI80imeLaBRv0TmDOWWliqL6Qfs9mcGZdqO+drqkMk7T9F4tjdud9S+7Htk0/D3Wjk9/r570NofFQvE47aoSP9i8xQaGXM4CRM0QHU8aMjukI+F3PA7rS3mBMhJtPiEes9ih4yFS58Mr6RtrVO/Y05Zo0YdwiK6jwgQhBRd0bcY+YxGx0TT8kGrATYMrRnIJ0k9R1RU3XdO4twIDAQABAoIBAD8y35teowJ3dU2swMTR6fO58iLcuQ76/le3YoMMcyu3YNZgUP4dNlrNE6resMs0SvsRoaHHBKz0xrMAwECWRDMxRtlF3SwKm2vjnUQGmLzL6iwpYXHkk8oMJWRhe4u4GAaswvRufZJ01FohjBgOLvGbMkVKzXagJQzoug1pW6aret2AUbx9rr9NxvWKQxG+ztLsTykqd1BScpwaM6E5+KpILRsrs+S8HyyaaJSDGReU9xnsFSLqX9SpcX1y9/x9fXkX+AUNsu/YUTOalXzKc4CwXxi/61sAsw3djTqhtvEFewVCuAAtOhi/Xs0y8mIHKmEzNKqXJOdtEEtxTIGztiECgYEA2GToBgzjpoy/jvOdzgFxBm6q3xCWk3XQeaYG8Z+kwqWSC33Ehnnf/M8h3VogcPH5/wlPKQRTG1+0kgKLeAP8btGwzU2GmIPnNC2BVaYQTBIS7qQEhsMXh4xwGu5BQXFB+EcsOWkKK8AoIyHVS2gA6MXnqaDHAGc54RclemAtwu8CgYEAzLE4HWDSK+scbKVkqzpUHtI9q5vbRiVU9rIrgjihq1NAV3j/4qYqq/nP0Kexw5nQBbCdoPubjHoSWb155UlE+Ews02lH8WRJ91MRkojGDopbPedSJ+BT89RChxK05AILPlYfcq70Czb9wMVipeseW3NbXQ2uznyUeF9L3APTxrkCgYEAp9IKB7czTlVVsn3I4p1HlJ97MSfiP1ZdahqSxAz1cGeLzhGpukkGpz/UmaBuDGn9YgdMNxk9grtEhQAoPdmJikBhh7caLWoOgu7PoSb6+KQDvsPBJupicyM9RgWE4kX9zZkU+Sk3VBrghe6VRrfQDLZ/JZSlAPENeD3FORUiKE0CgYEAkMvsfhu3kQnIGbMF+3pPd14R8gtWmdBewgRXcs7Mzn0dzsLxgEs7dFxK/bcisNNlrCC74N0bs8vGn2TBjci+2UZJj2OyWLgw+pvwmk/WiwKkeK3iGANAYAOO7C33eDNZ8MbLiDzqteQ4rNz0Y5pm5xo7TyAWwEqwXFZNO14ZuUECgYAETmckzryaUWqYNzZS2tfvtJzdBOex7aIH6t+sefT+muiov7BfvUXi8Ctr75u4BrJVYJxkXC6WWYW2EUH02qUqeh74MLW7AtDjsS1GJcHA5qD+FC/1Vf2nheiesnSEcxC8xUN3HQXIzkp0EKj0OD7f+aC7Ciyw3ysDyX5KiqJ/9w==',
      }
      EOS

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
      end
    end

    it 'has created a client2' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.baz -r test' do
        data = JSON.parse(stdout)
        expect(data['authenticationFlowBindingOverrides']['browser']).to eq('foo-test')
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
  end

  context 'updates client' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
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
      EOS

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
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
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
      EOS

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
