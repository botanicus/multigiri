# encoding: utf-8

# Add Google Analytics tracking to your page

# @example
#   use Multigiri do
#     use GoogleAnalytics, :my_tracking_code if Rango.production?
#   end

class Multigiri
  class GoogleAnalytics
    attr_accessor :tracking_code
    def initialize(app, tracking_code)
      @app, @tracking_code = app, tracking_code
    end

    def call(env)
      status, headers, document = @app.call(env)
      body = document.xpath("/html/body")[0]

      # include scripts to the page
      script(body, protocol_recognition_script)
      script(body, tracker_script)

      [status, headers, document]
    end

    protected
    def script(body, content)
      script = Nokogiri::XML::Node.new(:script, body.document)
      script.inner_html = content
      body.add_child(script)
    end

    def protocol_recognition_script
      <<-EOF
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
      EOF
    end

    def tracker_script
      <<-EOF
try {
  var pageTracker = _gat._getTracker("#{self.tracking_code}");
  pageTracker._trackPageview();
} catch(err) {}
      EOF
    end
  end
end
