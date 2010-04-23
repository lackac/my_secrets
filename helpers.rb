helpers do
  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= User[session[:current_user_id]]
  end

  def form_field(label, object, attribute, type="text")
    object_name = object.class.name.downcase
    id = "#{object_name}_#{attribute}"
    name = "#{object_name}[#{attribute}]"
    error = object.errors[attribute]
    error = %{<span class="error">#{error}</span>} if error
    %{
      <p>
        <label for="#{id}">#{label}:</label>
        <input type="#{type}" id="#{id}" name="#{name}" value="#{object[attribute]}"/>
        #{error}
      </p>
    }
  end
end

class NilClass
  def empty?
    true
  end
end
