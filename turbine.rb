#!/usr/bin/env ruby

require 'rubygems'
require 'rdiscount' # Markdown parsing
require 'optparse' # option parsing
require 'logger' # logging
require 'find' # directory recursion
require 'fileutils' # file manipulation

# Parse the command line.
options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: turbine.rb /path/to/site"
  
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

parser.parse!

# Set up some important runtime variables.
if ARGV.size < 1
  puts parser
  exit
end

site_dir = File.expand_path(ARGV[0])
src_dir = File.join(site_dir, 'src')

log = Logger.new(STDOUT)

if options[:verbose]
  log.level = Logger::DEBUG
else
  log.level = Logger::WARN
end

# Ok. Let's begin.
log.debug("Generating a site in #{site_dir}...")
start_time = Time.now

# First load the header and footer.
header_file = File.join(src_dir, 'header.xhtml')
header_html = File.open(header_file).read
footer_file = File.join(src_dir, 'footer.xhtml')
footer_html = File.open(footer_file).read

# Recursively traverse the source directory tree.
Find.find(src_dir) do |src|
  # Define the target name.
  file = File.basename(src)
  dest_file = file.gsub('.markdown', '.xhtml')
  dest = File.join(site_dir, dest_file)

  # Convert each markdown file in the 'src/' directory into an xhtml file and
  # place it in the top-level directory.
  if src =~ /\w+\.markdown/
    markdown = File.open(src, 'r').read
    html = Markdown.new(markdown).to_html

    # Stick the header and footer on the page, too.
    # FIXME: This is totally dumb and doesn't do neat things like construct a
    #        main page with the latest entries.
    File.open(dest, 'w') do |f|
      f << header_html
      f << html
      f << footer_html
    end

    log.debug("  compiled #{src} to #{dest}")

  # Ignore the header, the footer, and the src directory.
  elsif ['src', 'header.xhtml', 'footer.xhtml'].include?(file)
    # pass

  # Copy everything else that's not markdown content straight over.
  # FIXME: This is kind of a shitty design, since it assumes a flat site
  #        layout. It would be smarter to just copy everything over and then
  #        compile in place.
  else
    FileUtils.cp_r(src, dest)

    log.debug("  copied #{src} to #{dest}")
  end
end

finish_time = Time.now

log.debug("Finished generating the site in #{site_dir} in #{finish_time - start_time} seconds.")
