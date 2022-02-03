# frozen_string_literal: true

return unless ENV['RACK_ENV'] == 'production'

require 'new_relic/agent/instrumentation/controller_instrumentation'
require 'new_relic/agent/parameter_filtering'

class Roda
  module RodaPlugins
    module NewRelicInstrumentation
      module InstanceMethods
        def self.included(base)
          base.include NewRelic::Agent::Instrumentation::ControllerInstrumentation
        end

        def _roda_run_main_route(r)
          params = NewRelic::Agent::ParameterFiltering.apply_filters(r.env, r.params)
          perform_action_with_newrelic_trace(category: :controller, params: params) { super }
        rescue StandardError => e
          NewRelic::Agent.notice_error(e)
          raise e
        end
      end
    end

    register_plugin(:new_relic, NewRelicInstrumentation)
  end
end
