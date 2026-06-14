# Jobs And Workers

## Current State

Active Job is loaded and Solid Queue is configured, but no domain jobs exist.

Existing files:

- `app/jobs/application_job.rb`
- `config/queue.yml`
- `config/recurring.yml`
- `db/queue_schema.rb`

Configured recurring task:

- Production clears finished Solid Queue jobs hourly through `SolidQueue::Job.clear_finished_in_batches`.

## Missing Domain Jobs

No jobs exist for:

- Notifications.
- Report generation.
- Forecast generation.
- Payment webhook processing.
- Order fulfillment.
- Stock reservation expiration.
- Auction closing.
- RFQ deadline handling.

## Marketplace Direction

Keep jobs inside this Rails app and use Solid Queue first. Add domain jobs only when workflows become asynchronous or retryable, such as payment webhook handling, notification fan-out, stock reservation expiration, and report exports.

