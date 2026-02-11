# Configuring Azure Active Directory federated authentication

This guide describes how to configure Azure Active Directory (Azure AD) as a federated identity provider for WSO2 API Manager Publisher and Developer Portal single sign-on (SSO).

## Prerequisites

Before you begin, ensure that you have:

- An Azure AD tenant with administrative privileges
- WSO2 API Manager 4.0.0 installed and running
- WSO2 Identity Server configured as the identity provider for API Manager
- Access to the Azure portal (https://portal.azure.com)

## Step 1: Create an Azure AD enterprise application

1. Sign in to the Azure portal at https://portal.azure.com.
2. Navigate to **Azure Active Directory** > **Enterprise applications**.
3. Select **New application** > **Create your own application**.
4. Enter a name for your application (for example, "WSO2 API Manager").
5. Select **Integrate any other application you don't find in the gallery (Non-gallery)**.
6. Select **Create**.

## Step 2: Configure Azure AD SAML settings

1. In your newly created enterprise application, navigate to **Single sign-on**.
2. Select **SAML** as the single sign-on method.
3. In the **Basic SAML Configuration** section, select **Edit** and configure the following:
   - **Identifier (Entity ID)**: `wso2carbon-server`
   - **Reply URL (Assertion Consumer Service URL)**: `https://<API_MANAGER_HOST>:<API_MANAGER_PORT>/commonauth`
   
   Replace `<API_MANAGER_HOST>` and `<API_MANAGER_PORT>` with your actual API Manager host and port values.

4. In the **User Attributes & Claims** section, ensure the following claims are configured:
   - **Unique User Identifier (Name ID)**: `user.userprincipalname`
   - **Email**: `user.mail`
   - **First Name**: `user.givenname`
   - **Last Name**: `user.surname`
   - **Role**: Custom claim based on your Azure AD role assignments

## Step 3: Download Azure AD metadata

1. In the **SAML Signing Certificate** section, download the **Federation Metadata XML** file.
2. Save this file as you'll need it to configure the identity provider in WSO2 Identity Server.

## Step 4: Configure Azure AD as an identity provider in WSO2 Identity Server

1. Sign in to the WSO2 Identity Server Management Console.
2. Navigate to **Main** > **Identity Providers** > **Add**.
3. Enter the following details:
   - **Identity Provider Name**: `AzureAD`
   - **Display Name**: `Azure Active Directory`
   - **Description**: `Azure AD federated authentication for API Manager`

4. Under **Federated Authenticators**, expand **SAML2 Web SSO Configuration** and configure:
   - **Enable SAML2 Web SSO**: Select this checkbox
   - **Default**: Select this checkbox
   - **Select Mode**: **Metadata File Configuration**
   - Upload the **Federation Metadata XML** file downloaded from Azure AD
   - **Enable Logout**: Select this checkbox
   - **Enable Logout Request Signing**: Select this checkbox
   - **Enable Authentication Request Signing**: Select this checkbox

5. Under **Claim Configuration**, configure:
   - **Use Local Claim Dialect**: Unselect this checkbox
   - **Identity Provider Claim URI**: Map Azure AD claims to local claims:
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress` → `http://wso2.org/claims/emailaddress`
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname` → `http://wso2.org/claims/givenname`
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname` → `http://wso2.org/claims/lastname`
     - `http://schemas.microsoft.com/ws/2008/06/identity/claims/role` → `http://wso2.org/claims/role`

6. Under **Role Configuration**, configure role mappings based on your organization's Azure AD role structure.

7. Enable **Just-In-Time Provisioning** to automatically create user accounts.

8. Select **Register** to save the identity provider configuration.

## Step 5: Configure service provider authentication

1. In the WSO2 Identity Server Management Console, navigate to **Main** > **Service Providers** > **List**.
2. Locate and edit your API Manager service provider configurations for both Publisher and Developer Portal.
3. Under **Local & Outbound Authentication Configuration**:
   - **Authentication Type**: Select **Federated Authentication**
   - **Federated Identity Providers**: Select **AzureAD**

4. Under **Claim Configuration**:
   - **Subject Claim URI**: `http://wso2.org/claims/emailaddress`
   - Add required claim mappings for your application needs

5. Select **Update** to save the configuration.

## Step 6: Test the configuration

1. Navigate to the WSO2 API Manager Publisher portal.
2. You should be redirected to the Azure AD sign-in page.
3. Enter your Azure AD credentials.
4. After successful authentication, you should be redirected back to the Publisher portal.
5. Repeat the same process for the Developer Portal to verify functionality.

## Troubleshooting

If you encounter issues during configuration, consider the following:

- **Authentication failures**: Verify that the Entity ID and Reply URL in Azure AD match your WSO2 configuration
- **User provisioning issues**: Ensure Just-In-Time provisioning is enabled and claim mappings are correct
- **Role mapping problems**: Check that Azure AD roles are properly mapped to WSO2 roles
- **Certificate issues**: Verify that the SAML certificates are valid and properly configured

## Additional resources

For more information about configuring federated authentication, see:

- [Configuring Identity Server as IDP for SSO]({{base_path}}/develop/extending-api-manager/saml2-sso/configuring-identity-server-as-idp-for-sso)
- [Configuring Single Sign-on with SAML2]({{base_path}}/develop/extending-api-manager/saml2-sso/configuring-single-sign-on-with-saml2)
- [Azure AD SAML SSO documentation](https://docs.microsoft.com/azure/active-directory/manage-apps/configure-saml-single-sign-on)