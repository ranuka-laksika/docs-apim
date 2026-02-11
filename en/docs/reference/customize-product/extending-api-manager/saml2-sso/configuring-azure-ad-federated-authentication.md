# Configuring Azure Active Directory federated authentication

Azure Active Directory (Azure AD) can be configured as a federated identity provider for WSO2 API Manager, enabling single sign-on (SSO) for both the Publisher and Developer Portal. This guide walks you through the complete configuration process using OAuth 2.0 and OpenID Connect protocols.

## Prerequisites

Before you begin, ensure you have the following:

- Administrative access to Azure AD tenant
- Running WSO2 API Manager instance (version 4.3.0)
- Administrative access to WSO2 API Manager
- SSL certificates properly configured (recommended for production)

## Step 1: Configure Azure AD application

1. Sign in to the Azure portal and navigate to **Azure Active Directory**.

2. Go to **App registrations** and select **New registration**.

3. Configure the application:
   - **Name**: WSO2 API Manager
   - **Supported account types**: Accounts in this organizational directory only
   - **Redirect URI**: 
     - Type: Web
     - URL: `https://<APIM_HOST>:<PORT>/publisher/login/callback/azuread` for Publisher
     - URL: `https://<APIM_HOST>:<PORT>/devportal/login/callback/azuread` for Developer Portal

4. Click **Register** to create the application.

5. Note the following values from the application overview:
   - **Application (client) ID**
   - **Directory (tenant) ID**

6. Navigate to **Certificates & secrets** and create a new client secret:
   - Click **New client secret**
   - Add description and set expiration
   - Copy the **Value** (this is your client secret)

7. Configure API permissions:
   - Go to **API permissions**
   - Add the following Microsoft Graph permissions:
     - `openid`
     - `profile`
     - `email`
     - `User.Read`

8. Grant admin consent for the configured permissions.

## Step 2: Configure WSO2 API Manager

### Configure the identity provider

1. Start WSO2 API Manager and access the Management Console:
   `https://<APIM_HOST>:<PORT>/carbon`

2. Navigate to **Main > Identity > Identity Providers > Add**.

3. Configure the identity provider with the following settings:

   **Basic Information:**
   - **Identity Provider Name**: AzureAD
   - **Display Name**: Azure Active Directory
   - **Description**: Azure AD Federated Authentication

   **Federated Authenticators > OAuth2/OpenID Connect Configuration:**
   - **Enable OAuth2/OpenIDConnect**: Checked
   - **Default**: Checked
   - **Client ID**: Your Azure AD Application (client) ID
   - **Client Secret**: Your Azure AD client secret
   - **Authorization Endpoint URL**: `https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize`
   - **Token Endpoint URL**: `https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token`
   - **Userinfo Endpoint URL**: `https://graph.microsoft.com/v1.0/me`
   - **Logout Endpoint URL**: `https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/logout`
   - **Scope**: `openid profile email`
   - **Enable HTTP basic auth for client authentication**: Checked

   Replace `{tenant-id}` with your Azure AD Directory (tenant) ID.

4. Configure **Claim Configuration**:
   - **User ID Claim**: `sub`
   - **Role Claim**: Leave empty (roles will be managed in API Manager)

5. Click **Register** to save the configuration.

### Configure service providers

#### Publisher service provider

1. Navigate to **Main > Identity > Service Providers > List**.

2. Find the **apim_publisher** service provider and click **Edit**.

3. Configure **Local & Outbound Authentication Configuration**:
   - **Authentication Type**: Federated Authentication
   - Select **AzureAD** from the federated identity providers list

4. Configure **Claim Configuration**:
   - **Subject Claim URI**: `http://wso2.org/claims/username`
   - **Requested Claims**: Add the following claims:
     - `http://wso2.org/claims/username` (Required: Yes)
     - `http://wso2.org/claims/emailaddress` (Required: No)
     - `http://wso2.org/claims/givenname` (Required: No)
     - `http://wso2.org/claims/lastname` (Required: No)

