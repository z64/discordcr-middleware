require "../spec_helper"

module DiscordMiddleware
  describe DiscoParser do
    describe DiscoParser::Argument do
      describe "#parse" do
        it "parses a required argument" do
          arg = DiscoParser::Argument.new(DiscoParser::PARTS_RE.match("<a:int>").not_nil!)
          arg.name.should eq "a"
          arg.required.should be_true
          arg.count.should eq 1
          arg.types.should eq ["int"]
          arg.catch_all.should be_false
        end

        it "parses an optional argument" do
          arg = DiscoParser::Argument.new(DiscoParser::PARTS_RE.match("[a:int]").not_nil!)
          arg.required.should be_false
        end

        it "parses a flag" do
          arg = DiscoParser::Argument.new(DiscoParser::PARTS_RE.match("{a}").not_nil!)
          arg.name.should eq "a"
          arg.@flag.should be_true
        end

        it "parses catch-all" do
          arg = DiscoParser::Argument.new(DiscoParser::PARTS_RE.match("<foo:str...>").not_nil!)
          arg.types.should eq ["str"]
          arg.catch_all.should be_true
        end
      end
    end

    describe DiscoParser::ArgumentSet do
      describe "#parse" do
        it "parses multiple arguments" do
          set = DiscoParser::ArgumentSet.new("<foo:str> <bar:int>")
          set.arguments.size.should eq 2
        end

        context "with a required argument after an optional one" do
          it "raises" do
            expect_raises(Exception, "Required argument cannot come after an optional argument") do
              DiscoParser::ArgumentSet.new("[foo] <bar>")
            end
          end
        end

        context "with a regular argument after a catch-all" do
          it "raises" do
            expect_raises(Exception, "No arguments can come after a catch-all") do
              DiscoParser::ArgumentSet.new("<foo...> <bar>")
            end
          end
        end
      end
    end
  end
end
