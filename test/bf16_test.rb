# frozen_string_literal: true

require "minitest/autorun"
require "socket"
require "bf16"

class Bf16ClientTest < Minitest::Test
  def test_missing_api_key_raises
    client = Bf16::Client.new(api_key: nil)
    err = assert_raises(Bf16::Error) { client.me }
    assert_match(/Missing BF16_API_KEY/, err.message)
  end

  def test_models_and_chat_roundtrip
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    thread = Thread.new do
      2.times do
        sock = server.accept
        req_line = sock.gets
        content_len = 0
        while (line = sock.gets)
          break if line == "\r\n" || line == "\n"
          if line.downcase.start_with?("content-length:")
            content_len = line.split(":", 2)[1].to_i
          end
        end
        body = content_len.positive? ? sock.read(content_len) : ""
        payload = if req_line.include?("/v1/models")
          JSON.generate({ "object" => "list", "data" => [{ "id" => Bf16::MODEL_DEEPSEEK_V41_FLASH }] })
        else
          req_json = JSON.parse(body)
          JSON.generate({
            "id" => "chatcmpl-test",
            "model" => req_json["model"],
            "choices" => [{ "message" => { "content" => "ok" } }]
          })
        end
        sock.write("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: #{payload.bytesize}\r\nConnection: close\r\n\r\n#{payload}")
        sock.close
      end
    end

    begin
      client = Bf16::Client.new(api_key: "sk-bf16-v1-test", base_url: "http://127.0.0.1:#{port}/v1")
      models = client.models
      assert_equal 1, models["data"].size
      chat = client.chat(
        model: Bf16::MODEL_GLM_53,
        messages: [{ role: "user", content: "ping" }]
      )
      assert_equal "ok", chat["choices"][0]["message"]["content"]
    ensure
      server.close
      thread.join
    end
  end
end
