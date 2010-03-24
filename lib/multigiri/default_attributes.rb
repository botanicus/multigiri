# encoding: utf-8

module Multigiri
  class DefaultAttributes
    def initialize(app, defaults = nil)
      @app, @defaults = app, defaults
      @defaults ||= {"form" => {"method" => "POST"}, "script" => {"type" => "text/javascript"}}
    end

    def call(env)
      status, headers, document = @app.call(env)
      @defaults.each do |tag, attributes|
        document.css(tag).each do |element|
          attributes.each do |attribute, value|
            element[attribute] ||= value
          end
        end
      end
      [status, headers, document]
    end
  end
end
