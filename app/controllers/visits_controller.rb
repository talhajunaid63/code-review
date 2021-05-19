class VisitsController < ApplicationController
  def demo
    @demo_visit = DemoVisit.return_valid_demo_visit
    authorize @demo_visit, policy_class: VisitPolicy

    @participant_tok_token = TokBoxService.new(@demo_visit).generate_token
    @participant_tok_apikey = ApplicationConfig["TOK_API_VP8"]
  end
end
