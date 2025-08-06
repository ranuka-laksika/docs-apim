# Configure Asgardeo as a Key Manager

WSO2 API Manager can integrate with Asgardeo, WSO2's Identity as a Service (IDaaS) solution, as an external Identity and Access Management server (IAM) to manage OAuth clients and tokens. Asgardeo provides comprehensive identity management capabilities and can serve as a third-party Key Manager for WSO2 API Manager.

Follow the instructions below to configure Asgardeo as a third-party Key Manager:

## Step 1 - Configure Asgardeo

### 1.1 Set up Asgardeo Organization

1. Navigate to the [Asgardeo Console](https://console.asgardeo.io/) and sign up for an Asgardeo account if you don't have one.

2. Create a new organization or select an existing organization.

3. Note down your organization URL, which will be in the format:
   
   Example: `https://api.asgardeo.io/t/myorg`

### 1.2 Create an Application for API Manager Integration

1. In the Asgardeo Console, navigate to **Applications** and click **New Application**.

2. Select **Single Page Application** and provide the following details:
   - **Name**: API Manager Integration
   - **Description**: Application for WSO2 API Manager integration

3. Configure the application settings:
   - **Grant Types**: Select **Authorization Code**, **Client Credentials**, and **Refresh Token**
   - **Public Client**: Disable this option to get client credentials
   - **PKCE**: Enable PKCE (Proof Key for Code Exchange)

4. Add redirect URLs if needed for your API Manager deployment:
   - `https://<api-manager-host>:9443/devportal`
   - `https://<api-manager-host>:9443/publisher`

5. Note down the **Client ID** and **Client Secret** from the **Protocol** tab.

### 1.3 Configure API Resources and Scopes

1. Navigate to **API Resources** and click **New API Resource**.

2. Create a new API resource:
   - **Identifier**: `api-manager-resource`
   - **Display Name**: API Manager Resource
   - **Description**: API resource for WSO2 API Manager

3. Add the required scopes:
   - **Scope**: `default`
   - **Display Name**: Default Scope
   - **Description**: Default scope for API access

4. Configure additional scopes as needed for your API management requirements.

### 1.4 Create Machine-to-Machine Application (Optional)

For better security and token introspection, create a separate machine-to-machine application:

1. Create a new **Machine to Machine Application** in Asgardeo.
2. Configure it with **Client Credentials** grant type.
3. Note down the Client ID and Client Secret for introspection API access.

### 1.5 Get Asgardeo Well-known Endpoint

The well-known endpoint for Asgardeo follows this format:
```
https://api.asgardeo.io/t/{org_name}/oauth2/token/.well-known/openid_configuration
```

Replace `{org_name}` with your organization name.

## Step 2 - Configure WSO2 API Manager

### 2.1 Access Admin Portal

1. Start WSO2 API Manager.

2. Sign in to the Admin Portal:
   ```
   https://<hostname>:9443/admin
   ```
   
   For local deployment:
   ```
   https://localhost:9443/admin
   ```

### 2.2 Add Asgardeo Key Manager

1. Click **Key Managers** and then click **Add Key Manager**.

   [\![Add new Key Manager]({{base_path}}/assets/img/administer/add-key-manager.png)]({{base_path}}/assets/img/administer/add-key-manager.png)

2. Configure the Key Manager with the following settings:

   | Configuration | Description | Value/Example | Required |
   |---------------|-------------|---------------|----------|
   | **Name** | The name of the key manager | `Asgardeo` | Mandatory |
   | **Display Name** | A name to display in the UI | `Asgardeo Identity Server` | Mandatory |
   | **Description** | Brief description of the Key Manager | `Asgardeo as third-party Key Manager` | Optional |
   | **Key Manager Type** | Select the type of Key Manager | `Default` | Mandatory |
   | **Well-known-url** | The well-known URL of Asgardeo | `https://api.asgardeo.io/t/{org_name}/oauth2/token/.well-known/openid_configuration` | Optional |
   | **Issuer** | The token issuer URL | `https://api.asgardeo.io/t/{org_name}/oauth2/token` | Optional |

   **Key Manager Endpoints:**
   
   | Endpoint | Description | Value/Example | Required |
   |----------|-------------|---------------|----------|
   | **Client Registration Endpoint** | Endpoint for dynamic client registration | `https://api.asgardeo.io/t/{org_name}/api/identity/oauth2/dcr/v1.1/register` | Optional |
   | **Introspection Endpoint** | Token introspection endpoint | `https://api.asgardeo.io/t/{org_name}/oauth2/introspect` | Optional |
   | **Token Endpoint** | Token issuance endpoint | `https://api.asgardeo.io/t/{org_name}/oauth2/token` | Optional |
   | **Revoke Endpoint** | Token revocation endpoint | `https://api.asgardeo.io/t/{org_name}/oauth2/revoke` | Optional |
   | **Userinfo Endpoint** | User information endpoint | `https://api.asgardeo.io/t/{org_name}/oauth2/userinfo` | Optional |
   | **Authorize Endpoint** | Authorization endpoint | `https://api.asgardeo.io/t/{org_name}/oauth2/authorize` | Optional |
   | **Scope Management Endpoint** | Scope management endpoint | `https://api.asgardeo.io/t/{org_name}/api/identity/oauth2/v1.0/scopes` | Optional |

   **Connector Configurations:**
   
   | Configuration | Description | Value | Required |
   |---------------|-------------|--------|----------|
   | **Username** | Username for token introspection | Client ID from Step 1.4 | Mandatory |
   | **Password** | Password for token introspection | Client Secret from Step 1.4 | Mandatory |
   | **Client ID** | Main application client ID | Client ID from Step 1.2 | Optional |
   | **Client Secret** | Main application client secret | Client Secret from Step 1.2 | Optional |

   **Advanced Configurations:**
   
   | Configuration | Description | Default Value | Required |
   |---------------|-------------|---------------|----------|
   | **Token Generation** | Enable token generation | `Enabled` | Mandatory |
   | **Out Of Band Provisioning** | Enable out of band provisioning | `Disabled` | Optional |
   | **OAuth App Creation** | Enable OAuth app creation | `Enabled` | Optional |
   | **Token Validation Method** | Method for token validation | `introspect` | Optional |

   \!\!\! note "Auto-filling Key Manager configurations"
       The Key Manager configurations can be auto-filled by clicking the **Import** button after providing the well-known endpoint of Asgardeo.

3. Click **Save** to add the Asgardeo Key Manager.

## Step 3 - Test the Configuration

### 3.1 Verify Key Manager

1. Navigate to **Key Managers** in the Admin Portal.
2. Verify that the Asgardeo Key Manager is listed and shows as **Active**.

### 3.2 Create Application and Test Token Generation

1. Sign in to the Developer Portal.
2. Create a new application and select **Asgardeo** as the Key Manager.
3. Generate keys for the application.
4. Test token generation using the client credentials.

### 3.3 API Subscription and Testing

1. Subscribe to an API using the application created with Asgardeo Key Manager.
2. Generate an access token.
3. Invoke the API using the generated token to verify the complete flow.

## Step 4 - Advanced Configuration

### 4.1 Custom Scopes

If you need to work with custom scopes:

1. Define custom scopes in Asgardeo under **API Resources**.
2. Map these scopes to your APIs in WSO2 API Manager.
3. Configure applications to request specific scopes.

### 4.2 User Claims Mapping

To map user claims from Asgardeo:

1. Configure user attributes in Asgardeo user profiles.
2. Map these attributes in the Key Manager configuration.
3. Use the claims in API policies or application logic.

### 4.3 Token Validation Customization

For custom token validation requirements:

1. Implement custom token validation logic if needed.
2. Configure the validation method in the Key Manager settings.
3. Test the validation with different token types.

## Troubleshooting

### Common Issues and Solutions

1. **Connection Timeout**: Verify network connectivity between API Manager and Asgardeo.

2. **Invalid Client Credentials**: Ensure the client ID and secret are correctly configured.

3. **Token Introspection Failures**: Verify the introspection endpoint and credentials.

4. **Scope Issues**: Check that the required scopes are properly configured in Asgardeo.

### Debug Logs

Enable debug logs for Key Manager operations:

1. Add the following to the log4j2.properties file:
   ```
   logger.key-mgt.name = org.wso2.carbon.apimgt.keymgt
   logger.key-mgt.level = DEBUG
   ```

2. Restart WSO2 API Manager and check the logs for detailed error messages.

## Next Steps

After successfully configuring Asgardeo as a Key Manager:

1. **Configure Multiple Key Managers**: You can configure multiple Key Managers to work with different environments.

2. **Application-Level Key Manager Selection**: Allow developers to choose between different Key Managers when creating applications.

3. **API-Level Key Manager Enforcement**: Configure specific APIs to work only with certain Key Managers.

4. **Monitoring and Analytics**: Monitor the usage and performance of your Asgardeo integration through WSO2 API Manager analytics.

For more information about Key Manager configurations, see [Key Manager Overview]({{base_path}}/administer/key-managers/overview/).
EOF < /dev/null