class CompareController < ApplicationController
  helper CsvHelper
  helper ProjectsHelper
  helper RatingsHelper
  before_action :setup_header, only: [:projects]

  def projects
    find_projects
  end

  def projects_graph
    @metric = params[:metric]
    find_projects
    set_date_ranges
    populate_chart_plot_points_and_series
  end

  private

  def find_projects
    @projects = [Project.where(name: params[:project_0]).first,
                 Project.where(name: params[:project_1]).first,
                 Project.where(name: params[:project_2]).first]
  end

  def populate_chart_plot_points_and_series
    @series_of_plot_points = {}
    @projects.compact.each do |project|
      next if project.nil? || project.best_analysis.nil?
      @series_of_plot_points[project.name] = metric_data(@metric, project)
      @series_of_plot_points[project.name].pop
    end
  end

  def set_date_ranges
    present_date = Time.now.utc
    @end_date = Time.now.utc.strftime('%Y-%m-01')
    @start_date = Time.utc(present_date.year - 3, present_date.month).strftime('%Y-%m-01')
  end

  def setup_header
    return unless request_format == 'csv'
    response.content_type = 'text/csv'
    response.headers['Content-Disposition'] = 'attachment; filename="export_compare.csv"'
  end

  def metric_data(metric_name, project)
    data = project.best_analysis.send("#{metric_name}_history".to_sym, @start_date, @end_date)
    data.map do |values|
      metric_name == 'code_total' ? values['code_total'].to_i : values["#{metric_name.pluralize}"].to_i
    end
  end
end
