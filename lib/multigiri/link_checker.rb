# encoding: utf-8

# @example
#   use Multigiri do
#     use LinkChecker, Logger.new("log/links.log") do |checker|
#       def checker.path_from_link(link)
#         "media" + link
#       end
#     end
#   end
module Multigiri
  class LinkChecker
    def initialize(app, logger, patterns = nil, &block)
      @app, @logger, @patterns = app, logger, patterns
      @patterns ||= {"img" => "src", "link" => "href", "a" => "href"}
      block.call(self) unless block.nil?
    end

    def call(env)
      @path_info = env["PATH_INFO"]
      status, headers, document = @app.call(env)
      @patterns.each do |tag, attribute|
        document.css("#{tag}[#{attribute}]").each do |element|
          link = element[attribute]
          if link.match(/^\w+:\/\//)
            check_remote_link(link)
          else
            check_local_link(link)
          end
        end
      end
      [status, headers, document]
    end

    private
    def path_from_link(link)
      "public" + link
    end

    def check_local_link(link)
      real_path = path_from_link(link)
      unless File.exist?(real_path)
        @logger.error("[LINK from #{@path_info}] #{link} doesn't exist in #{real_path}")
      end
    end

    def check_remote_link(link)
      # require "net/http"
      #
      # Net::HTTP::Get.start() do |http|
      #   http
      # end
    end
  end
end
