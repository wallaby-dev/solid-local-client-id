# solid-local-client-id

A publicly hosted [Solid-OIDC Client Identifier Document](https://docs.inrupt.com/guides/identity-in-solid/the-client-id-document), intended for use by apps running on `localhost` during local development.

## Why this exists

[Solid-OIDC](https://solidproject.org/TR/oidc) lets an application authenticate without pre-registering with every Identity Provider it talks to, by using a **Client Identifier Document**: a small JSON-LD file, hosted at a stable URL, that describes the client (its name, allowed redirect URIs, requested scopes, and so on). That URL is used directly as the app's `client_id` — the Identity Provider dereferences it to fetch the document and validate the login request against it.

This only works if the document is reachable over the public internet. During local development an app typically runs on `http://localhost:<port>`, which an Identity Provider can't fetch — so the document itself has to be hosted somewhere else, even though the `redirect_uris` inside it point back to `localhost`.

This repository is that "somewhere else": a small static site, published via GitHub Pages, that serves one or more Client Identifier Documents for local development use. It has no server-side logic — it's just a place to host the JSON-LD file(s) at a fixed, dereferenceable URL.

## Usage

Point your app's Solid-OIDC client configuration at the raw URL of the relevant document in this repo (e.g. `https://<user>.github.io/solid-local-client-id/<file>.jsonld`), and set that same URL as the `client_id` value.

Each document's `redirect_uris` should list only the local development callback URL(s) it's meant for. A real deployment should use its own Client Identifier Document listing its actual deployed origin — don't add production URLs to a document that also allows `localhost`, since `localhost` shouldn't remain a valid redirect target once a real deployment exists.

## Further reading

- [Solid-OIDC specification](https://solidproject.org/TR/oidc) — the official spec, including the Client Identifier section
- [Inrupt: The Client Identifier Document](https://docs.inrupt.com/guides/identity-in-solid/the-client-id-document) — practical guide to the document's format and how it's used during authentication
