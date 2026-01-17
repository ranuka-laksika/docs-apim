# Configure Azure Active Directory as external IDP using OIDC

This document explains how to connect Microsoft Azure Active Directory (Azure AD) as an external Identity Provider to WSO2 API Manager for Single Sign-On (SSO) authentication. With this configuration, users can authenticate to the API Manager Publisher and Developer Portal using their Azure AD credentials.

## Prerequisites

Before you begin, make sure you complete the following prerequisites:

1. Create an Azure AD tenant and have administrative access to it.
2. Download the WSO2 API Manager distribution from [https://wso2.com/api-management/](https://wso2.com/api-management/).
3. Enable the email domain on WSO2 API Manager.

     Azure AD uses the email as the username by default. As the email domain is not enabled by default in WSO2 API Manager, you have to enable it to use the email as the username. Once enabled, you can use your email or a normal username as your username.

     Follow the instructions below:

     1. Unzip the WSO2 API Manager distribution.
     2. Open the `deployment.toml` file, which is located in the `<API-M_HOME>/repository/conf/` directory.
     3. Add the following configuration:

        ```toml
        [tenant_mgt]
        enable_email_domain= true
        ```

4. Start the WSO2 API Manager server.

## Step 1 - Configure Azure Active Directory

!!! note
    For more information about working with Azure Active Directory, see the [official Microsoft Azure documentation](https://docs.microsoft.com/en-us/azure/active-directory/).

1. Sign in to the [Azure portal](https://portal.azure.com).

2. Navigate to **Azure Active Directory** from the left navigation menu.

3. Select **App registrations** and click **New registration**.

4. Create a new application registration with the following details:

    <table>
      <tr>
      <th><b>Field</b></th>
      <th><b>Value</b></th>
      </tr>
      <tr>
      <td>Name</td>
      <td><code>WSO2-API-Manager-OIDC</code></td>
      </tr>
      <tr>
      <td>Supported account types</td>
      <td>Accounts in this organizational directory only (Single tenant)</td>
      </tr>
      <tr>
      <td>Redirect URI (optional)</td>
      <td>Web: <code>https://localhost:9443/commonauth</code></td>
      </tr>
    </table>

    !!! tip
        Replace `localhost:9443` with the actual hostname and port of your WSO2 API Manager deployment.

5. Click **Register** to create the application.

6. After the application is created, note down the following values from the **Overview** page:
   - **Application (client) ID**
   - **Directory (tenant) ID**

7. Navigate to **Certificates & secrets** and create a new client secret:
   
   1. Click **New client secret**.
   2. Add a description (for example, `WSO2-APIM-Secret`).
   3. Select an expiration period.
   4. Click **Add**.
   5. Copy the generated **Value** of the client secret immediately. This value will not be shown again.

8. Configure API permissions:
   
   1. Navigate to **API permissions**.
   2. Click **Add a permission**.
   3. Select **Microsoft Graph**.
   4. Select **Delegated permissions**.
   5. Add the following permissions:
      - `openid`
      - `profile`
      - `email`
      - `User.Read`
   6. Click **Add permissions**.
   7. Click **Grant admin consent** for your tenant.

9. Configure token configuration (optional):
   
   1. Navigate to **Token configuration**.
   2. Click **Add optional claim**.
   3. Select **ID** token type.
   4. Add the following claims:
      - `email`
      - `given_name`
      - `family_name`
   5. Click **Add**.

## Step 2 - Configure WSO2 API Manager

1. Sign in to the WSO2 API Manager Management Console by browsing to the following URL:

    ```
    https://localhost:9443/carbon
    ```

2. Navigate to **Main > Identity > Identity Providers**.

3. Click **Add** to create a new Identity Provider.

4. Configure the basic information:

    <table>
      <tr>
      <th><b>Field</b></th>
      <th><b>Value</b></th>
      </tr>
      <tr>
      <td>Identity Provider Name</td>
      <td><code>AzureAD</code></td>
      </tr>
      <tr>
      <td>Display Name</td>
      <td><code>Azure Active Directory</code></td>
      </tr>
      <tr>
      <td>Description</td>
      <td><code>Azure AD federation for API Manager</code></td>
      </tr>
    </table>

5. Expand the **Claim Configuration** section:
   
   1. Enable **Define Custom Claim Dialect**.
   2. Add the following claim mappings:

    <table>
      <tr>
      <th><b>Identity Provider Claim URI</b></th>
      <th><b>Local Claim URI</b></th>
      </tr>
      <tr>
      <td><code>email</code></td>
      <td><code>http://wso2.org/claims/emailaddress</code></td>
      </tr>
      <tr>
      <td><code>given_name</code></td>
      <td><code>http://wso2.org/claims/givenname</code></td>
      </tr>
      <tr>
      <td><code>family_name</code></td>
      <td><code>http://wso2.org/claims/lastname</code></td>
      </tr>
      <tr>
      <td><code>sub</code></td>
      <td><code>http://wso2.org/claims/username</code></td>
      </tr>
    </table>

   3. Set the **User ID Claim URI** to `http://wso2.org/claims/username`.
   4. Set the **Role Claim URI** to `http://wso2.org/claims/role` (if role mapping is needed).

6. Expand the **Role Configuration** section:
   
   1. Add the following role mappings if you want to map Azure AD groups to WSO2 API Manager roles:

    <table>
      <tr>
      <th><b>Identity Provider Role</b></th>
      <th><b>Local Role</b></th>
      </tr>
      <tr>
      <td><code>APIM-Publishers</code></td>
      <td><code>Internal/publisher</code></td>
      </tr>
      <tr>
      <td><code>APIM-Subscribers</code></td>
      <td><code>Internal/subscriber</code></td>
      </tr>
      <tr>
      <td><code>APIM-Creators</code></td>
      <td><code>Internal/creator</code></td>
      </tr>
    </table>

7. Expand the **Federated Authenticators** section:
   
   1. Expand the **OAuth2/OpenID Connect Configuration** section.
   2. Enable the configuration and add the following details:

    <table>
      <tr>
      <th><b>Field</b></th>
      <th><b>Value</b></th>
      </tr>
      <tr>
      <td>Enable OAuth2/OpenIDConnect</td>
      <td>Select this checkbox</td>
      </tr>
      <tr>
      <td>Default</td>
      <td>Select this checkbox</td>
      </tr>
      <tr>
      <td>Client ID</td>
      <td>Application (client) ID from Azure AD</td>
      </tr>
      <tr>
      <td>Client Secret</td>
      <td>Client secret value from Azure AD</td>
      </tr>
      <tr>
      <td>Authorization Endpoint URL</td>
      <td><code>https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize</code></td>
      </tr>
      <tr>
      <td>Token Endpoint URL</td>
      <td><code>https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token</code></td>
      </tr>
      <tr>
      <td>Callback URL</td>
      <td><code>https://localhost:9443/commonauth</code></td>
      </tr>
      <tr>
      <td>Userinfo Endpoint URL</td>
      <td><code>https://graph.microsoft.com/oidc/userinfo</code></td>
      </tr>
      <tr>
      <td>OpenID Connect User ID Location</td>
      <td>User ID found among claims</td>
      </tr>
      <tr>
      <td>Additional Query Parameters</td>
      <td><code>scope=openid email profile</code></td>
      </tr>
    </table>

    !!! tip
        Replace `{tenant-id}` with the **Directory (tenant) ID** obtained from Azure AD and `localhost:9443` with the actual hostname and port of your WSO2 API Manager deployment.

8. Expand the **Just-in-Time Provisioning** section:
   
   1. Enable **Always Provision to User Store Domain** and set it to `PRIMARY`.
   2. Enable **Provision silently**.
   3. This ensures that users are automatically created in WSO2 API Manager when they log in for the first time through Azure AD.

9. Click **Register** to save the Identity Provider configuration.

## Step 3 - Update service provider configurations

### Configure Publisher service provider

1. Navigate to **Main > Service Providers > List**.

2. Select **apim_publisher**.

3. Expand the **Local and Outbound Authentication Configuration** section.

4. Select **Federated Authentication** as the **Authentication Type**.

5. Add the **AzureAD** identity provider to the authentication steps:
   
   1. Click **Add Authentication Step**.
   2. Select **AzureAD** from the **Federated Authenticators** list.
   3. Click **Add Authenticator**.

6. Click **Update** to save the changes.

### Configure Developer Portal service provider

1. Navigate to **Main > Service Providers > List**.

2. Select **apim_devportal**.

3. Expand the **Local and Outbound Authentication Configuration** section.

4. Select **Federated Authentication** as the **Authentication Type**.

5. Add the **AzureAD** identity provider to the authentication steps:
   
   1. Click **Add Authentication Step**.
   2. Select **AzureAD** from the **Federated Authenticators** list.
   3. Click **Add Authenticator**.

6. Click **Update** to save the changes.

## Step 4 - Test the configuration

1. Navigate to the API Manager Publisher Portal:
   
    ```
    https://localhost:9443/publisher
    ```

2. Click **Sign-in** to be redirected to the Azure AD login page.

3. Enter your Azure AD credentials and complete the authentication process.

4. After successful authentication, you should be redirected back to the Publisher Portal.

5. Similarly, test the Developer Portal:
   
    ```
    https://localhost:9443/devportal
    ```

## Troubleshooting

### Common issues and solutions

1. **Redirect URI mismatch error**: Ensure the redirect URI configured in Azure AD matches the callback URL in the WSO2 API Manager Identity Provider configuration.

2. **Token endpoint authentication failed**: Verify that the client ID and client secret are correctly configured in both Azure AD and WSO2 API Manager.

3. **User not found error**: Check that Just-in-Time Provisioning is enabled in the Identity Provider configuration.

4. **Claim mapping issues**: Verify that the required claims (email, given_name, family_name) are configured in Azure AD's token configuration.

5. **Permission denied in Azure AD**: Ensure that admin consent has been granted for the required Microsoft Graph permissions.

## Additional configuration

### Configure role-based access

If you want to control user access based on Azure AD groups:

1. Create security groups in Azure AD (for example, `APIM-Publishers`, `APIM-Subscribers`).

2. Assign users to the appropriate groups.

3. Configure the groups claim in Azure AD:
   
   1. Navigate to **Token configuration** in your Azure AD application.
   2. Add the `groups` claim to ID tokens.

4. Update the claim configuration in WSO2 API Manager to map the groups claim to roles.

### Enable HTTPS for production

For production deployments, ensure that you:

1. Configure SSL certificates for WSO2 API Manager.
2. Update all URLs to use HTTPS instead of HTTP.
3. Update the redirect URIs in Azure AD to use the production domain.

## Additional resources

For more information about configuring external identity providers with WSO2 API Manager, see the following resources:

- [Configuring Identity Server as External IDP using OIDC]({{base_path}}/install-and-setup/setup/sso/configuring-identity-server-as-external-idp-using-oidc)
- [Using Okta as an External IDP with OIDC]({{base_path}}/install-and-setup/setup/sso/okta-as-an-external-idp-using-oidc)
- [WSO2 API Manager Authentication Documentation]({{base_path}}/reference/customize-product/extending-api-manager/saml2-sso/multi-factor-authentication-mfa-for-publisher-and-developer-portals)

For Azure AD-specific configuration details, refer to the [Microsoft Azure Active Directory documentation](https://docs.microsoft.com/en-us/azure/active-directory/).