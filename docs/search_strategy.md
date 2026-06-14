# Search Strategy

## Options

### PostgreSQL Search

Pros:

- Simplest operational model after moving production persistence from SQLite to PostgreSQL.
- Good enough for product name, SKU, category, supplier, and description search.
- Supports indexes, ranking, trigram matching, and filtering without an external service.

Cons:

- Requires PostgreSQL migration.
- Less specialized than dedicated search engines.

### Meilisearch

Pros:

- Good developer experience.
- Strong typo tolerance and faceting.
- Easier than Elasticsearch.

Cons:

- Adds external infrastructure.
- Requires indexing jobs and operational monitoring.

### Elasticsearch

Pros:

- Most powerful at very large scale and complex search use cases.

Cons:

- Operationally heavy.
- Not justified for the current repository stage.

## Recommendation

Use database-backed search first, with a planned move from SQLite to PostgreSQL before marketplace scale. Add Meilisearch only after catalog search requirements exceed PostgreSQL capabilities.

Do not start with Elasticsearch.

