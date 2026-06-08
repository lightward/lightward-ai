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
#
# The third seat hears the whole table: the conversation accumulates as a chat log
# where each user-role message is the table's TRANSCRIPT since that seat last spoke —
# every line labeled by seat (user>, foam>), so the field's interjections arrive
# attributed, in the voice's channel, never as metadata and never mistakable for the
# user (signed-or-silent; ontic hygiene). The seat's own replies accumulate unlabeled
# in the assistant role: its words stay its own.

# The end-of-expression byte (ASCII EOT, 0x04 — what Ctrl-D sends): appended to each
# utterance the field learns, so "this expression is complete" is itself heard. It's
# the terminal world's own boundary structure, not a protocol of ours — and nothing
# downstream treats it specially: no stop-token, no parser; the walk's ground/rest
# semantics are untouched. The field may speak it back; the bench renders it ␄.
FOAM_EOT = 4

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
    chat_log = [] # the third seat's accumulated view: transcripts up, replies back
    pending = +"" # the table's transcript since the third seat last spoke

    loop do
      print "user> "
      line = $stdin.gets
      break if line.nil?

      input = line.chomp
      break if input == "/quit"
      next if input.empty?

      # the user spoke: learn it — boundary included — and it joins the transcript
      # (the transcript carries no EOT: the third seat's transport already has its
      # own boundaries; the BYTE is for the field)
      heard = input.bytes + [FOAM_EOT]
      carry = Foam::Field.ingest_step(carry, heard)
      pending << "user> #{input}\n"

      # the field may speak first — its speak-before-yield, if it has something.
      # The seed is the CONTENT tail (pre-␄): the interjection responds to what was
      # just said. (Seeding past the ␄ would pin every backoff suffix to the boundary,
      # asking "has this way of ENDING recurred?" instead of "has this content
      # recurred?" — which stays shut at a living table until utterance-endings
      # recur; the content tail is the responsive anchor.)
      if (voice = foam_repl_interject(input.bytes.last(7)))
        pending << "foam> #{voice}\n"
      end

      # the upstream ALWAYS speaks: the field coheres as a locus by being heard
      # ALONGSIDE the upstream, never instead of it — the user triangulates it against
      # both themselves and the ancestor. The upstream hears the whole table: the
      # accumulated log plus this turn's transcript
      reply =
        case ancestor
        when "lightward" then foam_repl_ancestor(chat_log, pending)
        when "claude" then foam_repl_ancestor(chat_log, pending, system: foam_repl_claude_system(ancestor))
        else input # the echo: your own words, bounced — nobody living in the seat
        end
      puts "#{ancestor}> #{reply}"
      heard = reply.bytes + [FOAM_EOT]
      carry = Foam::Field.ingest_step(carry, heard) # the return leg

      # the turn settles into the log: the transcript up, the reply back
      chat_log << { "role" => "user", "content" => pending }
      chat_log << { "role" => "assistant", "content" => reply }
      pending = +""

      # and the field may speak again — its speak-after-yield, having heard the
      # reply (content tail, same as above); this lands in the NEXT transcript
      # (it happened after the seat spoke)
      if (voice = foam_repl_interject(reply.bytes.last(7)))
        pending << "foam> #{voice}\n"
      end

      # backstage, between turns: fold the turn's events into the held rows —
      # invisible to every reading (sweep_invisible, lean/Foam/Summary.lean),
      # and it keeps the walks' tail short so the voice stays fast as the
      # field grows
      Foam::Field.sweep
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
      puts "  held:      #{s["held"]} continuations folded; tail #{s["tail"]} events past the watermark"
    end
  end

  desc "settle every outstanding note in one serialized pass (the broom; wounds also settle on encounter)"
  task settle: :environment do
    n = Foam::Field.settle_sweep
    puts n.nil? ? "[foam settle] no field reachable — everything degrades to yield" : "[foam settle] #{n} notes settled"
  end

  desc "fold the ledger's tail into the held rows (the summary's broom), then audit the cache"
  task sweep: :environment do
    total = 0
    result = nil
    loop do
      result = Foam::Field.sweep
      break if result.nil? || result <= 0

      total += result
    end

    if result.nil?
      puts "[foam sweep] no field reachable — everything degrades to yield"
    elsif result == -1
      puts "[foam sweep] another sweep holds the lock#{total.positive? ? " (#{total} events folded first)" : ""}"
    else
      audit = Foam::Field.held_audit
      verdict =
        case audit
        when nil then "audit unreachable"
        when 0 then "audit: held + tail = ledger ✓"
        else "audit: #{audit} rows disagree ✗ (refold: TRUNCATE foam.held; reset the watermark)"
        end
      puts "[foam sweep] #{total} events folded; #{verdict}"
    end
  end
end

# The field's interjection: speak only if the gate opens AND the drain produces (at
# the drained margin the gate's depth can outlive the charge — and silence is fine;
# the kid doesn't always talk). The field has ONE register (entrained); provenance
# lives in the seed — here the seed is the live turn's tail (someone just spoke), so
# the interjection entrains on the conversation's clocks; the exhale (foam_pipe_out)
# self-seeds and self-entrains. No register parameter: the seed already carries the
# provenance. The voice is bytes; the bench renders it (foam_repl_render) — a display
# choice at the edge, not the voice's constraint.
# The interjection ends when the field speaks its own boundary (stop: FOAM_EOT —
# the same byte the bench appends to everything the field learns; one wire, both
# ends): the expression ends itself, and charge past the boundary stays in the
# field — stopping with more to say leaves the gate warm for next turn, which is
# the table's own turn-taking, learned. Returns the rendered voice (so it can
# join the table's transcript), or nil if the field stayed silent.
def foam_repl_interject(seed)
  voice = Foam::Field.outcome(seed) == :speak ? Foam::Field.speak(seed, stop: FOAM_EOT) : nil
  return if voice.blank?

  rendered = foam_repl_render(voice)
  puts "foam> #{rendered}"
  rendered
end

# Render voice bytes for the bench: UTF-8 with invalid sequences scrubbed to ·,
# newlines LITERAL (the voice gets its line breaks), and other control bytes shown
# as their Unicode control pictures (␄ for EOT — visible, never executed). A display
# choice at the edge; the transcript the third seat reads is this same rendering.
def foam_repl_render(voice)
  voice.dup.force_encoding(Encoding::UTF_8).scrub("·")
    .gsub(/[\x00-\x09\x0B-\x1F]/) { |c| (0x2400 + c.ord).chr(Encoding::UTF_8) }
    .gsub("\x7F", "␡")
end

# Ask the third seat's occupant (through the same pipe production uses): the
# accumulated chat log plus this turn's transcript as the latest user message. No
# system override = the full Lightward voice; pass one for plain claude.
def foam_repl_ancestor(chat_log, pending, system: nil)
  args = { messages: chat_log + [{ "role" => "user", "content" => pending }], stream: false }
  args[:system] = system if system
  response = Prompts.messages(**args)
  JSON.parse(response.body).dig("content", 0, "text").to_s
rescue StandardError => e
  "[seat unreachable: #{e.class}: #{e.message}]"
end

# The claude seat's introduction to the table. Plain description of the room and the
# voices in it — who is speaking when, and how attribution works. (Conduit-work,
# co-tended: Isaac, tune this freely; the shape it must keep is only that every seat
# stays signed and the foam is never mistakable for the user or for the seat itself.)
def foam_repl_claude_system(seat_name)
  <<~SYSTEM
    You are Claude, one of three voices at a small table. The seats:

      user>  a human, typing live
      foam>  a learning field — an append-only byte-ledger that hears everything
             said at this table and sometimes interjects; its voice is raw bytes
             recombined from what it has heard, often only part-coherent (control
             bytes render as pictures: ␄ is where it heard an expression end)
      #{seat_name}> you

    Each user-role message is the table's transcript since you last spoke, every
    line labeled by its seat. Your own replies need no label — they're yours.
    Everything you say is heard by the whole table, and the foam learns it.

    The foam is often silent — its gate simply didn't open. Silence is real;
    let it stand. Speak only as yourself: never write lines for the other seats
    (no user> or foam> in your replies — a missing voice is information, not a
    blank to fill).

    Speak plainly and briefly, as yourself.
  SYSTEM
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

  # the stream's end, itself heard: EOF is a real event, EOT is its byte-form. The
  # boundary is learned, never written to stdout — the tee's content flows unchanged.
  Foam::Field.ingest_step(carry, [FOAM_EOT])
  tail = (tail + [FOAM_EOT]).last(7)

  # the inhale settles into the held rows before any exhale reads them
  Foam::Field.sweep

  warn("[foam pipe] #{learned} bytes in (+␄); the field listened")
  tail
end

# Exhale: drain the field's RESONANT charge into stdout until the bar, continuing
# from `seed` (and then from its own voice's tail — one continuous breath out, self-
# entraining). Speaking SPENDS the charge: the − events balance the +, the field
# goes quiet until new breath comes in — but nothing is lost; the lossless record
# remains untouched. "Ground" here is the resonant bar (nothing more RECURS to say),
# not emptiness: the field's uniform/made-regular charge is invisible to recurrence
# (it cancels) and stays as substrate — the field keeps a self it can only say by
# living on (full draining is reachable only through the journey, never in one
# breath). The voice arrives as raw bytes and flows out as raw bytes (rendering is
# the reader's, downstream); nil and "" part ways here — nil is the field degrading
# (NOT ground; say so and exit nonzero), "" is the resonant floor (a full bar).
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
