# encoding: utf-8

# @example
#   use Multigiri do
#     use LinkChecker, Rango.logger do |path|
#       "public" + path
#     end
#   end
class Multigiri
  class LinkChecker
    def initialize(app, logger, patterns = nil, &block)
      @app, @logger, @patterns, @block = app, logger, patterns, block
      @patterns ||= {"img" => "src", "link" => "href", "a" => "href"}
    end

    def links
      @links ||= Array.new
    end

    def call(env)
      status, headers, document = @app.call(env)
      @patterns.each do |tag, attribute|
        document.css("#{tag}[#{attribute}]").each do |element|
          link = element[attribute]
          unless link.match(/^\w+:\/\//)
            self.links << link
          end
        end
      end
      check_links
      [status, headers, document]
    end

    private
    def check_links
      self.links.each do |link|
        real_path = @block.call(link)
        unless File.exist?(real_path)
          @logger.error("[LINK] #{link} doesn't exist")
        end
      end
    end
  end
end
