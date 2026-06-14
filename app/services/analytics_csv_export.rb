class AnalyticsCsvExport
  def self.call(summary)
    rows = [["metric", "value"]]
    summary.each { |key, value| rows << [key, value] }
    rows.map { |row| row.map { |value| value.to_s.gsub(",", " ") }.join(",") }.join("\n")
  end
end
