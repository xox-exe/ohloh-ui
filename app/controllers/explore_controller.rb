class ExploreController < ApplicationController
  helper :Projects

  before_action :projects_details, only: [:index, :projects]

  def index
    render 'explore/projects'
  end

  def demographic_chart
    render json: Project::DemographicChart.data
  end

  def orgs
    @newest_orgs = Organization.active.order(created_at: :desc).limit(3)
    @most_active_orgs = OrgThirtyDayActivity.most_active_orgs
    @stats_by_sector = OrgStatsBySector.recent
    @org_by_30_day_commits = OrgThirtyDayActivity.filter_all_orgs
  end

  def orgs_by_thirty_day_commit_volume
    @org_by_30_day_commits = OrgThirtyDayActivity.filter(params[:filter])
  end

  private

  def projects_details
    @tags = CloudTag.list
    @languages = Language.map
    @projects = Project.hot(params[:lang_id])
    @project_logos = Logo.where(id: @projects.map(&:logo_id)).index_by(&:id)
    @total_count = Project.active.count
    @with_pai_count = Project.with_pai_available
  end
end
