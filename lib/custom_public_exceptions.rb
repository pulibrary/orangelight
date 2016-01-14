class CustomPublicExceptions < ActionDispatch::PublicExceptions
  def call(env)
    status = env["PATH_INFO"][1..-1]

    if status == "404" or "422" or "500"
      Rails.application.routes.call(env)
    else
      super
    end
  end
end
