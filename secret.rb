class Secret < Sequel::Model
  many_to_one :user
  many_to_many :viewers, :join_table => :secret_view_rights, :left_key => :secret_id, :right_key => :viewer_id, :class => :User

  set_allowed_columns :title, :body, :viewer_logins

  def allowed_to_view?(user)
    self.user_id == user.id or self.viewers.include?(user)
  end

  def allowed_to_update?(user)
    self.user_id == user.id
  end

  def viewer_logins
    self.viewers.map {|u| u.login}.join(", ")
  end

  def viewer_logins=(users)
    self.remove_all_viewers
    users.split(/[, ]+/).each do |login|
      if user = User[:login => login] and user != self.user
        self.add_viewer(user)
      end
    end
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
