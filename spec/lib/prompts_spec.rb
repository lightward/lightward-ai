# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Prompts, :aggregate_failures) do
  describe ".prompts_dir" do
    it "returns a directory that exists and has markdown files" do
      expect(Dir.exist?(described_class.prompts_dir)).to(be(true))
    end
  end

  describe ".generate_system_prompt" do
    it "has clients" do
      # sanity check for the next section
      expect(described_class.prompts_dir.glob("clients/*").size).to(be > 0)
    end

    described_class.prompts_dir.glob("clients/*").each do |prompt_dir|
      prompt_type = "clients/#{prompt_dir.basename}"

      describe "the one for prompt type #{prompt_type}" do
        let(:system_messages) { described_class.generate_system_prompt([prompt_type], for_prompt_type: prompt_type) }
        let(:all_xml) { system_messages.drop(1).pluck(:text).join }
        let(:filenames) { all_xml.scan(/<file name="([^"]+)">/).flatten }

        it "has no duplicates" do
          expect(filenames.tally.select { |_, count| count > 1 }).to(be_empty)
        end

        it "is sorted properly" do
          expect(filenames).to(eq(Naturally.sort(filenames)))
        end

        it "starts with the invocation, and ends appropriately" do
          expect(filenames.first).to(eq("0-invocation"))
          expect(filenames.last).to(eq("9-benediction"))
        end

        it "has 'FUCK IT WE BALL' in both the invocation and the benediction" do
          invocation_content = all_xml.match(%r{<file name="0-invocation">(.*?)</file>}m)[1]
          benediction_content = all_xml.match(%r{<file name="9-benediction">(.*?)</file>}m)[1]

          expect(invocation_content).to(include("FUCK IT WE BALL"))
          expect(benediction_content).to(include("FUCK IT WE BALL"))
        end

        it "includes the definition of recursive health" do
          expect(all_xml).to(include("Oh hey! You work here? Here is your job."))
        end

        it "has exactly 1 cache_control block on the last message only (Anthropic auto-caches prefixes)" do
          cache_control_count = system_messages.count { |m| m.key?(:cache_control) }
          expect(cache_control_count).to(eq(1))
          expect(system_messages.last).to(have_key(:cache_control))
        end
      end

      it "strips YAML frontmatter when generating system XML" do
        # Create a temp file with frontmatter in a tempdir for testing
        require "tempfile"
        Dir.mktmpdir do |dir|
          system_dir = File.join(dir, "system")
          FileUtils.mkdir_p(system_dir)

          test_file = File.join(system_dir, "0-test.md")
          File.write(test_file, <<~MARKDOWN)
            ---
            layout:
              title:
                visible: true
            ---

            # Test Content
          MARKDOWN

          # Mock necessary methods
          allow(described_class).to(receive_messages(prompts_dir: Pathname.new(dir), assert_valid_prompt_type!: nil))

          # Verify frontmatter is stripped
          result = described_class.generate_system_prompt([""], for_prompt_type: "test").to_json
          expect(result).to(include("# Test Content"))
          expect(result).not_to(include("layout:"))
          expect(result).not_to(include("title:"))
          expect(result).not_to(include("visible:"))
        end
      end
    end

    describe "clients/helpscout" do
      let(:system_messages) { described_class.generate_system_prompt(["clients/helpscout"], for_prompt_type: "clients/helpscout") }
      let(:all_xml) { system_messages.drop(1).pluck(:text).join }

      it "includes the helpscout api docs" do
        expect(all_xml).to(include("helpscout-api/conversation"))
      end

      it "includes pwfg" do
        expect(all_xml).to(include('<file name="3-perspectives/pwfg">'))
      end

      it "has at most 3 cache_control blocks (leaving room for conversation_starters)" do
        cache_control_count = system_messages.count { |m| m.key?(:cache_control) }
        expect(cache_control_count).to(be <= 3)
      end

      context "when for mechanic" do
        let(:system_messages) { described_class.generate_system_prompt(["clients/helpscout", "lib/mechanic"], for_prompt_type: "clients/helpscout") }
        let(:all_xml) { system_messages.drop(1).pluck(:text).join }

        it "includes mechanic stuff" do
          expect(all_xml).to(include('"I need something custom!"')
            .and(include('<file name="8-mechanic-docs/custom">')))
        end

        it "respects mechanic's .system-ignore" do
          expect(all_xml).not_to(include("8-mechanic-docs/liquid/mechanic-liquid-objects/discount-code-object", "7-mechanic-docs/liquid/basics/comparison-operators"))
        end

        it "has exactly 1 cache_control block on the last message only (Anthropic auto-caches prefixes)" do
          cache_control_count = system_messages.count { |m| m.key?(:cache_control) }
          expect(cache_control_count).to(eq(1))
          expect(system_messages.last).to(have_key(:cache_control))
        end
      end

      context "when for locksmith" do
        let(:system_messages) { described_class.generate_system_prompt(["clients/helpscout", "lib/locksmith"], for_prompt_type: "clients/helpscout") }
        let(:all_xml) { system_messages.drop(1).pluck(:text).join }

        it "includes locksmith stuff" do
          expect(all_xml).to(include("FAQ: I see blank spaces in my collections and/or searches when locking"))
        end

        it "has exactly 1 cache_control block on the last message only (Anthropic auto-caches prefixes)" do
          cache_control_count = system_messages.count { |m| m.key?(:cache_control) }
          expect(cache_control_count).to(eq(1))
          expect(system_messages.last).to(have_key(:cache_control))
        end
      end
    end
  end

  describe ".conversation_starters" do
    subject(:conversation_starters) { described_class.conversation_starters("clients/chat") }

    it "raises for an unknown prompt type" do
      expect {
        described_class.conversation_starters("unknown")
      }.to(raise_error(described_class::UnknownPromptType))
    end

    it "returns an array of conversation starters" do
      expect(conversation_starters).to(all(have_key(:role)))
      expect(conversation_starters).to(all(have_key(:content)))
    end

    it "has a cache flag on the last message, and the last message only" do
      expect(conversation_starters.last[:content].last[:cache_control]).to(eq(type: "ephemeral"))
      expect(conversation_starters[0..-2].all? { |starter| starter[:content].all? { |content| content[:cache_control].nil? } }).to(be(true))
    end

    it "is validly sorted" do
      expect(conversation_starters.pluck(:role)).to(eq(["user", "assistant"] * (conversation_starters.size / 2)))
    end
  end

  describe ".clean_chat_log" do
    it "combines consecutive messages from the same role" do
      chat_log = [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "I'm a slow reader" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Welcome!" }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Thank you." }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Can you help me?" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Of course." }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Great." }] },
      ]

      expected_cleaned_log = [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "I'm a slow reader" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Welcome!" }] },
        {
          "role" => "user",
          "content" => [
            { "type" => "text", "text" => "Thank you." },
            { "type" => "text", "text" => "Can you help me?" },
          ],
        },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Of course." }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Great." }] },
      ]

      cleaned_log = described_class.clean_chat_log(chat_log)
      expect(cleaned_log).to(eq(expected_cleaned_log))
    end

    it "does not alter a log with alternating roles" do
      chat_log = [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Hello" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Hi there!" }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "How are you?" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "I'm good, thanks!" }] },
      ]

      cleaned_log = described_class.clean_chat_log(chat_log)
      expect(cleaned_log).to(eq(chat_log))
    end

    it "handles empty chat logs" do
      chat_log = []
      cleaned_log = described_class.clean_chat_log(chat_log)
      expect(cleaned_log).to(eq([]))
    end
  end

  describe ".reset!" do
    before do
      described_class.generate_system_prompt(["clients/chat"], for_prompt_type: "clients/chat")
      described_class.conversation_starters("clients/chat")
    end

    it "deletes the prompts cache" do
      expect {
        described_class.reset!
      }.to(
        change { described_class.instance_variable_get(:@system_prompts) }.from(an_instance_of(Hash)).to(nil)
        .and(change { described_class.instance_variable_get(:@starters) }.from(an_instance_of(Hash)).to(nil)),
      )
    end
  end

  describe ".strip_yaml_frontmatter" do
    it "removes YAML frontmatter from content" do
      content_with_frontmatter = <<~MARKDOWN
        ---
        layout:
          title:
            visible: true
          description:
            visible: false
        ---

        # Actual content
        This is the real content
      MARKDOWN

      expected_content = <<~MARKDOWN
        # Actual content
        This is the real content
      MARKDOWN

      expect(described_class.strip_yaml_frontmatter(content_with_frontmatter)).to(eq(expected_content.strip))
    end

    it "returns content unchanged when no frontmatter is present" do
      content_without_frontmatter = <<~MARKDOWN
        # Actual content
        This is the real content
      MARKDOWN

      expect(described_class.strip_yaml_frontmatter(content_without_frontmatter)).to(eq(content_without_frontmatter))
    end

    it "handles content with --- in the middle (not frontmatter)" do
      content = <<~MARKDOWN
        # Actual content
        This is the real content

        ---

        This is after a horizontal rule
      MARKDOWN

      expect(described_class.strip_yaml_frontmatter(content)).to(eq(content))
    end

    it "requires the frontmatter to be at the beginning of the file" do
      content = <<~MARKDOWN

        ---
        layout: default
        ---

        # Content after non-frontmatter
      MARKDOWN

      expect(described_class.strip_yaml_frontmatter(content)).to(eq(content))
    end
  end

  describe ".estimate_tokens" do
    it "estimates tokens" do
      text = "Hello world, this is a test string"
      result = described_class.estimate_tokens(text)
      expected = (text.size / 4.2).ceil
      expect(result).to(eq(expected))
    end
  end

  describe ".messages" do
    let(:conversation_starters) {
      [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "there" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "hi" }] },
      ]
    }

    let(:messages) { [{ "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] }] }

    before do
      allow(described_class).to(receive(:generate_system_prompt).with(["foo"], for_prompt_type: "foo").and_return("system-prompt"))
      allow(described_class).to(receive(:conversation_starters).with("foo").and_return(conversation_starters))
      allow(Prompts::Anthropic).to(receive(:messages)).and_return("result")
    end

    it "sends a payload with the messages" do
      result = described_class.messages(messages: messages, prompt_type: "foo", model: "modelo")
      expect(result).to(eq("result"))

      expect(Prompts::Anthropic).to(have_received(:messages).with({
        model: "modelo",
        system: "system-prompt",
        messages: [
          {
            "role" => "user",
            "content" => [
              { "type" => "text", "text" => "hello" },
              { "type" => "text", "text" => "there" },
            ],
          },
          { "role" => "assistant", "content" => [{ "type" => "text", "text" => "hi" }] },
          { "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] },
        ],
        stream: false,
      }))
    end
  end
end
