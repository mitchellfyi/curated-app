# Curated

An app for aggregating links to interesting places on the web via RSS and APIs. Users can curate the content using votes and discussions can happen around the content. Like if Reddit was also an RSS reader.

## Multi-tenant
It is designed to power multiple websites based on their domain or subdomain using the Account model. This allows users to form groups around specific domains, e.g. pets.cx or football.curated.cx

## Sources
When creating an Account, keyphrases can be provided that will generate some initial recommended sources.
Keyphrases are used to filter the content from these generic sources so they're relevant to the account.
This means accounts don't start out completely empty.
If keyphrases are not provided, sources will not be created. However, keyphrases can be added later.

TODO: Adding initial sources should be optional.

## Tags
When creating an account, some initial recommended Tags are added (if there are none created with it) to allow for content to be categorised and filtered easily by users.
