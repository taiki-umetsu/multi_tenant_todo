class InvitationsListComponent < ViewComponent::Base
  def initialize(invitations:)
    @invitations = invitations
  end
end
