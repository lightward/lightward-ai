[Original URL: https://learn.mechanic.dev/techniques/working-with-external-apis/json-web-signatures]

# JSON Web Signatures

From Wikipedia:

> A JSON Web Signature (abbreviated JWS) is an IETF-proposed standard (RFC 7515) for signing arbitrary data.[1] This is used as the basis for a variety of web-based technologies including JSON Web Token.

Copy

    {% capture private_key_pem = options.private_key_pem__required_code_multiline %}
    
    {% assign claims = options.payload_json__code_multiline | parse_json | json | base64_url_safe_encode %}
    {% assign header = '{"alg":"RS256","typ":"JWT"}' | base64_encode %}
    {% assign input = header | append: "." | append: claims %}
    
    {% assign signature = input | rsa_sha256: private_key_pem | base64_url_safe_encode %}
    
    {% log header: header, claims: claims, input: input, signature: signature %}

Last updated 2023-11-08T15:16:45Z