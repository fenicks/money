struct Money
  module Casting
    # Returns the amount of money as a `BigDecimal`.
    #
    # ```
    # Money.us_dollar(1_00).to_big_d # => BigDecimal.new("1.00")
    # ```
    def to_big_d : BigDecimal
      amount
    end

    # Returns the amount of money as a `BigFloat`. Floating points cannot guarantee
    # precision. Therefore, this function should only be used when you no longer
    # need to represent currency or working with another system that requires
    # floats.
    #
    # ```
    # Money.us_dollar(100).to_big_f # => 1.0
    # ```
    def to_big_f : BigFloat
      amount.to_big_f
    end
  end
end
