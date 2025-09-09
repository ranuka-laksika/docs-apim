# Configuring Azure AD Federated Authentication for Publisher and Developer Portal

!!! note
    Please follow [Configuring Identity Server as IDP for SSO]({{base_path}}/develop/extending-api-manager/saml2-sso/configuring-identity-server-as-idp-for-sso) to configure WSO2 Identity Server.
    This guide will assume you have already followed the above tutorial and configured the Identity Server as IDP for SSO.

Azure Active Directory (Azure AD) federated authentication allows users to sign in to the API Manager Publisher and Developer Portal using their Azure AD credentials. This eliminates the need for separate credentials and provides a seamless single sign-on experience.

## Prerequisites

- Azure AD tenant with administrative privileges
- WSO2 Identity Server configured as IDP for SSO
- API Manager instance with Publisher and Developer Portal

## Step 1: Configure Azure AD Application

1. Sign in to the [Azure Portal](https://portal.azure.com) with administrator credentials.

2. Navigate to **Azure Active Directory** > **App registrations** > **New registration**.

3. Configure the application:
   - **Name**: WSO2 API Manager
   - **Supported account types**: Accounts in this organizational directory only
   - **Redirect URI**: Select **Web** and enter `https://<IS_HOST>:<PORT>/commonauth`

4. Click **Register** to create the application.

5. Note down the **Application (client) ID** and **Directory (tenant) ID** from the Overview page.

## Step 2: Configure Azure AD Authentication

1. In your Azure AD application, navigate to **Authentication**.

2. Under **Implicit grant and hybrid flows**, enable:
   - **Access tokens**
   - **ID tokens**

3. Add additional redirect URIs if needed:
   - `https://<IS_HOST>:<PORT>/commonauth`
   - `https://<APIM_HOST>:<PORT>/commonauth`

4. Configure logout URL:
   - **Front-channel logout URL**: `https://<IS_HOST>:<PORT>/oidc/logout`

## Step 3: Generate Client Secret

1. Navigate to **Certificates & secrets** > **Client secrets**.

2. Click **New client secret**.

3. Provide a description and set expiration period.

4. Click **Add** and copy the **Value** (client secret). Store it securely as it won't be displayed again.

## Step 4: Configure API Permissions

1. Navigate to **API permissions**.

2. Click **Add a permission** > **Microsoft Graph**.

3. Select **Delegated permissions** and add:
   - `openid`
   - `profile`
   - `email`
   - `User.Read`

4. Click **Add permissions**.

5. Grant admin consent by clicking **Grant admin consent for [Your Organization]**.

## Step 5: Configure Token Configuration (Optional)

1. Navigate to **Token configuration**.

2. Click **Add optional claim**.

3. Select **ID** token type and add claims as needed:
   - `email`
   - `family_name`
   - `given_name`
   - `upn`

## Step 6: Configure WSO2 Identity Server

1. Sign in to the WSO2 Identity Server Management Console.

2. Navigate to **Identity Providers** > **Add**.

3. Configure the Identity Provider:
   - **Identity Provider Name**: AzureAD
   - **Display Name**: Azure Active Directory

4. Under **Federated Authenticators** > **OAuth2/OpenID Connect Configuration**:
   - Enable **OAuth2/OpenIDConnect**
   - Check **Default**
   - **Client Id**: Enter the Application (client) ID from Azure AD
   - **Client Secret**: Enter the client secret from Azure AD
   - **Authorization Endpoint URL**: `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize`
   - **Token Endpoint URL**: `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token`
   - **UserInfo Endpoint URL**: `https://graph.microsoft.com/oidc/userinfo`
   - **Logout Endpoint URL**: `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/logout`
   - **Additional Query Parameters**: `scope=openid profile email`

5. Under **Claim Configuration**:
   - **User ID Claim URI**: `sub`
   - **Role Claim URI**: `roles` (if using Azure AD roles)

6. Click **Register** to save the configuration.

## Step 7: Configure Service Provider Authentication

1. In WSO2 Identity Server, navigate to **Service Providers**.

2. Edit the service provider configured for API Manager.

3. Under **Local & Outbound Authentication Configuration**:
   - Select **Federated Authentication**
   - Choose **AzureAD** from the dropdown

4. Under **Claim Configuration**:
   - Add `http://wso2.org/claims/role` as the Claim URI
   - Select the **Mandatory Claim** checkbox
   - Add `http://wso2.org/claims/username` as the Subject Claim URI

5. Click **Update** to save the changes.

## Step 8: Configure Role Mapping (Optional)

If you want to map Azure AD roles to WSO2 API Manager roles:

1. In the AzureAD Identity Provider configuration, navigate to **Role Mappings**.

2. Map Azure AD roles to corresponding API Manager roles:
   - Azure AD Role → API Manager Role
   - Example: `admin` → `admin`
   - Example: `developer` → `Internal/subscriber`

## Step 9: Enable Just-In-Time (JIT) Provisioning

1. In the AzureAD Identity Provider configuration, enable **Just-in-Time Provisioning**.

2. Configure provisioning settings:
   - **User Store Domain**: PRIMARY
   - **Provisioning enabled**: Yes
   - **Prompt for username, password and consent**: No
   - **Associate the provisioned local user with the federated subject**: Yes

## Testing the Configuration

1. Navigate to the API Manager Publisher or Developer Portal.

2. Click on the sign-in button.

3. You should be redirected to Azure AD login page.

4. Enter your Azure AD credentials.

5. Upon successful authentication, you should be redirected back to the API Manager portal.

## Troubleshooting

### Common Issues:

1. **Authentication fails**: 
   - Verify the client ID and secret are correct
   - Check that redirect URIs match exactly
   - Ensure proper API permissions are granted

2. **User not provisioned**:
   - Check JIT provisioning settings
   - Verify claim mappings are correct
   - Check WSO2 Identity Server logs

3. **Role mapping issues**:
   - Verify role claim configuration in Azure AD
   - Check role mappings in WSO2 Identity Server
   - Ensure roles exist in API Manager

### Useful Logs:

- WSO2 Identity Server: `<IS_HOME>/repository/logs/wso2carbon.log`
- API Manager: `<APIM_HOME>/repository/logs/wso2carbon.log`

!!! tip
    For more information on OAuth2/OpenID Connect configurations, see [WSO2 Identity Server OAuth2/OpenID Connect Documentation](https://is.docs.wso2.com/en/latest/guides/identity-federation/oauth2-oidc/).

!!! info
    This configuration supports both SAML2 and OAuth2/OpenID Connect protocols. Choose the appropriate protocol based on your organizational requirements and Azure AD setup.