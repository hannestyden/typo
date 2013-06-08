module Typo
  ANYTHING = Object.new

  ArgumentTypeError = Class.new(ArgumentError)
  ReturnTypeError   = Class.new(ArgumentError)

  def returns(return_type, locals = [], types = [])
    locals.zip(types).each do |((name, var), type)|
      if type
        var.is_a?(type) || (raise ArgumentTypeError.new('type_error'))
      end
    end
    return_value = yield
    if return_type == ANYTHING || return_value.is_a?(return_type)
      return_value
    else
      raise ReturnTypeError.new('type_error')
    end
  end
end

if $0 == __FILE__
  gem 'minitest'
  require 'minitest/autorun'
  class TestTypo < Minitest::Test
    class TestClass
      include Typo

      def one_arg(string,
      _ts       =[String])
        _ls = local_variables.reduce([]) { |vars, name| vars << [ name, eval(name.to_s) ]}
        returns String, _ls, _ts do
          string
        end
      end

      def two_args(string, symbol,
      _ts        =[String, Symbol])
        _ls = local_variables.reduce([]) { |vars, name| vars << [ name, eval(name.to_s) ]}
        returns String, _ls, _ts do
          string
        end
      end

      def returns_anything
        returns ANYTHING do
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
