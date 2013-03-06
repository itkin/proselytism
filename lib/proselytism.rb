
require "active_support/core_ext"

require "proselytism/version"
require "proselytism/shared"
require "proselytism/proselytism"
require "proselytism/converter"

require "proselytism/converters/open_office"
require "proselytism/converters/pdf_to_text"
require "proselytism/converters/pdf_images"
require "proselytism/converters/ppm_to_jpeg"


require "proselytism/engine" if defined? Rails