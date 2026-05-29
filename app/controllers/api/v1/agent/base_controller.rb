module Api
  module V1
    module Agent
      # Base controller for the agent-scoped API surface.
      #
      # All requests authenticate via the X-Agent-Token header, which resolves
      # to an Agent record (and from there, to its owning User). Subclasses can
      # call `current_agent` and `current_user` freely.
      class BaseController < Api::V1::BaseController
      end
    end
  end
end
