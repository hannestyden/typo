gem     'binding_of_caller'
require 'binding_of_caller'

module Typo
  ArgumentTypeError = Class.new(ArgumentError)
  ReturnTypeError   = Class.new(StandardError)

  def returns(return_type)
    binding_of_caller = binding.of_caller(1)
    if binding_of_caller
      locals =
        eval('local_variables', binding_of_caller).reduce([]) do |vars, name|
          vars << [name, eval(name.to_s, binding_of_caller)]
        end
      types =
        begin
          eval('____', binding_of_caller)
        rescue NameError
          []
        end
      locals.zip(types).each do |((name, var), type)|
        if type
          var.is_a?(type) || (raise ArgumentTypeError.new('Better error description'))
        end
      end
    end
    return_value = yield
    if return_value.is_a?(return_type)
      return_value
    else
      raise ReturnTypeError.new('Better error description')
    end
  end
end

if $0 == __FILE__
  gem 'minitest'
  require 'minitest/autorun'
  class TestTypo < Minitest::Test
    class TestClass
      include Typo

      # Never used, only for style demonstration.
      def a(numeric,
      ____=[Numeric])
        returns Object do
          :anything
        end
      end

      def one_arg(string,
      ____      =[String])
        returns Object do
          string
        end
      end

      def two_args(string, symbol,
      ____       =[String, Symbol])
        returns Object do
          string
        end
      end

      def returns_anything
        returns Object do
          yield
        end
      end

      def return_value
        returns String do
          yield
        end
      end
    end

    def test_one_arg_valid
      test = TestClass.new
      assert_equal 'string', test.one_arg('string')
    end

    def test_one_arg_invalid
      test = TestClass.new
      assert_raises Typo::ArgumentTypeError do
        test.one_arg(:symbol)
      end
    end

    def test_two_args_valid
      test = TestClass.new
      assert_equal 'string', test.two_args('string', :symbol)
    end

    def test_two_args_invalid
      test = TestClass.new
      assert_raises Typo::ArgumentTypeError do; test.two_args('string', 'string'); end
      assert_raises Typo::ArgumentTypeError do; test.two_args(:symbol, :symbol);   end
    end

    def test_returns_anything
      test = TestClass.new
      assert_equal 'string', test.returns_anything { 'string' }
      assert_equal :symbol,  test.returns_anything { :symbol }
    end

    def test_return_value_valid
      test = TestClass.new
      assert_equal 'string', test.return_value { 'string' }
    end

    def test_return_value_invalid
      test = TestClass.new
      assert_raises Typo::ReturnTypeError do
        test.return_value { :symbol }
      end
    end
  end
end
