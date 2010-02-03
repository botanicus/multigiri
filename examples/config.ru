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
use Multigiri do
  use HTML5::Forms
  use HTML5::Hidden
  use EmailObfuscator
  use GoogleAnalytics, :my_tracking_code
end

# It's especially important to run these middlewares after multigiri,
# because in multigiri middleware you probably change the resulted HTML
use ContentType
use ContentLength

# We can't use the trick with __END__ as is used in sinatra, since Rack
# authors are stupid idiots and the content of the rackup file is eval-ed.
# This crappy design leads to more problems than just this one.
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
