class Secret < Sequel::Model
  set_allowed_columns :title, :body

  def allowed_to_view?(user)
    self.user_id == user.id
  end

  def allowed_to_update?(user)
    self.user_id == user.id
  end

  def validate
    if title.empty?
      errors.add(:title, "nem lehet üres")
    end
    if body.empty?
      errors.add(:body, "nem lehet üres")
    end
  end

  def before_create
    self.created_at = Time.now
  end
end
