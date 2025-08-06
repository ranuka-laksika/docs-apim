# Configure Asgardeo as a Key Manager

It is possible to integrate the WSO2 API Manager with an external Identity and Access Management server (IAM) using the Asgardeo OAuth Authorization Server to manage the OAuth clients and tokens that are required by WSO2 API Manager. WSO2 API Manager has inbuilt support to consume APIs exposed by Asgardeo OAuth.

Follow the instructions below to configure Asgardeo as a third-party Key Manager:

\!\!\! info
    For more information, see the [Asgardeo Documentation](https://wso2.com/asgardeo/docs/), which is under the official WSO2 Asgardeo documentation.

## Step 1 - Configure Asgardeo

1. Create an Asgardeo account.
     
     Navigate to [https://console.asgardeo.io/](https://console.asgardeo.io/) and create a new account or sign in to your existing account.

2. Create an organization if you don't have one.

     Organizations in Asgardeo provide a way to manage your applications, users, and configurations in isolation.

3. Create an application to use the management API.

     Navigate to **Applications** and click **New Application**. Choose **Management Application** as the application type.

4. Configure the application settings.

     Make sure that you have granted the necessary permissions to manage applications, users, and other resources as required.

5. Navigate to the **API Resources** section and create a custom API resource.

     This will be used to define the scopes for your API.

6. Create scopes for your API resource.

     Add the necessary scopes such as read, write, or default based on your requirements.

## Step 2 - Configure WSO2 API Manager

1. Start WSO2 API Manager.

2. Sign in to the Admin Portal.

     https://<hostname>:9443/admin

     https://localhost:9443/admin

3. Add a new Key Manager.

    1. Select the Key manager type as Asgardeo and provide the relevant details in the fields accordingly.

        \!\!\! info
            The well-known URL for Asgardeo follows the pattern: https://api.asgardeo.io/t/{organization_name}/oauth2/.well-known/openid-configuration

            Example: https://api.asgardeo.io/t/myorg/oauth2/.well-known/openid-configuration

         - Select the token validation method as Self validate JWT.

     2. Set the grant types which are allowed in Asgardeo.

         Common grant types supported by Asgardeo include:
         - authorization_code
         - client_credentials
         - refresh_token
         - password (if enabled)

     3. Enter the client ID and client secret of the management application that was created in Asgardeo.

         You can get these values from the Protocol tab of your management application in the Asgardeo Console.

     4. Save the configurations.

## Step 3 - Generate keys using the Asgardeo Key Manager

1. Sign in to the Developer Portal.

     https://<hostname>:9443/devportal

     https://localhost:9443/devportal

2. Click Applications.

3. Create a new application.

4. Click either production or sandbox, select Asgardeo, and fill in the relevant information.
    
    \!\!\! note
        - Make sure to provide the organization name when generating the application keys.
        - You can obtain the organization name from your Asgardeo Console URL or settings.

     After the keys are generated, they will reflect in the UI.
    
5. Click Generate Keys.

\!\!\! tip
     If you want to generate the tokens with scopes, those scopes should have been defined in Asgardeo as mentioned in Step 1.
EOF < /dev/null