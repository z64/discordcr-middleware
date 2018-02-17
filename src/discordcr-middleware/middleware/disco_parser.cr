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
    # Name of this argument
    getter name

    # Number of raw arguments that compose this argument
    getter count

    # Wheter this argument is required
    getter required

    # Types this argument supportsa
    getter types

    # Whether this is a "catch-all" argument
    getter catch_all

    def initialize(@raw : Regex::MatchData, @name : String? = nil,
                   @count : Int32 = 1, @required : Bool = false,
                   @catch_all : Bool = false, @flag = false,
                   @types : Array(String)? = nil)
      parse(@raw)
    end

    # :nodoc:
    def parse(raw : Regex::MatchData)
      _, prefix, part = raw

      @required = true if prefix == "<"
      @flag = true if prefix == "{"

      unless @flag
        if part.ends_with?("...")
          part = part[0..-4]
          @catch_all = true
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
    # The arguments that compose this set
    getter arguments

    def initialize(@spec_string : String)
      @arguments = [] of Argument
      parse(@spec_string)
    end

    # :nodoc:
    def parse(spec : String)
      spec.scan(PARTS_RE) do |match|
        arg = Argument.new(match)

        if @arguments.any?
          if !@arguments.last.required && arg.required
            raise "Required argument cannot come after an optional argument"
          end

          if @arguments.last.catch_all
            raise "No arguments can come after a catch-all"
          end
        end

        @arguments << arg
      end
    end
  end

  def initialize(@spec_string : String)
  end

  def call(context, done)
    done.call
  end
end
