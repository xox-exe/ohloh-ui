class CompareProjectAnalysisCsvDecorator
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  def initialize(project)
    @project = project
  end

  def data_quality
    require_best_analysis { |a| t('compare.updated_ago', ago: time_ago_in_words(a.updated_on)) }
  end

  def estimated_cost
    require_best_analysis { |a| number_to_currency(a.cocomo_value.round, precision: 0) }
  end

  def initial_commit
    require_best_analysis { |a| t('compare.ago', ago: time_ago_in_words(a.first_commit_time)) }
  end

  def most_recent_commit
    require_best_analysis { |a| t('compare.ago', ago: time_ago_in_words(a.last_commit_time)) }
  end

  def year_over_year_commits
    require_best_analysis do |a|
      case a.factoids.select { |f| f.is_a?(FactoidActivity) || f.is_a?(FactoidTeamSizeZero) }.first
      when FactoidActivityIncreasing then t('compare.increasing')
      when FactoidActivityDecreasing then t('compare.decreasing')
      when FactoidTeamSizeZero then t('compare.no_activity')
      else t('compare.stable')
      end
    end
  end

  def comments
    require_best_analysis do |a|
      f = a.factoids.select { |factoid| factoid.is_a?(FactoidComments) }.first
      return t('compare.no_comments_found') unless a.relative_comments && f
      t("compare.#{f.class.name.gsub('FactoidComments', '').underscore}")
    end
  end

  def contributors_all_time
    require_best_analysis { |a| pluralize_with_delimiter(a.committers_all_time, t('compare.developer')) }
  end

  def contributors_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.committer_count, t('compare.developer')) }
  end

  def contributors_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.committer_count, t('compare.developer')) }
  end

  def commits_all_time
    require_best_analysis { |a| pluralize_with_delimiter(a.commit_count, t('compare.commit')) }
  end

  def commits_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.commits_count, t('compare.commit')) }
  end

  def commits_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.commits_count, t('compare.commit')) }
  end

  def files_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.files_modified, t('compare.file')) }
  end

  def files_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.files_modified, t('compare.file')) }
  end

  def loc
    require_best_analysis { |a| pluralize_with_delimiter(a.code_total, t('compare.line')) }
  end

  def loc_added_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.lines_added, t('compare.line')) }
  end

  def loc_removed_last_twelve_months
    require_twelve_month { |tms| pluralize_with_delimiter(tms.lines_removed, t('compare.line')) }
  end

  def loc_added_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.lines_added, t('compare.line')) }
  end

  def loc_removed_last_thirty_days
    require_thirty_day { |tds| pluralize_with_delimiter(tds.lines_removed, t('compare.line')) }
  end

  def main_language_name
    require_best_analysis { |a| a.main_language ? a.main_language.nice_name : t('compare.no_code_found') }
  end

  def t(*args)
    I18n.t(*args)
  end

  private

  def require_best_analysis(&block)
    if !@project.best_analysis.nil? && @project.best_analysis.last_commit_time
      block.call(@project.best_analysis)
    else
      (@project.enlistments.count > 0) ? t('compare.pending') : t('compare.no_data')
    end
  end

  def require_twelve_month(&block)
    require_best_analysis do
      tms = @project.best_analysis.twelve_month_summary
      (tms && tms.committer_count > 0) ? block.call(tms) : t('no_activity')
    end
  end

  def require_thirty_day(&block)
    require_best_analysis do
      tds = @project.best_analysis.thirty_day_summary
      (tds && tds.committer_count > 0) ? block.call(tds) : t('no_activity')
    end
  end
end