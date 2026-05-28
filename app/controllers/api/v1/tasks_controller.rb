module Api
  module V1
    # Legacy non-namespaced tasks endpoint. Kept in place so older clients
    # don't 404, but routes to the same behavior as the agent-namespaced
    # controller. New code should target /api/v1/agent/tasks instead.
    class TasksController < Agent::TasksController
    end
  end
end
