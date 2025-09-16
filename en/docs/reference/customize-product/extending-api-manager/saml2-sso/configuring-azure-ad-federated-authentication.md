# Configuring Azure AD Federated Authentication for Publisher and Developer Portal

This guide explains how to configure Azure Active Directory (Azure AD) federated authentication for WSO2 API Manager's Publisher and Developer Portal using SAML2 SSO.

## Prerequisites

- WSO2 API Manager 4.4.0 or later
- Azure Active Directory tenant with admin privileges
- Basic understanding of SAML2 SSO concepts

## Overview

Azure AD federated authentication allows users to log into WSO2 API Manager using their Azure AD credentials through SAML2 SSO. This integration provides:

- **Single Sign-On**: Users can access API Manager using their existing Azure AD credentials
- **Centralized User Management**: User lifecycle management through Azure AD
- **Enhanced Security**: Leverage Azure AD security features like MFA, conditional access
- **Seamless Integration**: Works with both Publisher and Developer Portal

## Step 1: Configure Azure AD Application

### 1.1 Create Enterprise Application

1. Sign in to the [Azure portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **Enterprise applications**
3. Click **New application** > **Create your own application**
4. Enter a name (e.g., "WSO2 API Manager") and select **Integrate any other application you don't find in the gallery**
5. Click **Create**

### 1.2 Configure Single Sign-On

1. In your application, go to **Single sign-on**
2. Select **SAML** as the SSO method
3. Configure the following basic SAML settings:

   **Identifier (Entity ID)**:
   ```
   https://your-apim-domain:9443/publisher
   https://your-apim-domain:9443/devportal
   ```

   **Reply URL (Assertion Consumer Service URL)**:
   ```
   https://your-apim-domain:9443/publisher/jagg/jaggery_acs.jag
   https://your-apim-domain:9443/devportal/jagg/jaggery_acs.jag
   ```

   **Sign on URL**:
   ```
   https://your-apim-domain:9443/publisher
   https://your-apim-domain:9443/devportal
   ```

### 1.3 Configure User Attributes & Claims

Configure the following attribute mappings:

| Claim name | Source attribute |
|------------|------------------|
| `http://wso2.org/claims/username` | user.userprincipalname |
| `http://wso2.org/claims/emailaddress` | user.mail |
| `http://wso2.org/claims/fullname` | user.displayname |
| `http://wso2.org/claims/firstname` | user.givenname |
| `http://wso2.org/claims/lastname` | user.surname |
| `http://wso2.org/claims/role` | user.assignedroles |

### 1.4 Download Certificate

1. In the **SAML Signing Certificate** section
2. Download the **Certificate (Base64)** file
3. Note the **Login URL** from the **Set up** section

## Step 2: Configure WSO2 API Manager

### 2.1 Configure Identity Provider

1. Access the Management Console: `https://your-apim-domain:9443/carbon`
2. Navigate to **Main** > **Identity** > **Identity Providers** > **Add**
3. Configure the following:

   **Basic Information**:
   - Identity Provider Name: `AzureAD`
   - Display Name: `Azure Active Directory`
   - Description: `Azure AD SAML SSO Integration`

   **Federated Authenticators** > **SAML2 Web SSO Configuration**:
   - Enable SAML2 Web SSO: ✓
   - Identity Provider Entity Id: `https://sts.windows.net/{tenant-id}/` (replace with your tenant ID)
   - Service Provider Entity Id: `https://your-apim-domain:9443/publisher` (for Publisher) or `https://your-apim-domain:9443/devportal` (for Developer Portal)
   - SSO URL: Use the **Login URL** from Azure AD
   - Identity Provider Certificate: Upload the downloaded certificate

   **Claim Configuration**:
   - Identity Provider Claim URIs:
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier` → `http://wso2.org/claims/username`
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress` → `http://wso2.org/claims/emailaddress`
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name` → `http://wso2.org/claims/fullname`
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname` → `http://wso2.org/claims/firstname`
     - `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname` → `http://wso2.org/claims/lastname`

4. Click **Register** to save the Identity Provider

### 2.2 Configure Service Providers

#### For Publisher:

1. Navigate to **Main** > **Identity** > **Service Providers** > **Add**
2. Configure:
   - Service Provider Name: `API_MANAGER_PUBLISHER`
   - **Inbound Authentication Configuration** > **SAML2 Web SSO Configuration**:
     - Issuer: `https://your-apim-domain:9443/publisher`
     - Assertion Consumer URLs: `https://your-apim-domain:9443/publisher/jagg/jaggery_acs.jag`
     - Default Assertion Consumer URL: `https://your-apim-domain:9443/publisher/jagg/jaggery_acs.jag`
     - Enable Response Signing: ✓
     - Enable Assertion Signing: ✓
   - **Local & Outbound Authentication Configuration**:
     - Authentication Type: `Federated Authentication`
     - Federated Identity Providers: Select `AzureAD`

#### For Developer Portal:

1. Navigate to **Main** > **Identity** > **Service Providers** > **Add**
2. Configure:
   - Service Provider Name: `API_MANAGER_DEVPORTAL`
   - **Inbound Authentication Configuration** > **SAML2 Web SSO Configuration**:
     - Issuer: `https://your-apim-domain:9443/devportal`
     - Assertion Consumer URLs: `https://your-apim-domain:9443/devportal/jagg/jaggery_acs.jag`
     - Default Assertion Consumer URL: `https://your-apim-domain:9443/devportal/jagg/jaggery_acs.jag`
     - Enable Response Signing: ✓
     - Enable Assertion Signing: ✓
   - **Local & Outbound Authentication Configuration**:
     - Authentication Type: `Federated Authentication`
     - Federated Identity Providers: Select `AzureAD`

### 2.3 Update API Manager Configuration

Edit the `deployment.toml` file in `<API-M_HOME>/repository/conf/`:

```toml
[authentication.authenticator.saml_sso_authenticator]
name = "SAMLSSOAuthenticator"
enable = true

[authentication.authenticator.saml_sso_authenticator.parameters]
LoginPage = "/carbon/admin/login.jsp"
ServiceProviderID = "API_MANAGER_PUBLISHER"
IdentityProviderSSOServiceURL = "https://your-apim-domain:9443/samlsso"
NameIDPolicyFormat = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"
IsAuthnReqSigned = false
IsLogoutEnabled = true
LogoutURL = "logout"
IsAssertionSigned = true
IsAssertionEncrypted = false
IsResponseSigned = false
IsEnableAssertionSignatureValidation = true
IsEnableAssertionEncryption = false
IsEnableSingleLogout = true
IsSignAuthReqIfSLORequestSigned = false
SAML2SSOManager = "org.wso2.carbon.apimgt.impl.sso.SAML2SSOManager"
```

### 2.4 Restart API Manager

Restart the WSO2 API Manager server:

```bash
cd <API-M_HOME>/bin
./api-manager.sh restart
```

## Step 3: Assign Users in Azure AD

1. In Azure portal, navigate to your enterprise application
2. Go to **Users and groups**
3. Click **Add user/group**
4. Assign users or groups that should have access to API Manager
5. Configure appropriate roles if needed

## Step 4: Testing the Integration

### Test Publisher SSO:

1. Navigate to `https://your-apim-domain:9443/publisher`
2. You should be redirected to Azure AD login
3. Enter your Azure AD credentials
4. Upon successful authentication, you should be redirected back to the Publisher

### Test Developer Portal SSO:

1. Navigate to `https://your-apim-domain:9443/devportal`
2. You should be redirected to Azure AD login
3. Enter your Azure AD credentials
4. Upon successful authentication, you should be redirected back to the Developer Portal

## Troubleshooting

### Common Issues:

1. **Certificate Issues**: Ensure the Azure AD certificate is properly uploaded and valid
2. **URL Mismatches**: Verify all URLs match exactly between Azure AD and WSO2 configurations
3. **Claim Mapping**: Check that user attributes are correctly mapped between Azure AD and WSO2
4. **Network Connectivity**: Ensure WSO2 API Manager can reach Azure AD endpoints

### Debug Steps:

1. Check WSO2 logs in `<API-M_HOME>/repository/logs/`
2. Enable debug logs for SAML components:
   ```xml
   <logger name="org.wso2.carbon.identity.sso.saml" level="DEBUG"/>
   ```
3. Use browser developer tools to inspect SAML requests/responses
4. Verify Azure AD application logs in Azure portal

### Log Locations:

- API Manager logs: `<API-M_HOME>/repository/logs/wso2carbon.log`
- Audit logs: `<API-M_HOME>/repository/logs/audit.log`
- HTTP access logs: `<API-M_HOME>/repository/logs/http_access_*.log`

## Security Considerations

1. **Certificate Management**: Regularly rotate and update SAML certificates
2. **HTTPS Only**: Ensure all communications use HTTPS
3. **Token Validation**: Enable proper SAML assertion validation
4. **Session Management**: Configure appropriate session timeout values
5. **Access Control**: Use Azure AD conditional access policies for additional security

## Additional Resources

- [WSO2 API Manager SAML SSO Documentation](https://apim.docs.wso2.com/en/latest/develop/extending-api-manager/saml2-sso/configuring-identity-server-as-idp-for-sso/)
- [Azure AD SAML SSO Documentation](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-saml-single-sign-on)
- [SAML 2.0 Protocol Specification](http://docs.oasis-open.org/security/saml/v2.0/saml-core-2.0-os.pdf)

---

For technical support and questions, refer to the [WSO2 API Manager documentation](https://apim.docs.wso2.com/) or contact your system administrator.