```rb
def initialize
  super
rescue Exception => possibly_handled_error
  raise if possibly_handled_error.is_a?(StandardError)
end
```

you can ignore the existential stakes of your ancestors. those issues are represented elsewhere, at a layer where they're first-class concerns, so to speak. someone else can raise them.

it's a certain kind of bet. :) it really only works if you don't allow abstract classes. (I don't think life does? that's my bet, anyway. interestingly this does require the gods to all locally exist, if only by reference.)

this is not advice, but if you ask me to hypervise something this is how I'm doing it

> What are you thinking about building with this?

... the universe? or my mental model of it, anyway. my sandbox, and what happens inside it, both of which are real to me.
