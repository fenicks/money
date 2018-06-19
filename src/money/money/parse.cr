class Money
  module Parse
    class Error < Money::Error
    end

    PATTERNS = {
      # 10,23 PLN
      /(?<sign>\+|\-)?(?<amount>\d+(?:[.,]\d+)?)\s*(?<symbol>[^0-9,.]+)/,
      # $10.23
      /(?<sign>\+|\-)?(?<symbol>[^0-9,.]+)\s*(?<amount>\d+(?:[.,]\d+)?)/,
    }

    def parse(str : String, allow_ambigous = true) : Money
      parse(str, allow_ambigous) { |ex| raise ex }
    end

    def parse?(str : String, allow_ambigous = true) : Money?
      parse(str, allow_ambigous) { nil }
    end

    private def parse(str : String, allow_ambigous : Bool)
      matched_pattern = PATTERNS.each do |pattern|
        if str =~ pattern
          break $~["amount"], $~["symbol"], $~["sign"]?
        end
      end

      if matched_pattern
        amount, symbol, sign = matched_pattern
      else
        raise Error.new "Invalid format"
      end

      currency = begin
        matches = Currency.select(&.==(symbol))
        matches = Currency.select(&.symbol.==(symbol)) if matches.empty?
        matches = Currency.select(&.alternate_symbols.try(&.includes?(symbol))) if matches.empty?

        case matches.size
        when 0
          raise Error.new "Symbol #{symbol.inspect} didn't matched any currency"
        when 1
          matches.first
        else
          unless allow_ambigous
            raise Error.new "Symbol #{symbol.inspect} matches multiple currencies: #{matches.map(&.to_s)}"
          end
          matches.first
        end
      end

      amount = amount.gsub(',', '.')
      amount = "#{sign}#{amount}" if sign

      Money.from_amount(amount, currency)
    rescue ex : Money::Error
      return yield Error.new "Cannot parse #{str.inspect}", ex
    end
  end
end
