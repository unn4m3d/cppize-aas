require "./cppize_aas/*"
require "cppize"
require "http/server"
require "option_parser"

AVAILABLE_TRANSPILER_FEATURES = ["unsafe-cast","auto-module-type"]

begin
  port = 1337

  OptionParser.parse! do |o|
    o.on("-pPORT","--port PORT","Set port"){|p| port = p.to_i; puts port}
  end

  server = HTTP::Server.new("0.0.0.0",port) do |ctx|
    ctx.response.content_type = "application/json"
    ctx.response.headers.add("Access-Control-Allow-Origin","*")
    begin
      transpiler = Cppize::Transpiler.new
      warnings = [] of Cppize::Transpiler::Error
      errors = [] of Cppize::Transpiler::Error
      tr_warnings = [] of String
      transpiler.on_warning{|e| warnings << e}
      transpiler.on_error{|e| errors << e}

      source = ctx.request.body.to_s

      source.scan(/#=:cppize-feature:=([^\n]+)\n/m) do |md|

        opt = md[1].strip
        puts "Opt #{opt} (#{md[0]})"
        if AVAILABLE_TRANSPILER_FEATURES.includes? opt
          if opt.nil?
            tr_warnings << "Trying to pass nil feature"
          else
            transpiler.options[opt] = ""
          end
        else
          tr_warnings << "Unsupported feature #{opt}"
        end
      end

      code = transpiler.parse_and_transpile(source,"<main>")

      ctx.response.puts({
        "code" => code,
        "errors" => errors.map(&.to_h),
        "warnings" => warnings.map(&.to_h) + tr_warnings.map{|x| {"message"=>x}}
      }.to_json)

    rescue ex
      ctx.response.puts({"error" => true, "backtrace" => ex.backtrace, "message" => ex.message }.to_json)
    end
  end

  puts "Starting"
  server.listen
  puts "..."

ensure
  puts "Crashed"
  server.close unless server.nil?
end
