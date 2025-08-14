# Create an API from an OpenAPI Definition

An OpenAPI definition is a format that describes REST APIs. WSO2 API Manager supports both OpenAPI 3.0 and Swagger 2.0 specifications for creating APIs.

## Supported Specification Versions

WSO2 API Manager supports the following OpenAPI/Swagger specification versions:

| Specification | Version | Status | Recommended Use |
|---------------|---------|--------|-----------------|
| OpenAPI | 3.0.x | ✅ Recommended | New API development |
| Swagger | 2.0 | ✅ Supported | Legacy API migration |

!!! note "Version Compatibility"
    - **OpenAPI 3.0** is the current standard and is recommended for new API development
    - **Swagger 2.0** is supported for backward compatibility and legacy API migration
    - Both versions can be imported and managed within the same WSO2 API Manager instance

Follow the instructions below to create a REST API using an OpenAPI definition for an existing API.

## Create an API using the basic flow

1. Sign in to the Publisher Portal of WSO2 API Manager.

     `https://<hostname>:9443/publisher` (e.g., `https://localhost:9443/publisher`).

    <html><div class="admonition note">
      <p class="admonition-title">Note</p>
      <p>The <b>Create API</b> button will only appear if you have the "creator" role permission.</p>
      </div>
    </html>

2. Click **Create API** and then click **Import OpenAPI**.

    [![Create an API]({{base_path}}/assets/img/learn/import-open-api.png)]({{base_path}}/assets/img/learn/import-open-api.png)

3. Select one of the following options:

	* **OpenAPI URL** - If you select this option, you need to provide an endpoint URL.
	* **OpenAPI Archive/File** - If you select this option, drag and drop or click **Browse File to Upload** to upload either an individual OpenAPI definition or an archive that has an OpenAPI definition with external <a href="https://Swagger.io/docs/specification/using-ref/" target="_blank">file references</a>.

    <html><div class="admonition note">
    <p class="admonition-title">Note</p>
    <p>
    <ul><li>You need to upload an archive if you have remote references in your API definition. - <a href="{{base_path}}/assets/attachments/design/sample-archive.zip">Sample OpenAPI archive</a></li><li>If it is a single OpenAPI file without remote references, it can be imported directly, without zipping.</li><li> 
    When uploading an OpenAPI archive, the master OpenAPI file should be named as <b>openapi.yaml</b>/<b>openapi.json</b> for OpenAPI 3.0 or <b>swagger.yaml</b>/<b>swagger.json</b> for Swagger 2.0. 
    </br>If not, the validation will fail at the point of API creation.</li> <li>Referenced files can be named independently.</li>
    <li>When archiving the OpenAPI files, make sure that it does not have any hidden folders (e.g., <code>__MACOSX</code>).</li></ul>
    </p>
    </div>
    </html>
    
    !!! tip "Archive Structure Requirements"
        The OpenAPI definitions should be placed under one root folder and zipped.    
   
        **Sample folder structures**
    
        === "OpenAPI 3.0 Structure"
            ```
                -masterFolder
                  ---openapi.json (or openapi.yaml)
                  ---reference.json
                  ---components/
                     ---schemas.json
            ```
        
        === "Swagger 2.0 Structure"
            ```
                -masterFolder
                  ---swagger.json (or swagger.yaml)
                  ---reference.json
                  ---definitions/
                     ---models.json
            ```

        In the above samples, every definition file is placed inside one root folder namely `masterFolder`.

4. Choose your preferred specification version and provide the corresponding URL. Click **Next**.

    === "OpenAPI 3.0 (Recommended)"
        Select **OpenAPI URL** and provide `https://petstore3.swagger.io/api/v3/openapi.json` as the URL.
        
        !!! tip "OpenAPI 3.0 Benefits"
            OpenAPI 3.0 provides enhanced features including:
            
            - Better schema validation and documentation
            - Improved security definitions with multiple security schemes
            - Enhanced parameter definitions and examples
            - Better tooling support and ecosystem
    
    === "Swagger 2.0 (Legacy Support)"
        Select **OpenAPI URL** and provide `http://petstore.swagger.io/v2/swagger.json` as the URL.
        
        !!! note "When to Use Swagger 2.0"
            Use Swagger 2.0 when:
            
            - Migrating existing APIs from legacy systems
            - Working with third-party services that only provide Swagger 2.0
            - Maintaining backward compatibility with existing tooling

     [![Create a REST API using swagger definition]({{base_path}}/assets/img/learn/create-rest-api-using-swagger-def-form1.png){: style="width:70%"}]({{base_path}}/assets/img/learn/create-rest-api-using-swagger-def-form1.png)

    !!! tip
        You can see the Linter results associated with the API here.

