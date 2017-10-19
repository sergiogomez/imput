class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.subject = "[#{Rails.env}] #{message.to} #{message.subject}"
    message.to = ['imput@sergio-gomez.com']
  end
end
