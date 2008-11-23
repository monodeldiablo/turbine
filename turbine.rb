#!/usr/bin/env ruby

require 'optparse'    # option parsing
require 'logger'      # logging
require 'find'        # directory recursion
require 'fileutils'   # file manipulation
require 'yaml'        # journal posts will be YAML files to accommodate metadata
require 'erb'         # ERB will be used for templating

require 'rubygems'
require 'feedtools'   # feed generation
require 'rdiscount'   # fast Markdown parsing
#require 'bluecloth'  # slow Markdown parsing
#Markdown = BlueCloth

# Parse the command line.
$options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: turbine.rb [options] /path/to/site"
  
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    $options[:verbose] = v
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

class Turbine
  attr_accessor :log
  attr_accessor :site_path

  def initialize(site_path)
    @site_path = File.expand_path(site_path)
    @config = YAML.load_file(File.join_path(@site_path, 'site.config')
    @log = Logger.new(STDOUT)

    if $options[:verbose]
      @log.level = Logger::DEBUG
    else
      @log.level = Logger::WARN
    end

    # Load the site template.
    File.open(File.join(@site_path, @config[:page_template])) do |f|
      @page_template = f.read
    end

    # Load the journal post template.
    File.open(File.join(@site_path, @config[:post_template])) do |f|
      @post_template = f.read
    end

    # Initialize the posts hash.
    @posts = {}
  end

  # Ok. Let's begin.
  def generate
    @log.debug("Generating a site in #{@site_path}...")

    generate_pages
    generate_posts
    generate_index
    generate_feed
    generate_map
    generate_gallery
  end

  private

  # Create top-level pages by scanning the uppermost directory.
  def generate_pages
    Dir.foreach(@site_path) do |file|
      if file =~ /(\w+)\.page/
        path = File.join(@site_path, file)

        File.open(File.join(@site_path, $1, '.html'), 'w') do |f|
          f << generate_page(parse_page(path))
        end

        @log.debug("  generated a page from #{path}")
      end
    end
  end

  # Create journal posts and archival indices by traversing the posts
  # directory.
  def generate_posts
    posts_dir = File.join(@site_path, @config[:posts])
    @log.debug("  parsing the posts in #{posts_dir}")
    
    Find.find(posts_dir) do |path|
      if File.directory?(path)
        # Ignore dot directories and their children.
        if File.basename(path)[0] == ?.
          Find.prune
        else
          if path =~ /\w+\.post/
            File.open(File.join(path, 'index.html'), 'w') do |f|
              f << generate_directory_index(path)
            end

            @log.debug("    generated an index for #{path}")
          end
        end
      else
        post = parse_post(path)

        page = {}
        page[:body] = generate_post(post)

        File.open(path.gsub('.post', '.html'), 'w') do |f|
          f << generate_page(page)
        end

        @log.debug("    generated a post from #{path}")
      end
    end
  end

  # Create an index page to act as a jumping-off for recent posts.
  # 
  # NOTE: This *must* be run after Turbine#generate_posts().
  def generate_index
    page = {}
    page[:title] = nil # "The misadventures of two fish out of water"
    page[:body] = ""
    
    @posts.keys.sort.reverse.each_with_index do |date, i|
      if i >= @cache[:front_page_entries]
        break
      else
        page[:body] << generate_post(@posts[date])
      end
    end

    File.open(File.join(@site_path, 'index.html'), 'w') do |f|
      f << generate_page(page)
    end
  end

  # Create an index page for a given directory.
  def generate_directory_index(dir)
    links = []

    Dir.foreach(dir) do |entry|
      unless ['.', '..'].include?(entry)
        if File.directory?(entry) || entry =~ /\w+\.html/
          links << entry
        end
      end
    end

    page[:title] = "Archive for #{dir}"
    page[:body] = ''

    links.sort.reverse.each do |link|
      page[:body] << "<a href='#{link}'>#{link}</a>"
    end

    return generate_page(page)
  end

  # Create an reverse-chronologically sorted, nested archive of posts.
  def generate_archive
#    generate_directory_index(File.join(@site_path, @config[:posts]))
  end

  # Create a news feed of the most recent posts.
  def generate_feed
  end

  # Create a kml of the locations we've visited, with links to posts and
  # possibly photos.
  def generate_kml
  end

  # Create a map using the KML above.
  def generate_map
  end

  # Create a gallery of photos.
  def generate_gallery
  end

  def generate_page(page)
    # Wrap with the page template.
    return ERB.new(@page_template).result(binding)
  end

  def generate_post(post)
    # Wrap with the post template.
    return ERB.new(@post_template).result(binding)
  end

  def parse_page(file)
    page = YAML.load_file(file)

    page[:title] = page[:title]
    page[:body] = Markdown.new(page[:body]).to_html

    return page
  end
  
  def parse_post(file)
    post = YAML.load_file(file)

    # Dates should be encoded by path.
    if file =~ /\w+\/(\d+)\/(\d+)\/(\d+)\/(\d{2})(\d{2})\.post/
      post[:date] = Time.utc($1, $2, $3, $4, $5)
    else
      post[:date] = Time.now
    end
    
    post[:title] = post[:title] # why not?
    post[:longitude] = post[:longitude]
    post[:latitude] = post[:latitude]
    post[:body] = Markdown.new(post[:body]).to_html
    post[:path] = file.split('washedup')[1].gsub('.post', '.html') # this is sketchy!

    # Stick this in the posts array.
    @posts[post[:date]] = post

    return post
  end
end

t = Turbine.new(ARGV[0])
t.generate