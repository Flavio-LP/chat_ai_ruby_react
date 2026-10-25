Yabeda.configure do
  group :llm do
    counter :requests_total,
      comment: "Total LLM API requests",
      tags: %i[model status]

    counter :tokens_total,
      comment: "Total tokens used",
      tags: %i[model direction]

    gauge :cost_usd_total,
      comment: "Accumulated cost in USD",
      tags: %i[model]

    histogram :latency_seconds,
      comment: "LLM request latency",
      tags: %i[model],
      buckets: [0.1, 0.5, 1, 2, 5, 10, 30, 60]

    histogram :time_to_first_token_seconds,
      comment: "Time to first streaming token",
      tags: %i[model],
      buckets: [0.1, 0.25, 0.5, 1, 2, 5]
  end
end

Yabeda.configure!
