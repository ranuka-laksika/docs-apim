# Using Azure AD as an External IDP with OIDC

Follow the instructions below to connect Azure AD as a third-party Identity Provider to WSO2 API Manager for federated authentication of Publisher and Developer Portal users.

## Prerequisites

Before you begin, make sure you do the following.

1. Create an Azure account that has an active subscription. [Create an account for free](https://azure.microsoft.com/en-gb/free/?WT.mc_id=A261C142F).
2. Download the WSO2 API Manager distribution from [https://wso2.com/api-management/](https://wso2.com/api-management/).
3. The Azure account must have permission to manage applications in Azure Active Directory (Azure AD). Any of the following Azure AD roles include the required permissions:
   - Application administrator
   - Application developer
   - Cloud application administrator
4. Enable the email domain on WSO2 API Manager.

     You need to enable this because Azure AD uses the email as the username by default. As the email domain is not enabled by default, you have to enable it to use the email as the username in WSO2 API Manager. Once enabled, you can use your email or a normal username as your username.

     Follow the instructions below:

     1. Unzip the WSO2 API Manager distribution.
     2. Open the `deployment.toml` file, which is located in the `<API-M_HOME>/repository/conf/` directory. 
     3. Add the following configuration.

        ```toml
        [tenant_mgt]
        enable_email_domain= true
        ```

5. Start the WSO2 API Manager server.

## Step 1 - Configure Azure AD

\!\!\! note
    For more information on working with Azure AD, see the official [Azure Entra ID documentation](https://learn.microsoft.com/en-us/entra/identity/).

1. Navigate to [Microsoft Entra ID](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview).

2. Add an application in Azure AD.
   
     Navigate to [App Registration](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps) and click **New registration**. Create an application based on the following settings:

    <table>
      <tr>
      <th><b>Field</b></th>
      <th><b>Value</b></th>
      </tr>
      <tr>
      <td>Name</td>
      <td><code>WSO2-APIM-SSO</code></td>
      </tr>
      <tr>
      <td>Supported account types</td>
      <td>Accounts in this organizational directory only (Single tenant)</td>
      </tr>
      <tr>
      <td>Redirect URI</td>
      <td><code>https://localhost:9443/commonauth</code><br/> 
      <code>https://localhost:9443/publisher/services/auth/callback/login</code><br/>
      <code>https://localhost:9443/devportal/services/auth/callback/login</code></td>
      </tr>
    </table>

3. Note down the following details from the **Overview** section of the created application:
   - **Application (client) ID**
   - **Directory (tenant) ID**

4. Create client secret.

    1. Navigate to **Certificates & secrets** > **Client secrets** > **New client secret**.
    2. Fill the form with relevant information and set expiration as needed.
    3. Make sure to copy the secret value, as it will only be displayed once.

5. Configure API permissions (Optional - for user profile access).

    1. Navigate to **API permissions**.
    2. Click **Add a permission**.
    3. Select **Microsoft Graph**.
    4. Click on **Delegated permissions**.
    5. Select **OpenId permissions**:
       - openid
       - profile  
       - email
    6. Click **Add permissions**.
    7. Click **Grant admin consent for Default Directory**.

## Step 2 - Configure WSO2 API Manager

1. Open the `deployment.toml` file located in the `<API-M_HOME>/repository/conf/` directory and add the following configurations.

    \!\!\! note
        Replace the values with the corresponding values that you received when configuring Azure AD.

    ```toml
    [authentication.authenticator.oidc.properties]
    IdPEntityId="https://login.microsoftonline.com/{tenant-id}/v2.0"
    ClientId="<Application (client) ID>"
    ClientSecret="<Client secret value>"
    AuthorizationEndpoint="https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize"
    TokenEndpoint="https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token"
    UserInfoEndpoint="https://graph.microsoft.com/oidc/userinfo"
    JWKSEndpoint="https://login.microsoftonline.com/{tenant-id}/discovery/v2.0/keys"
    IssuerIdentifier="https://login.microsoftonline.com/{tenant-id}/v2.0"
    IsUserIdInClaims=true
    ```

2. Add the identity provider configuration.

    ```toml
    [[authentication.custom_authentication_handler]]
    name="OIDCAuthenticationHandler"
    enable=true

    [authentication.custom_authentication_handler.properties]
    IdPEntityId="https://login.microsoftonline.com/{tenant-id}/v2.0"
    ```

3. Add the service provider configuration for the Publisher.

    ```toml
    [[service_provider]]
    id="API_PUBLISHER"
    saas_app=true

    [service_provider.local_claim_config]
    use_local_claim_dialect=true

    [service_provider.claim_config]
    user_claim_uri="http://wso2.org/claims/username"
    role_claim_uri="http://wso2.org/claims/role"
    local_claim_dialect=true

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/username"
    remote_claim_uri="preferred_username"

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/emailaddress"
    remote_claim_uri="email"

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/givenname"
    remote_claim_uri="given_name"

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/lastname"
    remote_claim_uri="family_name"

    [service_provider.federated_authenticators.oidc]
    enable=true
    client_id="<Application (client) ID>"
    client_secret="<Client secret value>"
    authorization_endpoint="https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize"
    token_endpoint="https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token"
    userinfo_endpoint="https://graph.microsoft.com/oidc/userinfo"
    jwks_endpoint="https://login.microsoftonline.com/{tenant-id}/discovery/v2.0/keys"
    issuer="https://login.microsoftonline.com/{tenant-id}/v2.0"
    ```

4. Add the service provider configuration for the Developer Portal.

    ```toml
    [[service_provider]]
    id="API_STORE"
    saas_app=true

    [service_provider.local_claim_config]
    use_local_claim_dialect=true

    [service_provider.claim_config]
    user_claim_uri="http://wso2.org/claims/username"
    role_claim_uri="http://wso2.org/claims/role"
    local_claim_dialect=true

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/username"
    remote_claim_uri="preferred_username"

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/emailaddress"
    remote_claim_uri="email"

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/givenname"
    remote_claim_uri="given_name"

    [[service_provider.claim_config.claim_mapping]]
    local_claim_uri="http://wso2.org/claims/lastname"
    remote_claim_uri="family_name"

    [service_provider.federated_authenticators.oidc]
    enable=true
    client_id="<Application (client) ID>"
    client_secret="<Client secret value>"
    authorization_endpoint="https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize"
    token_endpoint="https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token"
    userinfo_endpoint="https://graph.microsoft.com/oidc/userinfo"
    jwks_endpoint="https://login.microsoftonline.com/{tenant-id}/discovery/v2.0/keys"
    issuer="https://login.microsoftonline.com/{tenant-id}/v2.0"
    ```

5. Restart the WSO2 API Manager server.

## Step 3 - Try it out

1. Access the WSO2 API Manager Publisher via [https://localhost:9443/publisher](https://localhost:9443/publisher).

2. Click **Sign In**.

3. You will be redirected to the Azure AD login page.

4. Enter your Azure AD credentials and sign in.

5. Provide consent for the requested permissions if prompted.

6. Upon successful authentication, you will be redirected back to the API Manager Publisher.

7. Similarly, you can access the Developer Portal via [https://localhost:9443/devportal](https://localhost:9443/devportal) and sign in using your Azure AD credentials.

## Troubleshooting

### Invalid Redirect URI

If you encounter a redirect URI error, ensure that all redirect URIs are properly configured in your Azure AD application settings:

- `https://localhost:9443/commonauth`
- `https://localhost:9443/publisher/services/auth/callback/login`  
- `https://localhost:9443/devportal/services/auth/callback/login`

Replace `localhost:9443` with your actual WSO2 API Manager server URL and port.

### User Attribute Mapping Issues

If user attributes are not mapped correctly, verify the claim mappings in your service provider configuration. Azure AD typically uses the following claims:

- `preferred_username` for username
- `email` for email address
- `given_name` for first name
- `family_name` for last name

### Token Validation Errors

Ensure that the `issuer` value in your configuration exactly matches the `iss` claim in the tokens issued by Azure AD. The issuer should be in the format:
`https://login.microsoftonline.com/{tenant-id}/v2.0`

## Related Documentation

- [Configure Azure AD as a Key Manager]({{base_path}}/administer/key-managers/configure-azure-ad-key-manager/)
- [Using Okta as an External IDP with OIDC]({{base_path}}/install-and-setup/setup/sso/okta-as-an-external-idp-using-oidc/)
- [Configuring Identity Server as External IDP using OIDC]({{base_path}}/install-and-setup/setup/sso/configuring-identity-server-as-external-idp-using-oidc/)
EOF < /dev/null