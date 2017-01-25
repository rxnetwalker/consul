module Abilities
  class Everyone
    include CanCan::Ability

    def initialize(user)
      can [:read, :map], Debate
      can [:read, :map, :summary], Proposal
      can :read, Comment

      can [:read, :welcome, :select_district], SpendingProposal
      can [:stats, :results], SpendingProposal

      can :read, Poll
      can :read, Poll::Question

      can [:read, :welcome], Budget
      can [:read, :print], Budget::Investment
      can [:read], Budget::Group

      can :read, Legislation
      can :read, User
      can [:search, :read], Annotation

      can :new, DirectMessage

      can [:read, :create, :thanks], ::Nvote
    end
  end
end
