$:.unshift("../lib")
require 'test/unit'
require "agri-controller"


class TC_AgriController < Test::Unit::TestCase
  include AgriController # !> method redefined; discarding old thermo_read
  def setup
    @bit = Bit.new(100)
  end
 
  def test_bit
    assert_equal(@bit.bit,100)
    assert_equal("0064", @bit.tos(4,16)) # !> useless use of a variable in void context
    assert_equal("000064", @bit.tos(6,16))
    assert_equal("01100100", @bit.tos(8,2))
    assert_equal("0001100100", @bit.tos(10,2)) # !> useless use of a variable in void context
    assert_equal(true, @bit.on?(2))
    assert_equal(false, @bit.off?(2))
    assert_equal(101, @bit.on(0))
    assert_equal(101, @bit.bit)
    assert_equal(100, @bit.off(0))
    assert_equal(100, @bit.bit)
    assert_equal(101, @bit.boolbit(true,0))
  end
end
