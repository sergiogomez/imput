class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.subject = "[#{Rails.env}] #{message.to} #{message.subject}"
    message.to = ['dev@imput.io']
  end
end
