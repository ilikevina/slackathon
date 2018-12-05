module Slackathon
  class Command
    def self.dispatch_command(params)
      begin
        self.new(params).call
      rescue Exception => e
        post_error(e.message)
      end
    end

    def self.dispatch_interaction(params)
      if params[:type] == "dialog_submission"
        self.new(params).dialog_callback
      else
        action = params[:actions][0]
        method = self.new(params).public_method(action[:name])
        value = action[:value]
        if method.arity == 0
          method.call
        else
          method.call(self.unescape(value))
        end
      end
    end

    def self.unescape(message)
      message.gsub(/&amp;/, "&")
        .gsub(/&lt;/, "<")
        .gsub(/&gt;/, ">")
    end

    def initialize(params)
      @params = params
    end

    private
    
    def self.post_error(message)
    {
      response_type: "in_channel",
      delete_original: true,
      attachments: [
        {
          color: "danger",
          text: message
        }
      ]
    }
    end

    attr_reader :params
  end
end
