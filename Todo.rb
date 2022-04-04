class Todo

    attr_accessor :completed, :text
    def initialize(completed, text)
        @completed = completed
        @text = text
    end
end