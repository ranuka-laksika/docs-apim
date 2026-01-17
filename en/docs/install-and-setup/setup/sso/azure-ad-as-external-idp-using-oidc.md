# Using Azure AD as an External IDP with OIDC

Follow the instructions below to connect Azure Active Directory (Azure AD) as a third-party Identity Provider to WSO2 API Manager for federated authentication in the Publisher and Developer Portal.

## Prerequisites

Before you begin, make sure you do the following.

1. Create an Azure account that has an active subscription. [Create an account for free](https://azure.microsoft.com/en-gb/free/?WT.mc_id=A261C142F).
2. The Azure account must have permission to manage applications in Azure Active Directory. Any of the following Azure AD roles include the required permissions:
   - Application administrator
   - Application developer
   - Cloud application administrator
3. Download the WSO2 API Manager distribution from [https://wso2.com/api-management/](https://wso2.com/api-management/).
4. Enable the email domain on WSO2 API Manager.

   You need to enable this because Azure AD uses the email as the username by default. As the email domain is not enabled by default, you have to enable it to use the email as the username in WSO2 API Manager.

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
    For more information on working with Azure AD, see the [official Azure Entra ID documentation](https://learn.microsoft.com/en-us/entra/identity/).

1. Navigate to the [Azure Portal](https://portal.azure.com/).

2. Navigate to [Microsoft Entra ID](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview).

3. Add an application in Azure AD.

   1. Navigate to [App Registration](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps).
   2. Click **New registration**.
   3. Create an application based on the following application settings:

   <table>
     <tr>
       <th><b>Field</b></th>
       <th><b>Value</b></th>
     </tr>
     <tr>
       <td>Name</td>
       <td><code>WSO2-API-Manager-SSO</code></td>
     </tr>
     <tr>
       <td>Supported account types</td>
       <td>Accounts in this organizational directory only (Single tenant)</td>
     </tr>
     <tr>
       <td>Redirect URI (optional)</td>
       <td>Platform: <code>Web</code><br>
           URI: <code>https://localhost:9443/commonauth</code></td>
     </tr>
   </table>

   4. Click **Register**.

4. Configure the application authentication settings.

   1. Navigate to **Authentication** in the left panel.
   2. Under **Redirect URIs**, add the following URIs:
      - `https://localhost:9443/commonauth` (Publisher and DevPortal common auth endpoint)
      - `https://localhost:9443/publisher/services/auth/callback/login` (Publisher callback)
      - `https://localhost:9443/devportal/services/auth/callback/login` (DevPortal callback)
   3. Under **Front-channel logout URL**, add:
      - `https://localhost:9443/oidc/logout`
   4. Under **Implicit grant and hybrid flows**, select:
      - **ID tokens (used for implicit and hybrid flows)**
   5. Click **Save**.

5. Configure application permissions.

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
   7. Click **Grant admin consent for Default Directory**.

6. Create client secrets.

   1. Navigate to **Certificates & secrets**.
   2. Under **Client secrets**, click **New client secret**.
   3. Add a description and select the expiry period.
   4. Click **Add**.
   5. Copy the secret value immediately (it will be hidden after you navigate away).

7. Note down the application details.

   From the **Overview** page, note down:
   - **Application (client) ID**
   - **Directory (tenant) ID**
   - **Client secret** (from the previous step)

## Step 2 - Configure WSO2 API Manager

1. Navigate to the `<API-M_HOME>/repository/conf/` directory and open the `deployment.toml` file.

2. Add the following configuration to enable Azure AD as an Identity Provider:

   ```toml
   [authentication.authenticator.oidc]
   name = "OIDCAuthenticator"
   enable = true
   [authentication.authenticator.oidc.parameters]
   ClientId = "<Azure_AD_Application_Client_ID>"
   ClientSecret = "<Azure_AD_Client_Secret>"
   AuthorizationEndpointURL = "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize"
   TokenEndpointURL = "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token"
   CallbackUrl = "https://localhost:9443/commonauth"
   Scope = "openid profile email"
   AdditionalRequestParams = "prompt=select_account"
   
   [[authentication.custom_authenticator]]
   name = "OIDCAuthenticator"
   enable = true
   [authentication.custom_authenticator.parameters]
   ClientId = "<Azure_AD_Application_Client_ID>"
   ClientSecret = "<Azure_AD_Client_Secret>"
   AuthorizationEndpointURL = "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize"
   TokenEndpointURL = "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token"
   CallbackUrl = "https://localhost:9443/commonauth"
   Scope = "openid profile email"
   AdditionalRequestParams = "prompt=select_account"
   ```

   \!\!\! note
       Replace the following placeholders:
       - `<Azure_AD_Application_Client_ID>` - The Application (client) ID from Azure AD
       - `<Azure_AD_Client_Secret>` - The client secret value from Azure AD
       - `<tenant-id>` - The Directory (tenant) ID from Azure AD

3. Configure user store settings for Azure AD users.

   Add the following configuration to map Azure AD user attributes:

   ```toml
   [user_store]
   type = "database"
   
   [user_store.properties]
   UsernameAttribute = "preferred_username"
   UserNameAttribute = "preferred_username"
   UserIdAttribute = "sub"
   EmailAttribute = "email"
   FirstNameAttribute = "given_name"
   LastNameAttribute = "family_name"
   DisplayNameAttribute = "name"
   ```

4. Enable federated authentication for Publisher and Developer Portal.

   Add the following configuration to enable OIDC authentication for both portals:

   ```toml
   [apim.authentication]
   enable_sso = true
   
   [apim.devportal]
   enable_application_sharing = true
   enable_comments = true
   enable_ratings = true
   enable_forum = true
   enable_anonymous_mode = true
   
   [apim.devportal.application_sharing]
   enable_jwt_generation = true
   
   [[apim.authentication.publisher]]
   name = "OIDCAuthenticator"
   enable = true
   
   [[apim.authentication.devportal]]
   name = "OIDCAuthenticator"
   enable = true
   ```

## Step 3 - Test the Configuration

1. Restart the WSO2 API Manager server.

2. Test Publisher Portal SSO:
   1. Navigate to `https://localhost:9443/publisher`.
   2. You should see an option to **Sign In with Azure AD** or be redirected to Azure AD login.
   3. Enter your Azure AD credentials.
   4. You should be redirected back to the Publisher Portal upon successful authentication.

3. Test Developer Portal SSO:
   1. Navigate to `https://localhost:9443/devportal`.
   2. You should see an option to **Sign In with Azure AD** or be redirected to Azure AD login.
   3. Enter your Azure AD credentials.
   4. You should be redirected back to the Developer Portal upon successful authentication.

## Troubleshooting

### Common Issues

1. **Redirect URI mismatch error**
   - Ensure that all redirect URIs are properly configured in Azure AD application settings.
   - Verify that the `CallbackUrl` in the configuration matches one of the redirect URIs in Azure AD.

2. **Invalid client error**
   - Verify that the Client ID and Client Secret are correctly copied from Azure AD.
   - Check that the client secret has not expired.

3. **Permission denied error**
   - Ensure that the required permissions are granted and admin consent is provided in Azure AD.

4. **User not found in local user store**
   - Configure proper user attribute mapping in the `user_store.properties` section.
   - Enable email domain if users authenticate with email addresses.

### Logs

Check the following log files for troubleshooting:
- `<API-M_HOME>/repository/logs/wso2carbon.log`
- `<API-M_HOME>/repository/logs/audit.log`

Enable debug logs for authentication by adding the following to `<API-M_HOME>/repository/conf/log4j2.properties`:

```properties
logger.oidc-authenticator.name = org.wso2.carbon.identity.authenticator.oidc
logger.oidc-authenticator.level = DEBUG
logger.oidc-authenticator.additivity = false
logger.oidc-authenticator.appenderRef.CARBON_CONSOLE.ref = CARBON_CONSOLE
```

## Additional Resources

- [Azure Entra ID documentation](https://learn.microsoft.com/en-us/entra/identity/)
- [WSO2 Identity Server documentation](https://is.docs.wso2.com/)
- [WSO2 API Manager authentication documentation]({{base_path}}/administer/managing-users-and-roles/introduction-to-user-management/)

\!\!\! tip
    For production environments, replace `localhost:9443` with your actual domain name and ensure proper SSL certificates are configured.
EOF < /dev/null