5.  Edit the information as given below and click **Create**.
    
    !!! note
        Make sure to provide the correct endpoint at this step.

    === "OpenAPI 3.0 Configuration"
        | Field    | Sample value                        |
        |----------|-------------------------------------|
        | Name     | SwaggerPetstore                     |
        | Context  | /petstore                           |
        | Version  | 1.0.6                               |
        | Endpoint | https://petstore3.swagger.io/api/v3 |

    === "Swagger 2.0 Configuration"
        | Field    | Sample value                   |
        |----------|--------------------------------|
        | Name     | SwaggerPetstore                |
        | Context  | /petstore                      |
        | Version  | 1.0.5                          |
        | Endpoint | https://petstore.swagger.io/v2 |

     [![Create a REST API using swagger definition]({{base_path}}/assets/img/learn/create-rest-api-using-swagger-def-form2.png){: style="width:70%"}]({{base_path}}/assets/img/learn/create-rest-api-using-swagger-def-form2.png)

     The Petstore API overview page appears.

     [![Overview of created API]({{base_path}}/assets/img/learn/overviewpage-rest-api-creating-by-swagger-def.png)]({{base_path}}/assets/img/learn/overviewpage-rest-api-creating-by-swagger-def.png)

### Resources
   
Click **API Configurations** and then click **Resources** to navigate to the Resources page. 

You will notice that all the API resources are created automatically when the OpenAPI URL is specified.
   
[![]({{base_path}}/assets/img/learn/resource-of-pet-store-api.png)]({{base_path}}/assets/img/learn/resource-of-pet-store-api.png)

### API Definition

1. Click **API Configurations**, **API Definition**, and then click **Edit** to remove the security headers. 

     This is required to invoke the API in the Developer Portal using the OpenAPI UI.
    
     [![]({{base_path}}/assets/img/learn/edit-api-definition-pet-store.png)]({{base_path}}/assets/img/learn/edit-api-definition-pet-store.png)

    ??? note "Importing an API definition"
         You can also import an API definition.
         
            1. Click on **Import Definition** from the toolbar

            2. Select one of the following options:
                - OpenAPI URL
                - OpenAPI Archive/File

            3. To try this out, select OpenAPI URL and enter `https://petstore3.swagger.io/api/v3/openapi.json` as the URL for OpenAPI 3.0, or `http://petstore.swagger.io/v2/swagger.json` for Swagger 2.0.
        [![Import API Definition]({{base_path}}/assets/img/learn/import-api-definition.png)]({{base_path}}/assets/img/learn/import-api-definition.png)        
            
        **The Linter results can be viewed here.**

            4. If there are any errors present, they can be solved in the built-in editor by clicking on the **Edit and Import** button.

            5. Then click on the **Import Content** on the editor to import the API definition.

2. Remove the `petstore_auth` tag related configuration that appears under the `security` tag from the `/pet` POST resource given below. 

    !!! note
        Do not remove the `default` tag related configuration that appears under the `security` tag.

     **OpenAPI - Post resource**

    ``` java
    security:
        - petstore_auth:
            - 'write:pets'
            - 'read:pets'
        - default:
            - 'write:pets'
            - 'read:pets'
    ```

3.  Remove the security `pet/{petId}` GET resource given below:

     **OpenAPI - Get resource**

    ``` java
    //remove the following code snippet
    security:
            - api_key: []
    ```

4.  After removing the security tags, click **Update Content**.
     
     [![Update OpenAPI definition]({{base_path}}/assets/img/learn/update-content-pet-store.png)]({{base_path}}/assets/img/learn/update-content-pet-store.png)

5. Click **Save** to save the changes.
   
    !!! note
        If you have already deployed your API, click on the dropdown option, and click **Save and deploy** so that your API will be redeployed, and your changes will appear in the API Gateway.

### Endpoints

1. Click **API Configurations** and click **Endpoints** to navigate to the Endpoints page.

