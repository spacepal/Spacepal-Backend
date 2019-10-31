require "ohm"

Ohm.redis = Redic.new(ENV.fetch("SPACEPAL_REDIS_URL") { "redis://localhost:6379/1" })