5. Click **Update** to save the configuration.

#### Developer Portal service provider

1. Navigate to **Main > Identity > Service Providers > List**.

2. Find the **apim_devportal** service provider and click **Edit**.

3. Repeat the same configuration steps as the Publisher service provider.

## Step 3: Configure user attributes mapping

1. Navigate back to your Azure AD identity provider configuration.

2. Under **Claim Configuration**, configure the claim mappings:
   - **Local Claim**: `http://wso2.org/claims/username`
   - **Remote Claim**: `preferred_username`
   - **Local Claim**: `http://wso2.org/claims/emailaddress`
   - **Remote Claim**: `email`
   - **Local Claim**: `http://wso2.org/claims/givenname`
   - **Remote Claim**: `given_name`
   - **Local Claim**: `http://wso2.org/claims/lastname`
   - **Remote Claim**: `family_name`

3. Click **Update** to save the configuration.

## Step 4: Configure role mapping (optional)

If you need to map Azure AD groups to WSO2 API Manager roles:

1. In Azure AD, ensure your application has the **Groups** claim configured.

2. In the WSO2 API Manager identity provider configuration:
   - **Role Claim**: `groups`

3. Navigate to **Main > Identity > Identity Providers > List > AzureAD > Outbound Provisioning Roles**.

4. Map Azure AD group IDs to appropriate WSO2 API Manager roles:
   - **Identity Provider Role**: Azure AD group object ID
   - **Local Role**: WSO2 API Manager role (e.g., `Internal/publisher`, `Internal/subscriber`)

## Step 5: Test the configuration

1. Open a new browser session and navigate to the Publisher portal:
   `https://<APIM_HOST>:<PORT>/publisher`

2. You should see an **Azure Active Directory** login option.

3. Click on it and authenticate using your Azure AD credentials.

4. Upon successful authentication, you should be logged into the Publisher portal.

5. Repeat the same test for the Developer Portal:
   `https://<APIM_HOST>:<PORT>/devportal`

## Troubleshooting

### Common issues and solutions

**Issue: User gets "Access Denied" error**
- **Solution**: Ensure the user has appropriate permissions in WSO2 API Manager or configure Just-In-Time (JIT) provisioning.

**Issue: Claims not mapping correctly**
- **Solution**: Verify claim mappings in both Azure AD application manifest and WSO2 API Manager identity provider configuration.

**Issue: Authentication fails silently**
- **Solution**: Check the WSO2 API Manager logs for detailed error messages and verify redirect URIs match exactly.

**Issue: Session timeout issues**
- **Solution**: Configure appropriate session timeout values in both Azure AD and WSO2 API Manager.

### Enable debug logs

To enable debug logs for troubleshooting authentication issues:

1. Edit `<APIM_HOME>/repository/conf/log4j2.properties`.

2. Add the following logger configuration:
   ```properties
   logger.oauth.name = org.wso2.carbon.identity.oauth
   logger.oauth.level = DEBUG
   logger.oauth.additivity = false
   logger.oauth.appenderRef.CARBON_CONSOLE.ref = CARBON_CONSOLE
   ```

3. Restart WSO2 API Manager to apply the changes.

## Security considerations

- Use HTTPS for all endpoints in production environments
- Regularly rotate client secrets in Azure AD
- Configure appropriate session timeout values
- Monitor authentication logs for suspicious activities
- Consider implementing conditional access policies in Azure AD
- Ensure proper network security between WSO2 API Manager and Azure AD

## Additional resources

- [Azure AD OAuth 2.0 and OpenID Connect documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc)
- [WSO2 API Manager Identity Provider Configuration](https://apim.docs.wso2.com/en/latest/administer/managing-users-and-roles/managing-user-stores/configure-primary-user-store/configuring-the-primary-user-store/)
- [OAuth 2.0 and OpenID Connect troubleshooting guide](https://docs.microsoft.com/en-us/azure/active-directory/develop/reference-aadsts-error-codes)