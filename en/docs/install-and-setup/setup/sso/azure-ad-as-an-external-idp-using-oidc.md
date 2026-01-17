# Using Azure AD as an External IDP with OIDC

Follow the instructions below to connect Microsoft Azure Active Directory (Azure AD) as a third-party Identity Provider to WSO2 API Manager for federated authentication in the Publisher and Developer Portal.

## Prerequisites

Before you begin, make sure you do the following.

1. Create an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/en-gb/free/?WT.mc_id=A261C142F).
2. The Azure account must have permission to manage applications in Azure Active Directory. Any of the following Azure AD roles include the required permissions:
   - Application administrator
   - Application developer
   - Cloud application administrator
3. Download the WSO2 API Manager distribution from [https://wso2.com/api-management/](https://wso2.com/api-management/).
4. Enable the email domain on WSO2 API Manager.

   You need to enable this because Azure AD uses the email as the username by default. As the email domain is not enabled by default, you have to enable it to use the email as the username in WSO2 API Manager. Once enabled, you can use your email or a normal username as your username.

   Follow the instructions below:

   1. Unzip the WSO2 API Manager distribution.
   2. Open the `deployment.toml` file, which is located in the `<API-M_HOME>/repository/conf/` directory.
   3. Add the following configuration.

      ```toml
      [tenant_mgt]
      enable_email_domain = true
      ```

5. Start the WSO2 API Manager server.

## Step 1 - Configure Azure AD

!!! info
    For more information on working with Azure AD, see the [Microsoft Entra ID documentation](https://learn.microsoft.com/en-us/entra/identity/).

### Create an App Registration

1. Sign in to the [Azure portal](https://portal.azure.com/#home).
2. Navigate to [Microsoft Entra ID](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview).
3. Navigate to [App registrations](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps).
4. Click **New registration** and configure the application with the following settings:

   <table>
     <thead>
       <tr>
         <th><b>Field</b></th>
         <th><b>Value</b></th>
       </tr>
     </thead>
     <tbody>
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
         <td>Web: <code>https://localhost:9443/commonauth</code></td>
       </tr>
     </tbody>
   </table>

5. Click **Register** to create the application.

### Configure Authentication Settings

1. In your newly created app registration, navigate to **Authentication**.
2. Under **Redirect URIs**, ensure the following URIs are added:
   - `https://localhost:9443/commonauth` (for local development)
   - `https://<your-apim-host>:9443/commonauth` (for production deployment)

3. Under **Implicit grant and hybrid flows**, enable:
   - **ID tokens (used for implicit and hybrid flows)**

4. Click **Save**.

### Create a Client Secret

1. Navigate to **Certificates & secrets** in your app registration.
2. Under **Client secrets**, click **New client secret**.
3. Provide a description and set the expiration period.
4. Click **Add**.
5. **Important**: Copy the secret value immediately as it will not be visible again.

### Configure API Permissions

1. Navigate to **API permissions** in your app registration.
2. Click **Add a permission**.
3. Select **Microsoft Graph**.
4. Choose **Delegated permissions** and add the following permissions:
   - `openid`
   - `profile`
   - `email`
   - `User.Read`

5. Click **Add permissions**.
6. Click **Grant admin consent for [Your Directory]** to grant the permissions.

### Configure Token Configuration (Optional)

1. Navigate to **Token configuration** in your app registration.
2. Click **Add optional claim**.
3. Select **ID** token type.
4. Add the following claims:
   - `email`
   - `family_name`
   - `given_name`
   - `upn`

5. Click **Add**.

### Collect Configuration Details

1. Navigate to the **Overview** section of your app registration.
2. Note down the following values:
   - **Application (client) ID**
   - **Directory (tenant) ID**

3. Navigate to **Endpoints** and note down:
   - **OpenID Connect metadata document**: `https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid-configuration`
   - **OAuth 2.0 authorization endpoint (v2)**: `https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize`
   - **OAuth 2.0 token endpoint (v2)**: `https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token`

## Step 2 - Configure WSO2 API Manager

### Configure the Identity Provider

1. Sign in to the WSO2 API Manager Management Console.

   `https://<Server Host>:9443/carbon`

2. Navigate to **Main > Identity > Identity Providers > Add**.

3. Provide a suitable name for the identity provider (e.g., `AzureAD-OIDC`).

4. Expand the **Claim Configuration** section and configure the following:

   <table>
     <thead>
       <tr>
         <th><b>Field</b></th>
         <th><b>Value</b></th>
       </tr>
     </thead>
     <tbody>
       <tr>
         <td>Choose Identity Provider Certificate</td>
         <td>Select the certificate for token validation</td>
       </tr>
       <tr>
         <td>Identity Provider Certificate Alias</td>
         <td>The certificate alias</td>
       </tr>
       <tr>
         <td>Choose Claim mapping Dialect</td>
         <td>Define Custom Claim Dialect</td>
       </tr>
     </tbody>
   </table>

   Add the following claim mappings:

   <table>
     <thead>
       <tr>
         <th><b>Identity Provider Claim URI</b></th>
         <th><b>Local Claim URI</b></th>
       </tr>
     </thead>
     <tbody>
       <tr>
         <td>email</td>
         <td>http://wso2.org/claims/emailaddress</td>
       </tr>
       <tr>
         <td>given_name</td>
         <td>http://wso2.org/claims/givenname</td>
       </tr>
       <tr>
         <td>family_name</td>
         <td>http://wso2.org/claims/lastname</td>
       </tr>
       <tr>
         <td>sub</td>
         <td>http://wso2.org/claims/username</td>
       </tr>
     </tbody>
   </table>

   Set **User ID Claim URI** to `sub` and **Role Claim URI** to a suitable claim (if using role-based access).

5. Expand the **Role configuration** section and add roles as needed.

6. Expand the **Federated Authenticators** section and then expand the **OAuth2/OpenID Connect Configuration** section.

7. Configure the following settings:

   <table>
     <thead>
       <tr>
         <th><b>Field</b></th>
         <th><b>Value</b></th>
       </tr>
     </thead>
     <tbody>
       <tr>
         <td>Enable OAuth2/OpenIDConnect</td>
         <td>Selected</td>
       </tr>
       <tr>
         <td>Default</td>
         <td>Selected</td>
       </tr>
       <tr>
         <td>Client ID</td>
         <td>The Application (client) ID from Azure AD</td>
       </tr>
       <tr>
         <td>Client Secret</td>
         <td>The client secret from Azure AD</td>
       </tr>
       <tr>
         <td>Authorization Endpoint URL</td>
         <td>https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/authorize</td>
       </tr>
       <tr>
         <td>Token Endpoint URL</td>
         <td>https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token</td>
       </tr>
       <tr>
         <td>Callback URL</td>
         <td>https://localhost:9443/commonauth</td>
       </tr>
       <tr>
         <td>Userinfo Endpoint URL</td>
         <td>https://graph.microsoft.com/oidc/userinfo</td>
       </tr>
       <tr>
         <td>OpenID Connect User ID Location</td>
         <td>User ID found among claims</td>
       </tr>
       <tr>
         <td>Additional Query Parameters</td>
         <td>scope=openid profile email</td>
       </tr>
     </tbody>
   </table>

8. Click **Register** to save the Identity Provider configuration.

### Configure Service Providers

#### For Publisher

1. Navigate to **Main > Identity > Service Providers > Add**.

2. Provide the service provider name as `apim_publisher` and click **Register**.

3. Expand the **Claim Configuration** section and configure the following:

   - **Use Local Claim Dialect**: Selected
   - **Subject Claim URI**: `http://wso2.org/claims/username`
   - **Requested Claims**: Add the necessary claims like username, email, given name, and family name.

4. Expand the **Local and Outbound Authentication Configuration** section.

5. For **Authentication Type**, select **Federated Authentication**.

6. Select the Azure AD Identity Provider you created from the dropdown.

7. Click **Update** to save the configuration.

#### For Developer Portal

1. Navigate to **Main > Identity > Service Providers > Add**.

2. Provide the service provider name as `apim_devportal` and click **Register**.

3. Follow the same claim configuration steps as the Publisher.

4. Configure the same federated authentication settings with the Azure AD Identity Provider.

5. Click **Update** to save the configuration.

## Step 3 - Test the Configuration

1. Access the API Manager Publisher Portal:

   `https://<Server Host>:9443/publisher`

2. You should see an option to **Sign in with AzureAD-OIDC** (or the name you gave to your IDP).

3. Click the Azure AD sign-in option and verify that you are redirected to the Azure AD login page.

4. Sign in with your Azure AD credentials and verify successful authentication.

5. Repeat the same test for the Developer Portal:

   `https://<Server Host>:9443/devportal`

## Troubleshooting

### Common Issues and Solutions

1. **Invalid redirect URI error**:
   - Ensure the redirect URI in Azure AD matches exactly with the one configured in WSO2 API Manager.
   - Check for trailing slashes or HTTP vs HTTPS mismatches.

2. **Token validation failures**:
   - Verify that the client secret is correctly configured.
   - Ensure the Azure AD application has the necessary permissions granted.

3. **Claim mapping issues**:
   - Check that the required claims are available in the Azure AD token.
   - Verify the claim mapping configuration in the Identity Provider.

4. **SSL certificate issues**:
   - For production deployments, ensure proper SSL certificates are configured.
   - For development, you may need to add certificates to the truststore.

### Logs and Debugging

Enable debug logs for authentication by adding the following to the `<API-M_HOME>/repository/conf/log4j2.properties` file:

```properties
logger.org-wso2-carbon-identity.name=org.wso2.carbon.identity
logger.org-wso2-carbon-identity.level=DEBUG
logger.org-wso2-carbon-identity.appenderRef.CARBON_CONSOLE.ref=CARBON_CONSOLE
```

Monitor the logs in `<API-M_HOME>/repository/logs/wso2carbon.log` for authentication-related messages.

!!! note
    This configuration enables Azure AD federated authentication for both the API Manager Publisher and Developer Portal. Users will be able to sign in using their Azure AD credentials, providing a seamless single sign-on experience across your organization's identity infrastructure.