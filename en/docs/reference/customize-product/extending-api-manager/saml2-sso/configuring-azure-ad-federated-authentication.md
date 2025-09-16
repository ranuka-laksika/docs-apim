# Configure Azure AD federated authentication for Publisher and Developer Portal

Azure Active Directory (Azure AD) federated authentication enables users to sign in to the WSO2 API Manager Publisher and Developer Portal using their Azure AD credentials. This eliminates the need for users to maintain separate credentials and provides a seamless single sign-on (SSO) experience.

This guide demonstrates how to configure Azure AD as an external identity provider for WSO2 API Manager using OpenID Connect (OIDC) protocol.

## Prerequisites

- Azure AD tenant with administrative access
- WSO2 API Manager 4.6.0 or later
- WSO2 Identity Server configured as the identity provider for API Manager (recommended)

!!! info
    This guide assumes you have basic knowledge of Azure AD concepts and WSO2 Identity Server configuration. For foundational setup, see [Configuring Identity Server as IDP for SSO]({{base_path}}/reference/customize-product/extending-api-manager/saml2-sso/configuring-identity-server-as-idp-for-sso).

## Configure Azure AD

### Step 1 - Register an application in Azure AD

1. Sign in to the [Azure portal](https://portal.azure.com).

2. Navigate to **Azure Active Directory** > **App registrations** > **New registration**.

3. Configure the application:
   - **Name**: Enter a name for your application (e.g., "WSO2 API Manager SSO")
   - **Supported account types**: Select "Accounts in this organizational directory only"
   - **Redirect URI**: Select "Web" and enter:
     ```
     https://<WSO2_IS_HOST>:<WSO2_IS_PORT>/commonauth
     ```
     Replace `<WSO2_IS_HOST>` and `<WSO2_IS_PORT>` with your WSO2 Identity Server host and port.

4. Click **Register**.

### Step 2 - Configure authentication settings

1. In the application overview, note the **Application (client) ID** and **Directory (tenant) ID**.

2. Navigate to **Authentication** and configure:
   - **Front-channel logout URL**: 
     ```
     https://<WSO2_IS_HOST>:<WSO2_IS_PORT>/oidc/logout
     ```
   - **ID tokens**: Enable ID tokens
   - **Access tokens**: Enable access tokens

### Step 3 - Create client secret

1. Navigate to **Certificates & secrets** > **Client secrets** > **New client secret**.

2. Configure the secret:
   - **Description**: Enter a description (e.g., "WSO2 IS Client Secret")
   - **Expires**: Select an appropriate expiration period

3. Click **Add** and copy the generated secret value immediately.

!!! warning
    The secret value is only displayed once. Make sure to copy and store it securely.

### Step 4 - Configure API permissions (optional)

If you need to access additional user information, configure API permissions:

1. Navigate to **API permissions** > **Add a permission**.
2. Select **Microsoft Graph** > **Delegated permissions**.
3. Add required permissions (e.g., `User.Read`, `profile`, `email`).
4. Click **Grant admin consent** if required by your organization.

### Step 5 - Collect configuration details

Gather the following information from Azure AD:

- **Client ID**: Application (client) ID from the app registration
- **Client Secret**: The secret value created in Step 3
- **Tenant ID**: Directory (tenant) ID from the app registration
- **Authorization Endpoint**: 
  ```
  https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize
  ```
- **Token Endpoint**: 
  ```
  https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token
  ```
- **Userinfo Endpoint**: 
  ```
  https://graph.microsoft.com/oidc/userinfo
  ```
- **Logout Endpoint**: 
  ```
  https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/logout
  ```

## Configure WSO2 Identity Server

### Step 1 - Add Azure AD as an identity provider

1. Sign in to the WSO2 Identity Server Management Console.

2. Navigate to **Main** > **Identity** > **Identity Providers** > **Add**.

3. Configure the basic information:
   - **Identity Provider Name**: `AzureAD`
   - **Display Name**: `Azure Active Directory`
   - **Description**: `Azure AD federated authentication for API Manager`

### Step 2 - Configure OIDC settings

1. Expand **Federated Authenticators** > **OAuth2/OpenID Connect Configuration**.

2. Configure the following settings:

   | Property | Value |
   |----------|-------|
   | Enable OAuth2/OpenIDConnect | ✓ |
   | Default | ✓ |
   | Client ID | Application (client) ID from Azure AD |
   | Client Secret | Client secret from Azure AD |
   | Authorization Endpoint URL | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize` |
   | Token Endpoint URL | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token` |
   | Callback URL | `https://<WSO2_IS_HOST>:<WSO2_IS_PORT>/commonauth` |
   | Userinfo Endpoint URL | `https://graph.microsoft.com/oidc/userinfo` |
   | Logout Endpoint URL | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/logout` |
   | Additional Query Parameters | `scope=openid profile email` |

3. Click **Update**.

### Step 3 - Configure claim mappings

1. Expand **Claim Configuration** and configure claim mappings:

   | Local Claim | Remote Claim |
   |-------------|--------------|
   | http://wso2.org/claims/username | preferred_username |
   | http://wso2.org/claims/fullname | name |
   | http://wso2.org/claims/emailaddress | email |
   | http://wso2.org/claims/givenname | given_name |
   | http://wso2.org/claims/lastname | family_name |

2. Set **Subject Claim URI**: `http://wso2.org/claims/username`

### Step 4 - Enable just-in-time provisioning

1. Expand **Just-in-Time Provisioning** and configure:
   - **Enable Just-in-Time Provisioning**: ✓
   - **Provisioning User Store Domain**: `PRIMARY`
   - **Username Attribute**: `preferred_username`

## Configure service providers for API Manager

### Step 1 - Configure Publisher service provider

1. Navigate to **Main** > **Identity** > **Service Providers** and select the Publisher service provider.

2. Expand **Local & Outbound Authentication Configuration**.

3. Select **Federated Authentication** and choose `AzureAD` from the dropdown.

4. Click **Update**.

### Step 2 - Configure Developer Portal service provider

1. Navigate to **Main** > **Identity** > **Service Providers** and select the Developer Portal service provider.

2. Expand **Local & Outbound Authentication Configuration**.

3. Select **Federated Authentication** and choose `AzureAD` from the dropdown.

4. Click **Update**.

## Test the configuration

### Test Publisher Portal authentication

1. Navigate to the Publisher Portal: `https://<APIM_HOST>:<APIM_PORT>/publisher`

2. Click **Login**.

3. You should be redirected to Azure AD login page.

4. Sign in with your Azure AD credentials.

5. Upon successful authentication, you should be redirected back to the Publisher Portal.

### Test Developer Portal authentication

1. Navigate to the Developer Portal: `https://<APIM_HOST>:<APIM_PORT>/devportal`

2. Click **Sign In**.

3. You should be redirected to Azure AD login page.

4. Sign in with your Azure AD credentials.

5. Upon successful authentication, you should be redirected back to the Developer Portal.

## Troubleshooting

### Common issues and solutions

**Issue**: Users cannot sign in and receive "Authentication Failed" error.

**Solution**: Verify the following:
- Client ID and client secret are correctly configured
- Redirect URI in Azure AD matches the WSO2 IS callback URL
- Clock synchronization between servers
- Network connectivity between WSO2 IS and Azure AD

**Issue**: Users are authenticated but have no permissions in API Manager.

**Solution**: 
- Verify user role mappings in WSO2 Identity Server
- Ensure just-in-time provisioning is enabled and configured correctly
- Check if the user exists in the API Manager user store

**Issue**: Token validation fails with signature verification errors.

**Solution**:
- Verify the token endpoint URL configuration
- Check if the issuer claim matches the expected value
- Ensure proper claim mappings are configured

### Enable debug logs

To troubleshoot authentication issues, enable debug logging:

1. Edit `<IS_HOME>/repository/conf/log4j2.properties`.

2. Add the following logger configuration:
   ```
   logger.org-wso2-carbon-identity-oauth.name = org.wso2.carbon.identity.oauth
   logger.org-wso2-carbon-identity-oauth.level = DEBUG
   logger.org-wso2-carbon-identity-oauth.additivity = false
   logger.org-wso2-carbon-identity-oauth.appenderRef.CARBON_CONSOLE.ref = CARBON_CONSOLE
   ```

3. Restart WSO2 Identity Server.

4. Monitor the logs in `<IS_HOME>/repository/logs/wso2carbon.log` for authentication-related entries.

## Additional resources

- [Azure Active Directory documentation](https://docs.microsoft.com/en-us/azure/active-directory/)
- [OpenID Connect specification](https://openid.net/connect/)
- [WSO2 Identity Server documentation](https://is.docs.wso2.com/)
- [Configuring Identity Server as IDP for SSO]({{base_path}}/reference/customize-product/extending-api-manager/saml2-sso/configuring-identity-server-as-idp-for-sso)