# WSO2 API Security Guidelines

A comprehensive guide detailing security best practices for designing, implementing, and managing APIs, ensuring protection against common vulnerabilities and threats.

| Rule Name | Severity | Description |
|-----------|----------|-------------|
| [api-security-https-only](#api-security-https-only) | Error | API endpoints must use HTTPS protocol for secure communication. |
| [api-security-no-sensitive-data-in-url](#api-security-no-sensitive-data-in-url) | Error | Sensitive data must not be transmitted in URL parameters. |
| [api-security-authentication-required](#api-security-authentication-required) | Error | All API endpoints must implement proper authentication mechanisms. |
| [api-security-authorization-required](#api-security-authorization-required) | Error | API endpoints must implement proper authorization controls. |
| [api-security-input-validation](#api-security-input-validation) | Error | All API inputs must be validated and sanitized. |
| [api-security-rate-limiting](#api-security-rate-limiting) | Warning | API endpoints should implement rate limiting to prevent abuse. |
| [api-security-cors-configuration](#api-security-cors-configuration) | Warning | CORS configuration should be properly configured to prevent unauthorized access. |
| [api-security-error-handling](#api-security-error-handling) | Warning | Error responses should not expose sensitive system information. |
| [api-security-logging-monitoring](#api-security-logging-monitoring) | Warning | API access and security events should be logged for monitoring. |
| [api-security-data-encryption](#api-security-data-encryption) | Info | Sensitive data should be encrypted both in transit and at rest. |
| [api-security-token-expiration](#api-security-token-expiration) | Info | Authentication tokens should have appropriate expiration times. |
| [api-security-security-headers](#api-security-security-headers) | Info | Security headers should be implemented to enhance API security. |

## Detailed rules

### api-security-https-only

**Description:** API endpoints must use HTTPS protocol to ensure encrypted communication and prevent man-in-the-middle attacks.

**Severity:** Error

**Valid example**

```yaml
servers:
  - url: https://api.example.com/v1
    description: Production server (HTTPS)
```

**Invalid example**

```yaml
servers:
  - url: http://api.example.com/v1
    description: Production server (HTTP - insecure)
```

### api-security-no-sensitive-data-in-url

**Description:** Sensitive information such as passwords, tokens, or personal data must not be transmitted in URL parameters where they can be logged or cached.

**Severity:** Error

**Valid example**

```yaml
paths:
  /users/{id}:
    get:
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                token:
                  type: string
```

**Invalid example**

```yaml
paths:
  /users:
    get:
      parameters:
        - name: password
          in: query
          required: true
          schema:
            type: string
```

### api-security-authentication-required

**Description:** All API endpoints must implement proper authentication mechanisms to verify user identity.

**Severity:** Error

**Valid example**

```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
security:
  - BearerAuth: []
```

**Invalid example**

```yaml
paths:
  /sensitive-data:
    get:
      responses:
        '200':
          description: Sensitive data without authentication
```

### api-security-authorization-required

**Description:** API endpoints must implement proper authorization controls to ensure users can only access resources they are permitted to.

**Severity:** Error

**Valid example**

```yaml
paths:
  /admin/users:
    get:
      security:
        - BearerAuth: ['admin']
      responses:
        '200':
          description: User list for administrators only
```

**Invalid example**

```yaml
paths:
  /admin/users:
    get:
      responses:
        '200':
          description: User list without proper authorization
```

### api-security-input-validation

**Description:** All API inputs must be validated and sanitized to prevent injection attacks and ensure data integrity.

**Severity:** Error

**Valid example**

```yaml
components:
  schemas:
    UserInput:
      type: object
      properties:
        email:
          type: string
          format: email
          maxLength: 255
        age:
          type: integer
          minimum: 0
          maximum: 150
      required:
        - email
```

**Invalid example**

```yaml
components:
  schemas:
    UserInput:
      type: object
      properties:
        data:
          type: string
```

### api-security-rate-limiting

**Description:** API endpoints should implement rate limiting to prevent abuse, DDoS attacks, and ensure fair resource usage.

**Severity:** Warning

**Valid example**

```yaml
paths:
  /api/data:
    get:
      responses:
        '200':
          description: Successful response
        '429':
          description: Too many requests
          headers:
            Retry-After:
              schema:
                type: integer
              description: Number of seconds to wait before retrying
```

### api-security-cors-configuration

**Description:** Cross-Origin Resource Sharing (CORS) configuration should be properly configured to prevent unauthorized cross-origin requests.

**Severity:** Warning

**Valid example**

```yaml
# CORS should be configured at server level with specific origins
# Example configuration (not in OpenAPI spec):
# Access-Control-Allow-Origin: https://trusted-domain.com
# Access-Control-Allow-Methods: GET, POST
# Access-Control-Allow-Headers: Authorization, Content-Type
```

### api-security-error-handling

**Description:** Error responses should provide meaningful information to clients without exposing sensitive system details that could be used by attackers.

**Severity:** Warning

**Valid example**

```yaml
components:
  responses:
    ValidationError:
      description: Invalid input provided
      content:
        application/json:
          schema:
            type: object
            properties:
              error:
                type: string
                example: "Invalid email format"
              code:
                type: string
                example: "VALIDATION_ERROR"
```

**Invalid example**

```yaml
components:
  responses:
    ServerError:
      description: Internal server error
      content:
        application/json:
          schema:
            type: object
            properties:
              error:
                type: string
                example: "Database connection failed: mysql://user:pass@localhost:3306/db"
```

### api-security-logging-monitoring

**Description:** API access patterns, authentication failures, and security events should be logged for monitoring and incident response.

**Severity:** Warning

**Valid example**

```yaml
# Logging should be implemented at application level
# Key events to log:
# - Authentication attempts (success/failure)
# - Authorization failures
# - Rate limiting violations
# - Suspicious request patterns
# - Input validation failures
```

### api-security-data-encryption

**Description:** Sensitive data should be encrypted both in transit (HTTPS/TLS) and at rest to protect against unauthorized access.

**Severity:** Info

**Valid example**

```yaml
components:
  schemas:
    SensitiveData:
      type: object
      properties:
        encryptedField:
          type: string
          description: "This field contains encrypted sensitive data"
          example: "AES256:encrypted_value_here"
```

### api-security-token-expiration

**Description:** Authentication tokens should have appropriate expiration times to limit the impact of token compromise.

**Severity:** Info

**Valid example**

```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: "JWT tokens expire after 1 hour for security"
```

### api-security-security-headers

**Description:** Security headers should be implemented to enhance API security and prevent various attack vectors.

**Severity:** Info

**Valid example**

```yaml
# Security headers should be implemented at server level:
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-XSS-Protection: 1; mode=block
# Strict-Transport-Security: max-age=31536000; includeSubDomains
# Content-Security-Policy: default-src 'self'
```