#!/usr/bin/env rackup -p 4000 -s thin

$:.unshift(::File.expand_path("../../lib", __FILE__))

require "multigiri"
require "multigiri/html5"
require "multigiri/email_obfuscator"
require "multigiri/google_analytics"

# Multigiri change the last element of the rack array from body to
# nokogiri, document so instead of [status, headers, body] you'll get
# [status, headers, document]. After the multigiri block everything
# will get to normal, so middlewares whichrun later won't be affected.
use Multigiri::HTML do
  use Multigiri::HTML5::Forms
  use Multigiri::HTML5::Hidden
  use Multigiri::EmailObfuscator
  use Multigiri::GoogleAnalytics, :my_tracking_code
end

# RSS / Atom feeds processing
use Multigiri::XML, content_types: ["application/rss+xml", "application/atom+xml"] do
  # TODO
end

# Generic XML processing
use Multigiri::XML, content_types: [/\/xml$/] do
  # TODO
end

use Rack::ContentType, "text/html"

# We can't use the trick with __END__ as is used in sinatra,
# since the content of the rackup file is eval-ed. This
# crappy design leads to more problems than just this one.
# template = ::File.read(__FILE__).split("__END__").last
template = ::File.read(__FILE__).match(/=begin template\n(.+)\n=end/m)[1]

run lambda { |env| [200, Hash.new, [template]] }

=begin template
<html>
  <body>
    <h1>Hello World!</h1>
    <a href='joe@example.com'>mail</a>
    <p hidden>test</p>
    <p hidden style="color:red">test</p>
    <form method="GET">
    </form>
    <form method="PUT">
    </form>
    <form method="DELETE">
    </form>
  </body>
</html>
=end
