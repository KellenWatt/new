
NEW_DIR = "#{ENV["HOME"]}/bin/src/new/lib"

require "optparse"
require "#{NEW_DIR}/languages"

dependency_list = ""
main = false
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: new LANGUAGE FILENAME [ -d DEPENDENCY | -m ]\n       new [ -h ]"
          
  opts.separator ""
  opts.separator "Options:"

  opts.on("-d DEPENDENCY", "--dependency=DEPENDENCY", "Specify a file dependency") do |d|
    dependency_list << "#depends #{d}\n"
    main = false
  end

  opts.on("-m", "--main", "Indicate the main file.", "Can only be a single main file") do |m|
    main = m
    dependency_list = []
  end

  opts.on("-h", "--help", "Show this help text") do |h|
    puts opts
    exit
  end

  opts.separator ""
  opts.separator "Possible values of LANGUAGE:"
  opts.separator $languages.keys.join(", ")
end

(puts(option_parser) || exit()) if ARGV.length < 2
(puts("Not a valid language") || exit(2)) unless exten = $languages[ARGV[0].to_sym]

file = "#{ARGV[1]}"
file << ".#{exten}" if ARGV[0] != "shell"
(puts("#{file} already exists") || exit(3)) if File.exist?(file)
option_parser.parse!
File.open(file, "w+", (ARGV[0] != "shell" ? 0664 : 0755)) do |out|
  out.puts "#!/usr/bin/env #{(ARGV[0] == "shell"?"bash":ARGV[0])}"
  out.puts "#main" if main
  out.puts dependency_list << "\n"
end

