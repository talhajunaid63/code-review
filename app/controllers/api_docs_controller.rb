class ApiDocsController < ApplicationController
  include BasicAuthenticationProtected
  before_action :get_all_docs

  def index
  end

  def show
    @doc = params[:id]
    @markdown = File.read("app/views/api_docs/v1/#{@doc}.md")
    @updated_at = File.mtime("app/views/api_docs/v1/#{@doc}.md")
  end

  def get_all_docs
    @docs = Dir.glob("app/views/api_docs/v1/**/*.md").sort!
  end

end
