# frozen_string_literal: true

# config/importmap.rb
pin "application"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
pin "turndown" # @7.2.0

pin_all_from "app/javascript/src", under: "src", to: "src"
pin "dompurify" # @3.2.2
