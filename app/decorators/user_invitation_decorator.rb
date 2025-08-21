module UserInvitationDecorator
  def to_table_row
    invitation_url = new_user_url(token: token)
    [
      { body: email, type: :text },
      {
        body: admin? ? "管理者" : "メンバー",
        type: admin? ? :badge_success : :badge_info
      },
      { body: l(created_at.to_date, format: :long), type: :date },
      {
        body: expired? ? "期限切れ" : "有効",
        type: expired? ? :badge_yellow : :badge_success
      },
      {
        body: copy_url_button_html(invitation_url)
      }
    ]
  end

  private

  def copy_url_button_html(invitation_url)
    content_tag(:div,
      render(ButtonComponent.new(
        text: "URLをコピー",
        type: :secondary,
        data: {
          clipboard_target: "button",
          action: "click->clipboard#copy"
        }
      )),
      data: {
        controller: "clipboard",
        clipboard_text_value: invitation_url
      }
    )
  end
end
