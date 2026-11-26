# frozen_string_literal: true

require_relative "lib/bf16/version"

Gem::Specification.new do |spec|
  spec.name = "bf16"
  spec.version = Bf16::VERSION
  spec.authors = ["BF16 Team"]
  spec.email = ["hello@bf16.ai"]

  spec.summary = "Official zero-dependency Ruby SDK for bf16.ai (1M-context uncensored LLM API)."
  spec.description = "Zero-dependency Ruby client for bf16.ai OpenAI-compatible (/v1/chat/completions, /v1/responses) and Anthropic Messages (/v1/messages) APIs with strict Zero Data Retention."
  spec.homepage = "https://bf16.ai"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = "https://bf16.ai"
  spec.metadata["documentation_uri"] = "https://bf16.ai/docs"
  spec.metadata["source_code_uri"] = "https://github.com/BF16-AI/bf16-ruby"
  spec.metadata["changelog_uri"] = "https://bf16.ai/changelog"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]
end
