# encoding: utf-8

class Multigiri
  class EmailObfuscator
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, document = @app.call(env)
      # document.css("a[href~='@']").each do |element|
      document.css("a[href]").each do |element|
        element["href"] = element["href"].sub("@", "&#x40;")
      end
      [status, headers, document]
    end
  end
end
