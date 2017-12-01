# Helper module for validating middleware attributes
# against the attributes of another object
module DiscordMiddleware::AttributeMiddleware
  macro check_attributes(object)
    {% for var in @type.instance_vars %}
      if attr = {{object}}.{{var.id}}
        if value = @{{var.id}}
          return unless value == attr
        end
      end
    {% end %}
  end
end
