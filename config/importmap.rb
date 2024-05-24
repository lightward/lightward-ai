# frozen_string_literal: true

# config/importmap.rb
pin "application"
pin "@rails/actioncable", to: "actioncable.esm.js"

pin_all_from "app/javascript/src", under: "src", to: "src"
