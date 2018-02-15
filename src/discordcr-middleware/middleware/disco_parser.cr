# Middleware for command parsing, based on b1naryth1ef's command parser in the
# [disco](https://github.com/b1naryth1ef/disco.git) library.
class DiscordMiddleware::DiscoParser < Discord::Middleware
  # Regex which splits out argument parts
  PARTS_RE = /(\<|\[|\{)((?:\w+|\:|\||\.\.\.| (?:[0-9]+))+)(?:\>|\]|\})/

  # Map of common strings interpreted as boolean values
  BOOL_OPS = {
    "yes"   => true,
    "no"    => false,
    "true"  => true,
    "false" => false,
    "1"     => true,
    "0"     => false,
    "on"    => true,
    "off"   => false,
  }

  # Map of command spec tokens to anonymous casting functions
  TYPE_MAP = {
    "str"       => ->(ctx : Context, data : String) { data },
    "int"       => ->(ctx : Context, data : String) { data.to_i },
    "float"     => ->(ctx : Context, data : String) { data.to_f },
    "snowflake" => ->(ctx : Context, data : String) { data.to_u64 },
  }

  # A single argument, a component of an `ArgumentSet`
  class Argument
    def initialize(@raw : Regex::MatchData, @name : String? = nil,
                   @count : Int32 = 1, @required : Bool = false,
                   @flag = false, @types : Array(String)? = nil)
      parse(@raw)
    end

    def count
      @count.zero? ? 1 : @count
    end

    # :nodoc:
    def parse(raw : Regex::MatchData)
      _, prefix, part = raw

      @required = true if prefix == "<"
      @flag = true if prefix == "{"

      unless @flag
        if part.ends_with?("...")
          part = part[0..-4]
          @count = 0
        elsif part.includes?(' ')
          split = part.split(' ')
          part, @count = split[0], split[1].to_i
        end

        if part.includes?(':')
          part, type_info = part.split(':')
          @types = type_info.split('|')
        end
      end

      @name = part.strip
    end
  end

  # A collection of arguments, fully describing a command spec
  class ArgumentSet
  end

  def initialize(@spec_string : String)
  end

  def call(context, done)
    done.call
  end
end
