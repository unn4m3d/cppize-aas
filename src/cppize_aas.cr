require "./cppize_aas/*"
require "cppize"
require "http/server"
require "option_parser"


begin
  port = 1337

  OptionParser.parse! do |o|
    o.on("-pPORT","--port PORT","Set port"){|p| port = p.to_i}
  end

  server = HTTP::Server.new(port) do |ctx|
    ctx.response.content_type = "application/json"
    begin
      transpiler = Cppize::Transpiler.new
      warnings = [] of Cppize::Transpiler::Error
      errors = [] of Cppize::Transpiler::Error
      transpiler.on_warning{|e| warnings << e}
      transpiler.on_error{|e| errors << e}

      code = transpiler.parse_and_transpile(ctx.request.body.to_s,"<main>")

      ctx.response.puts({
        "code" => code,
        "errors" => errors.map(&.to_s),
        "warnings" => warnings.map(&.to_s)
      }.to_json)

    rescue ex
      ctx.response.puts({"error" => true, "backtrace" => ex.backtrace, "message" => ex.message }.to_json)
    end
  end

  server.listen

ensure
  server.close unless server.nil?
end
