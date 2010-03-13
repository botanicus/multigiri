# encoding: utf-8

# You might want to use some HTML 5 features right now, so your code is more readable & cleaner.

# In future it can detect if the browser is capable to deal with given HTML 5 feature and
# if yes, then there will be no transformation required. But then carefully with caching :)
class Multigiri
  module HTML5
    # Browsers supporting HTML 5 should can submit forms through PUT or DELETE natively.
    class Forms
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, document = @app.call(env)
        nodes = document.css("form[method=PUT]") + document.css("form[method=DELETE]")
        nodes.each do |form|
          input = Nokogiri::XML::Node.new("input", document)
          input["type"] = "hidden"
          input["name"] = "_method"
          input["value"] = form["method"]
          form["method"] = "POST"
          form.add_child(input)
        end
        [status, headers, document]
      end
    end

    # Elements can have attribute hidden.
    class Hidden
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, document = @app.call(env)
        document.css("[hidden]").each do |element|
          element.remove_attribute("hidden")
          if element["style"]
            element["style"] += "; display: none"
          else
            element["style"] = "display:none"
          end
        end
        [status, headers, document]
      end
    end
  end
end
