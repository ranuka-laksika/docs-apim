# Configure Azure AD Federated Authentication

WSO2 API Manager supports federated authentication, which allows users to log in to the Publisher Portal and Developer Portal using their Azure Active Directory (Azure AD) credentials. This eliminates the need to maintain separate user credentials and provides seamless Single Sign-On (SSO) experience.

\!\!\! info
    This guide covers federated authentication for the Publisher and Developer portals. For configuring Azure AD as a Key Manager for API access tokens, refer to [Configure Azure AD as a Key Manager]({{base_path}}/administer/key-managers/configure-azure-ad-key-manager).

## Prerequisites

Before you begin, ensure that you have:

1. An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/en-gb/free/).
2. The Azure account must have permission to manage applications in Azure Active Directory (Azure AD). Any of the following Azure AD roles include the required permissions:
   - Application administrator
   - Application developer  
   - Cloud application administrator
3. WSO2 API Manager 4.4.0 or later version installed and running.
4. Administrative access to WSO2 API Manager.

## Step 1: Configure Azure AD Application

### Create Azure AD Application

1. Sign in to the [Azure portal](https://portal.azure.com/).

2. Navigate to **Azure Active Directory** > **App registrations** > **New registration**.

3. Fill in the application details:
   - **Name**: Give a meaningful name (e.g., "WSO2 API Manager SSO")
   - **Supported account types**: Select "Accounts in this organizational directory only" for single tenant or "Accounts in any organizational directory" for multi-tenant
   - **Redirect URI**: 
     - Platform: Web
     - URI: `https://<APIM_HOST>:<APIM_PORT>/commonauth`
     
     Replace `<APIM_HOST>` and `<APIM_PORT>` with your API Manager's hostname and port.

4. Click **Register** to create the application.

### Configure Authentication Settings

1. In your newly created application, navigate to **Authentication**.

2. Under **Redirect URIs**, ensure the following URIs are added:
   - `https://<APIM_HOST>:<APIM_PORT>/commonauth`
   - `https://<APIM_HOST>:<APIM_PORT>/publisher/services/auth/callback/login`
   - `https://<APIM_HOST>:<APIM_PORT>/devportal/services/auth/callback/login`

3. Under **Implicit grant and hybrid flows**, ensure the following are selected:
   - **Access tokens** (for implicit flows)
   - **ID tokens** (for implicit flows)

4. Click **Save**.

### Generate Client Secret

1. Navigate to **Certificates & secrets**.

2. Click **New client secret**.

3. Provide a description and set the expiration period.

4. Click **Add** and copy the client secret value immediately (it won't be shown again).

### Configure API Permissions

1. Navigate to **API permissions**.

2. Click **Add a permission** > **Microsoft Graph** > **Delegated permissions**.

3. Add the following permissions:
   - `openid`
   - `profile`
   - `email`
   - `User.Read`

4. Click **Add permissions**.

5. Click **Grant admin consent for [Your Directory Name]**.

### Note Application Details

From the **Overview** page, note down the following values:
- **Application (client) ID**
- **Directory (tenant) ID**

## Step 2: Configure WSO2 API Manager

### Configure Identity Provider

1. Log in to the WSO2 API Manager Management Console at `https://<APIM_HOST>:<APIM_PORT>/carbon`.

2. Navigate to **Main** > **Identity** > **Identity Providers** > **Add**.

3. Fill in the basic information:
   - **Identity Provider Name**: `AzureAD`
   - **Display Name**: `Azure Active Directory`
   - **Description**: Optional description for the identity provider

4. Expand **Federated Authenticators** > **OAuth2/OpenID Connect Configuration**.

5. Select **Enable OAuth2/OpenIDConnect** and **Default**.

6. Fill in the OAuth2/OpenID Connect configuration:
   
   | Configuration | Value |
   |---------------|--------|
   | **Client Id** | Application (client) ID from Azure |
   | **Client Secret** | Client secret generated in Azure |
   | **Authorization Endpoint URL** | `https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/authorize` |
   | **Token Endpoint URL** | `https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token` |
   | **Callback URL** | `https://<APIM_HOST>:<APIM_PORT>/commonauth` |
   | **Userinfo Endpoint URL** | `https://graph.microsoft.com/oidc/userinfo` |
   | **Logout Endpoint URL** | `https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/logout` |
   | **Additional Query Parameters** | `scope=openid profile email` |

   Replace `<TENANT_ID>` with your Azure AD tenant ID.

7. Expand **Claim Configuration**.

8. Configure the following claim mappings:

   | Local Claim | Remote Claim |
   |-------------|---------------|
   | `http://wso2.org/claims/username` | `preferred_username` |
   | `http://wso2.org/claims/fullname` | `name` |
   | `http://wso2.org/claims/emailaddress` | `email` |
   | `http://wso2.org/claims/givenname` | `given_name` |
   | `http://wso2.org/claims/lastname` | `family_name` |

9. Set **Subject Claim URI** to `preferred_username`.

10. Set **Role Claim URI** to `groups` (if you want to map Azure AD groups to roles).

11. Click **Register** to save the identity provider configuration.

### Configure Service Providers

#### Configure Publisher Portal

1. In the Management Console, navigate to **Main** > **Identity** > **Service Providers** > **List**.

2. Find **apim_publisher** and click **Edit**.

3. Expand **Local and Outbound Authentication Configuration**.

4. Select **Federated Authentication** as the authentication type.

5. Select **AzureAD** from the federated identity provider dropdown.

6. Click **Update**.

#### Configure Developer Portal

1. Find **apim_devportal** and click **Edit**.

2. Expand **Local and Outbound Authentication Configuration**.

3. Select **Federated Authentication** as the authentication type.

4. Select **AzureAD** from the federated identity provider dropdown.

5. Click **Update**.

## Step 3: Configure User Attribute Mapping (Optional)

If you need to map additional Azure AD user attributes to WSO2 claims:

1. In the identity provider configuration, expand **Claim Configuration**.

2. Add additional claim mappings as needed.

3. If you want to use Azure AD groups for role-based access control:
   - Set up group claims in Azure AD application
   - Map the `groups` claim to `http://wso2.org/claims/role`
   - Configure appropriate role mappings

## Step 4: Test the Configuration

### Test Publisher Portal SSO

1. Navigate to the Publisher Portal: `https://<APIM_HOST>:<APIM_PORT>/publisher`

2. You should be redirected to Azure AD login page.

3. Log in with your Azure AD credentials.

4. Upon successful authentication, you should be redirected back to the Publisher Portal.

### Test Developer Portal SSO

1. Navigate to the Developer Portal: `https://<APIM_HOST>:<APIM_PORT>/devportal`

2. You should be redirected to Azure AD login page.

3. Log in with your Azure AD credentials.

4. Upon successful authentication, you should be redirected back to the Developer Portal.

## Troubleshooting

### Common Issues and Solutions

1. **Redirect URI Mismatch**
   - Ensure all redirect URIs are properly configured in Azure AD application
   - Verify the callback URL in WSO2 API Manager matches the redirect URI in Azure

2. **Invalid Client Error**
   - Check that the Client ID and Client Secret are correctly configured
   - Verify the client secret hasn't expired

3. **Insufficient Permissions**
   - Ensure proper API permissions are granted in Azure AD
   - Check that admin consent has been granted for the permissions

4. **User Not Found Error**
   - Verify the claim mappings are correct
   - Check that the Subject Claim URI matches the claim sent by Azure AD

5. **SSL/Certificate Issues**
   - Ensure proper SSL certificates are configured
   - Verify that the endpoints use HTTPS

### Logs for Debugging

Enable the following loggers in `<APIM_HOME>/repository/conf/log4j2.properties` for debugging:

```properties
logger.org-wso2-carbon-identity-application-authentication-framework.name = org.wso2.carbon.identity.application.authentication.framework
logger.org-wso2-carbon-identity-application-authentication-framework.level = DEBUG

logger.org-wso2-carbon-identity-oauth.name = org.wso2.carbon.identity.oauth
logger.org-wso2-carbon-identity-oauth.level = DEBUG
```

## Additional Resources

- [Azure Active Directory Documentation](https://docs.microsoft.com/en-us/azure/active-directory/)
- [WSO2 Identity Server Federated Authentication](https://is.docs.wso2.com/en/latest/guides/identity-federation/)
- [WSO2 API Manager Identity Integration](https://apim.docs.wso2.com/en/latest/administer/managing-users-and-roles/introduction-to-user-management/)

\!\!\! note
    This configuration enables federated authentication for user login to Publisher and Developer portals. For API access token management using Azure AD, refer to the [Azure AD Key Manager configuration]({{base_path}}/administer/key-managers/configure-azure-ad-key-manager).
EOF < /dev/null