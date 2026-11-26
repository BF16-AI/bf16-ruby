# bf16 (Official Ruby SDK)

Zero-dependency Ruby client for [bf16.ai](https://bf16.ai) — uncensored 1M-context open-weight LLM inference API (`DeepSeek V4.1 Flash`, `GLM-5.3`, `Kimi K3.1 Pro`) with automatic prompt caching and strict Zero Data Retention (ZDR).

## Installation

```bash
gem install bf16
```

## Quickstart

```ruby
require "bf16"

client = Bf16::Client.new(api_key: ENV.fetch("BF16_API_KEY"))

response = client.chat(
  model: Bf16::MODEL_DEEPSEEK_V41_FLASH,
  messages: [{ role: "user", content: "Summarize this SQL migration safely." }]
)
puts response.dig("choices", 0, "message", "content")
```

## Documentation & Links

- Website & Console: [bf16.ai](https://bf16.ai)
- API Documentation: [bf16.ai/docs](https://bf16.ai/docs)
- Open-Source Grants (`$50` API credits): [bf16.ai/open-source](https://bf16.ai/open-source)
