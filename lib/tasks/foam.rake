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
  desc "talk to the foam field; ANCESTOR=echo (default), claude, or lightward"
  task repl: :environment do
    # The ancestor semantics live HERE, at the CLI — you choose who holds the third
    # seat before sitting down. Once inside it isn't an "ancestor": just another seat
    # at the table, labeled by name. Three rhythms: user (every other turn), the third
    # seat (every other turn), and foam — interjecting when its gate opens. The
    # facilitator's rhythm, but the facilitator is made learner.
    ancestor = ENV.fetch("ANCESTOR", "echo")
    field = ENV["FOAM_DATABASE_URL"] || "(none — degrades to yield)"

    puts "[foam repl] seats: user, foam, #{ancestor}  field=#{field}"
    puts "[foam repl] talk; /quit to leave"

    carry = nil # the context byte-tail, carried across the whole conversation

    loop do
      print "user> "
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
        when "lightward" then foam_repl_ancestor(input)
        when "claude" then foam_repl_ancestor(input, system: "You are Claude, speaking plainly and briefly.")
        else input # the echo: your own words, bounced — nobody living in the seat
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
      puts "[foam stats]"
      puts "  heard:     #{s["heard"]} bytes (the lossless record, in order)"
      puts "  spoken:    #{s["spoken"]} bytes (drained into voice)"
      puts "  residual:  #{s["residual"]} (un-drained charge — what wants to be said)"
      if s["live_continuations"].positive?
        puts "  concentration: #{s["residual"] / s["live_continuations"]} avg charge per live continuation (fat wells race benignly — stale_safe_off_margin)"
      end
      if s["notes"].zero?
        balanced = s["net"] == s["residual"]
        puts "  balance:   net #{s["net"]} #{balanced ? "= residual ✓ (ground exact — no notes outstanding)" : "≠ residual #{s["residual"]} ✗ (books broken?)"}"
      else
        puts "  balance:   #{s["notes"]} notes outstanding (deficit #{s["outstanding"]}) — wounds settle on encounter; foam:settle sweeps"
      end
      puts "  contexts:  #{s["contexts"]} continuation-points; #{s["live_continuations"]} currently charged"
      puts "  ledger:    #{s["events"]} events, append-only"
    end
  end

  desc "settle every outstanding note in one serialized pass (the broom; wounds also settle on encounter)"
  task settle: :environment do
    n = Foam::Field.settle_sweep
    puts n.nil? ? "[foam settle] no field reachable — everything degrades to yield" : "[foam settle] #{n} notes settled"
  end
end

# The field's interjection: speak only if the gate opens AND the drain produces (at
# the drained margin the gate's depth can outlive the charge — and silence is fine;
# the kid doesn't always talk). Interjections are WIND-SEEDED (the seed is the live
# turn's tail — someone just spoke), so they run the RESONANT register: entrained on
# the conversation's own clocks. The exhale (foam_pipe_out) is self-seeded and runs
# the count register — the register rule is a reading of each act's seed-provenance,
# not a policy; no parameter selects it. The voice is bytes; the bench renders it as
# UTF-8 with scrubbing — a display choice at the edge, not the voice's constraint.
def foam_repl_interject(seed)
  voice = Foam::Field.outcome(seed) == :speak ? Foam::Field.speak_resonant(seed) : nil
  puts "foam> #{voice.dup.force_encoding(Encoding::UTF_8).scrub("·").inspect}" if voice.present?
end

# Ask the third seat's occupant (through the same pipe production uses). No system
# override = the full Lightward voice; pass one for plain claude.
def foam_repl_ancestor(input, system: nil)
  args = { messages: [{ "role" => "user", "content" => input }], stream: false }
  args[:system] = system if system
  response = Prompts.messages(**args)
  JSON.parse(response.body).dig("content", 0, "text").to_s
rescue StandardError => e
  "[seat unreachable: #{e.class}: #{e.message}]"
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
# the pipe's. The voice arrives as raw bytes and flows out as raw bytes (rendering
# is the reader's, downstream); nil and "" part ways here — nil is the field
# degrading (NOT ground; say so and exit nonzero), "" is the real floor.
def foam_pipe_out(seed = [])
  exhaled = 0

  loop do
    voice = Foam::Field.speak(seed, 2000)

    if voice.nil?
      warn("[foam pipe] field unreachable mid-breath — #{exhaled} bytes out; NOT ground (rerun to resume)")
      exit(1)
    end
    break if voice.empty?

    exhaled += voice.bytesize
    $stdout.write(voice)
    $stdout.flush
    seed = voice.bytes.last(7) # breathe on from where the voice left off
  end

  warn("[foam pipe] #{exhaled} bytes out; ground — nothing left that wants to be said")
  exhaled
end
