class NilAnalysis < NullObject
  attr_reader :main_language, :logged_at

  nought_methods :logic_total, :markup_total, :build_total, :headcount

  def twelve_month_summary
    NilAnalysisSummary.new
  end

  def previous_twelve_month_summary
    NilAnalysisSummary.new
  end

  def name_fact_for(_name_id)
    false
  end

  def activity_level
    :na
  end

  def man_years_from_loc(_)
    0
  end

  def factoids
    Factoid.none
  end

  def empty?
    true
  end

  def last_commit_time
    nil
  end

  def contributor_facts
    []
  end
end
