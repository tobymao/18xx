#!/usr/bin/ruby

if ARGV.size != 2
    puts "Usage: #{$PROGRAM_NAME} <infile> <outfile>"
    return
end

fin = File.open(ARGV[0], 'r')
fout = File.open(ARGV[1], 'w')

while str = fin.gets do
   fout.puts str
   if md = /(.*)logo: '(.*)',/.match(str)
      fout.puts "#{md[1]}simple_logo: '#{md[2]}.alt',"
   end
end
