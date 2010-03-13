# encoding: utf-8

# use Multigiri do
#   use GoogleAnalytics, :my_tracking_code
#   use EmailObfuscator
#   use HTML5::Forms
#   use HTML5::Hidden
# end

require "nokogiri"

# TODO: args for nokogiri, export format, indentation etc
class Multigiri
  def initialize(app, &block)
    @app, @block = app, block
  end

  def call(env)
    # convert to a Nokogiri document
    status, headers, chunks = @app.call(env)
    # the only what we know about body is that it has to respond to #each
    body = String.new
    chunks.each { |chunk| body += chunk }
    document = Nokogiri::HTML(body) # before
    @stack = lambda { |env| [status, headers, document] }

    # get middlewares
    self.instance_eval(&@block) if @block

    # convert back to a [String]
    status, headers, document = @stack.call(env)
    body = document.to_html(indentation: 2) # TODO
    headers["Content-Length"] = body.bytesize.to_s
    [status, headers, [body]]
  end

  # GoogleAnalytics.new(Other.new(self), tracking_code)
  def use(klass, *args, &block)
    @stack = klass.new(@stack, *args, &block)
  end
end
