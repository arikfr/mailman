module Mailman
  class Route

    # Matches against the To addresses of a message.
    class ToCondition < Condition
      def match(message)
        if !message.to.nil?
          message.to.each do |address|
            if result = @matcher.match(address)
              return result
            end
          end
        end
        nil
      end
    end

    # Matches against the From addresses of a message.
    class FromCondition < Condition
      def match(message)
        message.from.each do |address|
          if result = @matcher.match(address)
            return result
          end
        end
        nil
      end
    end

    # Matches against the Subject of a message.
    class SubjectCondition < Condition
      def match(message)
        @matcher.match(message.subject)
      end
    end

    # Matches against the Body of a message.
    class BodyCondition < Condition
      def match(message)
        if message.multipart?
          message.parts.each do |part|
            if result = @matcher.match(part.decoded)
              return result
            end
          end
        else
          @matcher.match(message.body.decoded)
        end
      end
    end

    # Matches against the CC header of a message.
    class CcCondition < Condition
      def match(message)
        if !message.cc.nil?
          message.cc.each do |address|
            if result = @matcher.match(address)
              return result
            end
          end
        end
        nil
      end
    end

    # Matches against any header. Syntax: header-name=pattern
    class HeaderCondition < Condition
      # @param [String, Regexp] the raw matcher to use in the condition,
      #   converted to a matcher instance by {Matcher.create}
      def initialize(header_condition)
        @header, condition = header_condition.split('=',2)
        super condition
      end

      def match(message)
        if !(header = message.header[@header]).nil?
          values = if header.is_a?(Array)
                     header.map { |h| h.value }
                   else
                     [header.value]
                   end
          values.each do |value|
            if result = @matcher.match(value)
              return result
            end
          end
        end
        nil
      end
    end

  end
end
