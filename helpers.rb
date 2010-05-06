helpers do
  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= User[session[:current_user_id]]
  end

  def require_user
    unless logged_in?
      session[:back_url] = request.path
      session[:error] = "Ehhez előbb be kell jelentkezned..."
      redirect "/"
    end
  end

  def form_field(label, object, attribute, type=:text)
    object_name = object.class.name.downcase
    id = "#{object_name}_#{attribute}"
    name = "#{object_name}[#{attribute}]"
    error = object.errors[attribute]
    error = %{<span class="error">#{error}</span>} if error
    unless type.to_sym == :textarea
      %{
        <p>
          <label for="#{id}">#{label}:</label>
          <input type="#{type}" id="#{id}" name="#{name}" value="#{object[attribute]}"/>
          #{error}
        </p>
      }
    else
      %{
        <p>
          <label for="#{id}">#{label}:</label> #{error}<br/>
          <textarea id="#{id}" name="#{name}" rows="10" cols="60">#{object[attribute]}</textarea>
        </p>
      }
    end
  end

  def secret_li(secret)
    css_class = secret.allowed_to_view?(current_user) ? "unlocked" : "locked"
    %{<li class="#{css_class}"><a href="/secrets/#{secret.id}">#{secret.title}</a></li>}
  end
end

class NilClass
  def empty?
    true
  end
end
