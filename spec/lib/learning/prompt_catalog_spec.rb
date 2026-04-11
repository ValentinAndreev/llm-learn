require "rails_helper"

RSpec.describe "Learning prompt catalog" do
  let(:prompts_dir) { Pathname.new(Rails.root).join("learning", "prompts") }

  let(:required_files) do
    %w[
      intake/system_role.md
      intake/ask_missing_context.md
      intake/check_completeness.md
      intake/build_brief.md
      conspect/build_prompt.md
      conspect/self_review.md
    ]
  end

  let(:template_files) do
    prompts_dir.glob("**/*.md").reject { |f| f.basename.to_s == ".gitkeep" }
  end

  let(:parsed_templates) do
    template_files.map do |path|
      content = path.read
      parts = content.split(/^---\s*$/, 3)
      # parts[0] = before first ---, parts[1] = front matter, parts[2] = body
      front_matter = YAML.safe_load(parts[1] || "")
      body = parts[2] || ""
      { path: path, front_matter: front_matter, body: body }
    end
  end

  it "has exactly 6 template files" do
    expect(template_files.size).to eq(6)
  end

  it "contains all required files" do
    required_files.each do |relative_path|
      full_path = prompts_dir.join(relative_path)
      expect(full_path).to exist, "Expected #{relative_path} to exist"
    end
  end

  it "each file has valid YAML front matter with required keys" do
    required_keys = %w[id purpose expected_output required_variables]
    parsed_templates.each do |template|
      relative = template[:path].relative_path_from(prompts_dir)
      front_matter = template[:front_matter]
      expect(front_matter).to be_a(Hash), "#{relative} must have parseable YAML front matter"
      required_keys.each do |key|
        expect(front_matter).to have_key(key), "#{relative} front matter must include '#{key}'"
      end
    end
  end

  it "each file has non-empty body content after front matter" do
    parsed_templates.each do |template|
      relative = template[:path].relative_path_from(prompts_dir)
      expect(template[:body].strip).not_to be_empty, "#{relative} must have content after front matter"
    end
  end

  it "all template IDs are unique" do
    ids = parsed_templates.map { |t| t[:front_matter]["id"] }
    expect(ids.uniq.size).to eq(ids.size), "Duplicate IDs found: #{ids.tally.select { |_, count| count > 1 }.keys}"
  end

  it "all placeholders in each file body use {{variable_name}} format" do
    parsed_templates.each do |template|
      relative = template[:path].relative_path_from(prompts_dir)
      body = template[:body]

      # Check no single-brace placeholders like {variable}
      expect(body).not_to match(/(?<!\{)\{[a-zA-Z_][a-zA-Z0-9_]*\}(?!\})/),
        "#{relative} contains single-brace placeholders like {variable}"

      # Check no angle-bracket placeholders like <variable>
      expect(body).not_to match(/<[a-zA-Z_][a-zA-Z0-9_]*>/),
        "#{relative} contains angle-bracket placeholders like <variable>"
    end
  end

  it "every {{variable}} used in body appears in required_variables" do
    parsed_templates.each do |template|
      relative = template[:path].relative_path_from(prompts_dir)
      body = template[:body]
      used_variables = body.scan(/\{\{([a-zA-Z_][a-zA-Z0-9_]*)\}\}/).flatten.uniq

      declared_variables = Array(template[:front_matter]["required_variables"])
        .map { |v| v.to_s.gsub(/^\{\{|\}\}$/, "") }

      used_variables.each do |var|
        expect(declared_variables).to include(var),
          "#{relative} uses {{#{var}}} but it is not listed in required_variables"
      end
    end
  end
end
