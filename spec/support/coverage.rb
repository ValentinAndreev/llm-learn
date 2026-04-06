require "coverage"
require "fileutils"
require "json"
require "time"

module TestCoverage
  ROOT = File.expand_path("../..", __dir__)
  SUMMARY_PATH = File.join(ROOT, "coverage", "summary.json")
  MINIMUM_LINE_COVERAGE = 80.0
  TRACKED_PREFIXES = [
    File.join(ROOT, "app") + "/",
    File.join(ROOT, "lib") + "/"
  ].freeze

  module_function

  def tracked_file?(path)
    TRACKED_PREFIXES.any? { |prefix| path.start_with?(prefix) }
  end

  def relative_path(path)
    path.delete_prefix("#{ROOT}/")
  end

  def line_hits_for(entry)
    return entry[:lines] if entry.is_a?(Hash)

    entry
  end
end

Coverage.start(lines: true)

at_exit do
  result = Coverage.result

  files = result.each_with_object({}) do |(path, entry), memo|
    next unless TestCoverage.tracked_file?(path)

    hits = TestCoverage.line_hits_for(entry)
    next unless hits

    relevant_hits = hits.compact
    total_lines = relevant_hits.length
    covered_lines = relevant_hits.count { |value| value.to_i.positive? }
    line_coverage = total_lines.zero? ? 100.0 : ((covered_lines.to_f / total_lines) * 100).round(2)

    memo[TestCoverage.relative_path(path)] = {
      covered_lines: covered_lines,
      total_lines: total_lines,
      line_coverage: line_coverage
    }
  end

  covered_lines = files.values.sum { |file| file[:covered_lines] }
  total_lines = files.values.sum { |file| file[:total_lines] }
  line_coverage = total_lines.zero? ? 100.0 : ((covered_lines.to_f / total_lines) * 100).round(2)
  passed = line_coverage >= TestCoverage::MINIMUM_LINE_COVERAGE

  summary = {
    generated_at: Time.now.utc.iso8601,
    minimum_line_coverage: TestCoverage::MINIMUM_LINE_COVERAGE,
    actual_line_coverage: line_coverage,
    covered_lines: covered_lines,
    total_lines: total_lines,
    passed: passed,
    files: files
  }

  FileUtils.mkdir_p(File.dirname(TestCoverage::SUMMARY_PATH))
  File.write(TestCoverage::SUMMARY_PATH, JSON.pretty_generate(summary))

  warn("Coverage: #{line_coverage}% (minimum #{TestCoverage::MINIMUM_LINE_COVERAGE}%)")
  exit(1) unless passed
end
