module ArchivedUsersHelper

  def unarchive_user_small_button_for(user)
    name = "<button class='btn-theme animation text-theme-danger fw-bold'>Unarchive</button>"
    link_to name.html_safe, user_unarchive_path(user), method: :delete
  end

  def unarchive_user_button_for(user)
    link_to(
      "Unarchive",
      user_unarchive_path(user),
      method: :delete,
      class: "btn-theme animation text-theme-danger fw-bold"
    )
  end

  def archive_user_button_for(user)
    link_to(
      "Archive #{user.type}",
      user_archive_path(user),
      method: :post,
      class: "btn-theme animation text-theme-danger fw-bold"
    )
  end
end
