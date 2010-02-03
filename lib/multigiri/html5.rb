# encoding: utf-8

module Rack
  class Multigiri
    module HTML5
      class Forms
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, document = @app.call(env)
          nodes = document.css("form[method=PUT]") + document.css("form[method=DELETE]")
          nodes.each do |form|
            input = Nokogiri::XML::Node.new("input", document)
            input[:type] = "hidden"
            input[:name] = "_method"
            input[:value] = form[:method]
            form[:method] = "POST"
            form.add_child(input)
          end
          [status, headers, document]
        end
      end

      class Hidden
        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, document = @app.call(env)
          document.css("[hidden]").each do |element|
            element.remove_attribute("hidden")
            if element[:style]
              element[:style] += "; display: none"
            else
              element[:style] = "display:none"
            end
          end
          [status, headers, document]
        end
      end
    end
  end
end
