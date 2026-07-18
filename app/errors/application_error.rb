class ApplicationError < StandardError
  def http_status
    :unprocessable_entity
  end
end
