# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "bf16/version"

module Bf16
  DEFAULT_BASE_URL = "https://api.bf16.ai/v1"
  ANTHROPIC_BASE_URL = "https://api.bf16.ai"

  MODEL_DEEPSEEK_V41_FLASH = "deepseek/deepseek-v4.1-flash-uncensored"
  MODEL_DEEPSEEK_V41_FLASH_FAST = "deepseek/deepseek-v4.1-flash-uncensored-fast"
  MODEL_GLM_53_FLASH = "zai-org/glm-5.3-flash-uncensored"
  MODEL_GLM_53 = "zai-org/glm-5.3-uncensored"
  MODEL_KIMI_K31_PRO = "moonshotai/kimi-k3.1-pro-uncensored"
  MODEL_AUTO = "bf16/auto"

  class Error < StandardError
    attr_reader :status_code

    def initialize(message, status_code = nil)
      super(message)
      @status_code = status_code
    end
  end

  class Client
    attr_reader :base_url, :timeout

    def initialize(api_key: ENV["BF16_API_KEY"], base_url: DEFAULT_BASE_URL, timeout: 120)
      @api_key = api_key
      @base_url = base_url.to_s.sub(%r{/+$}, "")
      @timeout = timeout
    end

    def models
      request_json("GET", "/models", auth: false)
    end

    def me
      request_json("GET", "/me", auth: true)
    end

    def chat(model:, messages:, **options)
      payload = options.merge(model: model, messages: messages)
      request_json("POST", "/chat/completions", payload: payload, auth: true)
    end

    def responses(model:, input:, **options)
      payload = options.merge(model: model, input: input)
      request_json("POST", "/responses", payload: payload, auth: true)
    end

    private

    def request_json(method, path, payload: nil, auth: true)
      if auth && (@api_key.nil? || @api_key.empty?)
        raise Error.new("Missing BF16_API_KEY", nil)
      end

      uri = URI.parse("#{@base_url}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.read_timeout = @timeout

      req = method == "GET" ? Net::HTTP::Get.new(uri.request_uri) : Net::HTTP::Post.new(uri.request_uri)
      req["Accept"] = "application/json"
      req["User-Agent"] = "bf16-ruby/#{VERSION}"
      req["Authorization"] = "Bearer #{@api_key}" if auth && @api_key && !@api_key.empty?

      if payload
        req["Content-Type"] = "application/json"
        req.body = JSON.generate(payload)
      end

      res = http.request(req)
      parsed = begin
        JSON.parse(res.body.to_s)
      rescue JSON::ParserError
        { "raw" => res.body.to_s }
      end

      code = res.code.to_i
      raise Error.new("bf16.ai HTTP #{code}: #{res.body}", code) if code >= 400

      parsed
    end
  end
end
