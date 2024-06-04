module Credence
  class GetRoomQuery
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that room'
      end
    end

    class NotFoundError < StandardError
      def message
        'We could not find that room'
      end
    end

    def self.call(account:, user_room:, room:)
      raise NotFoundError unless user_room

      policy = RoomPolicy.new(account, user_room)
      raise ForbiddenError unless policy.can_view?

      room
    end
  end
end
