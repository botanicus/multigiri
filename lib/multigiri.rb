# encoding: utf-8

# use Multigiri do
#   use GoogleAnalytics, :my_tracking_code
#   use EmailObfuscator
#   use HTML5::Forms
#   use HTML5::Hidden
# end

require "nokogiri"

# TODO: args for nokogiri, export format, indentation etc
module Multigiri
  class HTML
    # Ruby GC is weak
    CONTENT_TYPE   = "Content-Type"
    CONTENT_LENGTH = "Content-Length"
    DEFAULT_TYPES  = ["text/html"]

    attr_reader :options, :block
    def initialize(app, options = Hash.new, &block)
      @app, @options, @block = app, options, block
      @options[:indentation]   ||= 2
      @options[:content_types] ||= self.class::DEFAULT_TYPES
    end

    def call(env)
      status, headers, chunks = @app.call(env)
      check_content_type
      if options[:content_types].empty? || options[:content_types].any? { |type| headers[CONTENT_TYPE].match(type) }
        run(status, headers, chunks)
      else
        [status, headers, chunks]
      end
    end

    # convert to a Nokogiri document
    def run(status, headers, chunks)
      # the only what we know about body is that it has to respond to #each
      body = String.new
      chunks.each { |chunk| body += chunk }
      document = Nokogiri::HTML(body) # before
      @stack = lambda { |env| [status, headers, document] }

      # get middlewares
      self.instance_eval(&@block) if @block

      # convert back to a [String]
      status, headers, document = @stack.call(env)
      body = document.to_html(indentation: options[:indentation]) # TODO
      headers[CONTENT_LENGTH] = body.bytesize.to_s
      return [status, headers, [body]]
    end

    # GoogleAnalytics.new(Other.new(self), tracking_code)
    def use(klass, *args, &block)
      @stack = klass.new(@stack, *args, &block)
    end

    protected
    def check_content_type
      if headers[CONTENT_TYPE].nil? && !options[:content_types].empty?
        raise "Content-Type has to be set before you call multigiri, so multigiri can decide if it will parse the document or not!"
      end
    end
  end

  class XML
    # XML has many MIME types, if you want to work with all posible XML MIME types, you can use
    # use Multigiri, mime_type: /xml/
    DEFAULT_TYPES = ["text/xml"]

    def run(status, headers, chunks)
      # the only what we know about body is that it has to respond to #each
      body = String.new
      chunks.each { |chunk| body += chunk }
      document = Nokogiri::XML(body) # before
      @stack = lambda { |env| [status, headers, document] }

      # get middlewares
      self.instance_eval(&@block) if @block

      # convert back to a [String]
      status, headers, document = @stack.call(env)
      body = document.to_xml(indentation: options[:indentation]) # TODO
      headers[CONTENT_LENGTH] = body.bytesize.to_s
      return [status, headers, [body]]
    end
  end
end
