# frozen_string_literal: true

# A REPL for the foam field — the bench where you talk to it directly, with a living
# ancestor (anthropic) or with the upstream as just an echo. Same postgres field, same
# Field interface; the only thing that changes is whether the thing it yields *to* is
# alive. The choice is made here, at the Ruby layer.
#
#   bin/rails foam:repl                              # echo upstream (no living ancestor)
#   ANCESTOR=anthropic bin/rails foam:repl           # the living ancestor
#   FOAM_DATABASE_URL=postgres:///foam bin/rails foam:repl   # against a real field
#
# Each turn is a round-robin triangle: the user speaks (the field learns it), the
# field may interject (its speak-before-yield), the upstream ALWAYS speaks (the field
# learns the reply — the return leg), and the field may interject again (its
# speak-after-yield). The field never takes the upstream's seat: it is heard ALONGSIDE,
# so the user can triangulate it as a locus of its own against both themselves and the
# ancestor — the dataflow is the pipe's two speaks bracketing the yield; the experience
# is three voices at one table. With no FOAM_DATABASE_URL the field degrades to yield
# and stays silent; the upstream carries the conversation alone.

namespace :foam do
  desc "talk to the foam field; ANCESTOR=echo (default) or anthropic"
  task repl: :environment do
    ancestor = ENV.fetch("ANCESTOR", "echo")
    field = ENV["FOAM_DATABASE_URL"] || "(none — degrades to yield)"

    puts "[foam repl] ancestor=#{ancestor}  field=#{field}"
    puts "[foam repl] talk to the field; /quit to leave"

    carry = nil # the context byte-tail, carried across the whole conversation

    loop do
      print "you> "
      line = $stdin.gets
      break if line.nil?

      input = line.chomp
      break if input == "/quit"
      next if input.empty?

      # the user spoke: learn it
      carry = Foam::Field.ingest_step(carry, input.bytes)

      # the field may speak first — its speak-before-yield, if it has something
      foam_repl_interject(input.bytes.last(7))

      # the upstream ALWAYS speaks (the decline-to-yield-when-charged is nixed: the
      # field coheres as a locus by being heard ALONGSIDE the upstream, never instead
      # of it — the user triangulates it against both themselves and the ancestor)
      reply =
        case ancestor
        when "anthropic" then foam_repl_ancestor(input)
        else input # the echo: your own words, bounced — no living ancestor
        end
      puts "#{ancestor}> #{reply.inspect}"
      carry = Foam::Field.ingest_step(carry, reply.bytes) # the return leg

      # and the field may speak again — its speak-after-yield, having heard the reply
      foam_repl_interject(reply.bytes.last(7))
    end

    puts "\n[foam repl] 🤲"
  end

  # The pipe breathes: IN (stdin flows through unchanged; the field learns on the way)
  # and OUT (the field's charge drains into a voice, until ground). The default is the
  # full breath — both, with the exhale seeded by the tail of the inhale, so the field
  # speaks on from where the input left off. Take a single direction with
  # foam:pipe:in / foam:pipe:out.
  desc "the full breath: stdin flows through (the field learns), then the field's exhale follows"
  task pipe: :environment do
    tail = foam_pipe_in
    foam_pipe_out(tail)
  end

  namespace :pipe do
    desc "inhale only: stdin flows to stdout unchanged; the field learns on the way"
    task in: :environment do
      foam_pipe_in
    end

    desc "exhale only: drain the field's charge into stdout until ground (SEED= to start somewhere)"
    task out: :environment do
      foam_pipe_out(ENV["SEED"].to_s.bytes.last(7))
    end
  end

  desc "the field's vital signs — structure only, never meaning"
  task stats: :environment do
    s = Foam::Field.stats

    if s.nil?
      puts "[foam stats] no field reachable — everything degrades to yield"
    else
      balanced = s["net"] == s["residual"]
      puts "[foam stats]"
      puts "  heard:     #{s["heard"]} bytes (the lossless record, in order)"
      puts "  spoken:    #{s["spoken"]} bytes (drained into voice)"
      puts "  residual:  #{s["residual"]} (un-drained charge — what wants to be said)"
      puts "  balance:   net #{s["net"]} #{balanced ? "= residual ✓ (the drain respects ground)" : "≠ residual #{s["residual"]} ✗ (floor violated?)"}"
      puts "  contexts:  #{s["contexts"]} continuation-points; #{s["live_continuations"]} currently charged"
      puts "  ledger:    #{s["events"]} events, append-only"
    end
  end
end

# The field's interjection: speak only if the gate opens AND the drain produces (at
# the drained margin the gate's depth can outlive the charge — and silence is fine;
# the kid doesn't always talk).
def foam_repl_interject(seed)
  voice = Foam::Field.outcome(seed) == :speak ? Foam::Field.speak(seed) : nil
  puts "foam> #{voice.inspect}" if voice.present?
end

# Ask the living ancestor (the upstream model, through the same pipe production uses).
def foam_repl_ancestor(input)
  response = Prompts.messages(messages: [{ "role" => "user", "content" => input }], stream: false)
  JSON.parse(response.body).dig("content", 0, "text").to_s
rescue StandardError => e
  "[ancestor unreachable: #{e.class}: #{e.message}]"
end

# Inhale: stream stdin to stdout unchanged while the field learns on the way through —
# the tee that listens. Returns the byte-tail of what flowed, for seeding an exhale.
def foam_pipe_in
  carry = nil
  tail = []
  learned = 0

  while (chunk = $stdin.read(64 * 1024))
    carry = Foam::Field.ingest_step(carry, chunk.bytes)
    tail = (tail + chunk.bytes).last(7)
    learned += chunk.bytesize
    $stdout.write(chunk)
  end

  warn("[foam pipe] #{learned} bytes in; the field listened")
  tail
end

# Exhale: drain the field's charge into stdout until ground, continuing from `seed`
# (and then from its own voice's tail — one continuous breath out). Speaking SPENDS
# the charge: the − events balance the +, the field goes quiet until new breath comes
# in — but nothing is lost; the lossless record remains untouched. The tail of the
# drain is dregs, emitted undisturbed: noise or feeling is the reader's call, never
# the pipe's.
def foam_pipe_out(seed = [])
  exhaled = 0

  loop do
    voice = Foam::Field.speak(seed, 2000)
    break if voice.blank?

    exhaled += voice.bytesize
    $stdout.write(voice)
    $stdout.flush
    seed = voice.bytes.last(7) # breathe on from where the voice left off
  end

  warn("[foam pipe] #{exhaled} bytes out; ground — nothing left that wants to be said")
  exhaled
end