2. Enter the information shown below.

     | Field               | Sample value                                          |
     |---------------------|-------------------------------------------------------|
     | Endpoint type       | HTTP/REST Endpoint                                    |
     | Production endpoint | [https://petstore3.swagger.io/api/v3](https://petstore3.swagger.io/api/v3)                       |
     | Sandbox endpoint    | Let's only work with the production endpoint for this sample. Therefore, deselect the sandbox endpoint option. |

     <html>
     <img src="{{base_path}}/assets/img/learn/endpoint-menu.png" width="200">
     </html>

3. Click **Save** to save the changes.
   
    !!! note
        If you have already deployed your API, click on the dropdown option, and click **Save and deploy** so that your API will be redeployed, and your changes will appear in the API Gateway.

     [![]({{base_path}}/assets/img/learn/add-endpoint-configuration-for-pet-store-api.png)]({{base_path}}/assets/img/learn/add-endpoint-configuration-for-pet-store-api.png)

### Runtime Configuration

Click **API Configurations** and click **Runtime** to navigate to the Runtime Configurations page.
     
The Transport Level Security defines the transport protocol on which the API is exposed.

<a href="{{base_path}}/assets/img/learn/runtime-config-menu.png"><img src="{{base_path}}/assets/img/learn/runtime-config-menu.png" width="20%"></a>

<a href="{{base_path}}/assets/img/learn/transport-level-security-pet-store.png"><img src="{{base_path}}/assets/img/learn/transport-level-security-pet-store.png" width="90%">
</a>

<html><div class="admonition note">
    <p class="admonition-title">Note</p>
    <p> Both HTTP and HTTPS transports are selected by default. It is able to limit the API availability to only one transport (e.g., HTTPS) by clearing the checkbox of the other transport.</p>
    </div>
    </html>

<html><div class="admonition note">
    <p class="admonition-title">Note</p>
    <p> Transport Level Security defines the transport protocol on which the API is exposed. When creating a new API by using an OpenAPI or Swagger definition, these transport security schemes can be defined using <b>"x-wso2-transports"</b> and <b>"x-wso2-mutual-ssl"</b> extensions.</p>
        ```yaml
        x-wso2-mutual-ssl: "optional"
        x-wso2-transports: 
            - "https"
            - "http"
        ```
</div></html>

## Subscriptions

1. Click **Portal Configurations** and click **Subscriptions** to navigate to the Business Plans page.

     <a href="{{base_path}}/assets/img/learn/subscriptions-menu.png">
     <img src="{{base_path}}/assets/img/learn/subscriptions-menu.png" alt="subscriptions menu" width="20%">
     </a>

2. Select **Gold** and **Silver** as the Business Plans.

     <html><div class="admonition note">
     <p class="admonition-title">Note</p>
     <p> The API can be available at different levels of the service. The Business Plans allow you to limit the number of successful hits to an API during a given period of time.</p>
     </div>
     </html>

3. Click **Save**

    [![Business Plans page]({{base_path}}/assets/img/learn/add-bussiness-plans-for-pet-store-api.png)]({{base_path}}/assets/img/learn/add-bussiness-plans-for-pet-store-api.png)


Now, a REST API from an OpenAPI Definition has been created and configured successfully. 

Next, [deploy the API]({{base_path}}/deploy-and-publish/deploy-on-gateway/deploy-api/deploy-an-api/), [test the API]({{base_path}}/design/create-api/create-rest-api/test-a-rest-api/), and finally [publish the API]({{base_path}}/deploy-and-publish/publish-on-dev-portal/publish-an-api).

## Migration Guide

### Upgrading from Swagger 2.0 to OpenAPI 3.0

If you have existing APIs using Swagger 2.0 and want to migrate to OpenAPI 3.0:

1. **Export your existing API definition**
   - Navigate to **API Configurations** → **API Definition** 
   - Click **Export** to download your current Swagger 2.0 definition

2. **Convert to OpenAPI 3.0**
   - Use online conversion tools or libraries to convert Swagger 2.0 to OpenAPI 3.0
   - Review and update the converted definition for any compatibility issues

3. **Import the updated definition**
   - Use **Import Definition** to upload your OpenAPI 3.0 definition
   - Test the API functionality after migration

4. **Update endpoints if necessary**
   - Review endpoint configurations for any changes required by OpenAPI 3.0

## See Also

Learn more on the concepts that you need to know when creating a REST API:

-   [Endpoints]({{base_path}}/design/endpoints/endpoint-types/)
-   [API Security]({{base_path}}/design/api-security/api-authentication/secure-apis-using-oauth2-tokens/)
-   [Rate Limiting]({{base_path}}/design/rate-limiting/introducing-throttling-use-cases/)
-   [Life Cycle Management]({{base_path}}/design/lifecycle-management/api-lifecycle/)
-   [API Monetization]({{base_path}}/design/api-monetization/monetizing-an-api/)
-   [API Visibility]({{base_path}}/design/advanced-topics/control-api-visibility-and-subscription-availability-in-developer-portal/)
-   [API Documentation]({{base_path}}/design/api-documentation/add-api-documentation/)
-   [Custom Properties]({{base_path}}/design/create-api/adding-custom-properties-to-apis/)
