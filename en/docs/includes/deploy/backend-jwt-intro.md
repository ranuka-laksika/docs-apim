
There can be scenarios where a backend service needs to make different decisions or respond with different data, depending on the application end-user that consumes an API. To achieve this the backend service needs to have access to the respective end-user's data at the time an API call takes place.

This can be facilitated by the Gateway by sending the end user attributes that are defined in the respective user store, in a JWT via an HTTP header, to the backend service when the API call is being forwarded.

## How does it work?

The backend JSON Web Token (JWT) contains the claims that are transferred between two parties, such as the end-user and the backend. A claim is an attribute of the user that is mapped to the underlying user store. A set of claims is referred to as a dialect (e.g., https://wso2.org/claims).

If you enable backend JWT generation in the Gateway, each API request will carry a digitally signed JWT, which is in the following format to the backend service.
 
`{token header}.{claims list}.{signature}`

When the request goes through the Gateway, the backend JWT is appended as a transport header to the outgoing message. The backend service fetches the JWT and retrieves the required information about the user, application, or token.

## Sample backend JWT

The following is an example of a backend JWT:

``` json
{
    "typ": "JWT",
    "alg": "RS256",
    "x5t": "ODE3Y2ZhMTBjMDM4ZTBmMjAyYzliYTI2YjRhYTZlOGIyZmUxNWE3YQ==",
    "kid": "Q049bG9jYWxob3N0LCBPVT1XU08yLCBPPVdTTzIsIEw9TW91bnRhaW4gVmlldywgU1Q9Q0EsIEM9VVMjMTY3NzA4OTI4Mw"
}
{
    "iss":"wso2.org/products/am",
    "exp":1345183492181,
    "https://wso2.org/claims/subscriber":"admin",
    "https://wso2.org/claims/applicationname":"app2",
    "https://wso2.org/claims/apicontext":"/placeFinder",
    "https://wso2.org/claims/version":"1.0.0",
    "https://wso2.org/claims/tier":"Silver",
    "https://wso2.org/claims/enduser":"sumedha"
}
```

The above JSON Web Token (JWT) contains the following information.

**JWT Header :** 

- `"typ"` - Declares that the encoded object is a JWT access token
- `"alg"` - This defines the specific algorithm intended for use with the key
- `"x5t"` - Thumbprint of the x.509 cert (SHA-1 thumbprint)
- `"kid"` - Key ID parameter is a unique identifier used to match a specific key

**JWT Claims set :**

-   `"iss"` - The issuer of the JWT
-   `"exp"` - The token expiration time
-   `"https://wso2.org/claims/subscriber"` - Subscriber to the API, usually the app developer
-   `" https://wso2.org/claims/applicationname"` - Application through which API invocation is done
-   `" https://wso2.org/claims/apicontext"` - Context of the API
-   `" https://wso2.org/claims/version "` - API version
-   `" https://wso2.org/claims/tier"` - Tier/price band for the subscription
-   `" https://wso2.org/claims/enduser"` - End-user of the app who's action invoked the API