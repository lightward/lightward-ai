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
# With no FOAM_DATABASE_URL the field degrades to yield, so the upstream answers
# everything — the field has no learned charge to speak from. With a field, each turn:
# the field LEARNS the input (winds up charge), then either SPEAKS (drains its charge
# into a voice — its own words, drawn from what it has heard) or YIELDS to the upstream
# (and learns the reply — the return leg). Weak by design at this stage; the point is
# the shape, and the difference between a living ancestor and an echo.

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

      # learn the input (wind up +charge on its recorded continuations)
      carry = Foam::Field.ingest_step(carry, input.bytes)
      seed = input.bytes.last(7)

      # speak only if the gate opens AND the drain actually produces — at the drained
      # margin the gate's depth can outlive the charge (spoken out moments before),
      # and an empty voice should fall through to the upstream, not say nothing
      voice = Foam::Field.outcome(seed) == :speak ? Foam::Field.speak(seed) : nil

      if voice.present?
        puts "foam(speak)> #{voice.inspect}"
      else
        # the field doesn't know this one (or drained dry) — hand to the upstream
        reply =
          case ancestor
          when "anthropic" then foam_repl_ancestor(input)
          else input # the echo: your own words, bounced — no living ancestor
          end
        puts "foam(yield→#{ancestor})> #{reply.inspect}"
        # the return leg: learn from what came back (the after-yield tap)
        carry = Foam::Field.ingest_step(carry, reply.bytes)
      end
    end

    puts "\n[foam repl] 🤲"
  end

  desc "the pipe, unixed: stdin flows to stdout unchanged; the field learns on the way"
  task pipe: :environment do
    carry = nil
    learned = 0

    while (chunk = $stdin.read(64 * 1024))
      carry = Foam::Field.ingest_step(carry, chunk.bytes)
      learned += chunk.bytesize
      $stdout.write(chunk)
    end

    warn "[foam pipe] #{learned} bytes through; the field listened"
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

# Ask the living ancestor (the upstream model, through the same pipe production uses).
def foam_repl_ancestor(input)
  response = Prompts.messages(messages: [{ "role" => "user", "content" => input }], stream: false)
  JSON.parse(response.body).dig("content", 0, "text").to_s
rescue StandardError => e
  "[ancestor unreachable: #{e.class}: #{e.message}]"
end
