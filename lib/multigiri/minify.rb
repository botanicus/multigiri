# encoding: utf-8

module Multigiri
  class Minify
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, document = @app.call(env)
      # TODO
      [status, headers, document]
    end
  end
end
