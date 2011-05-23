#!/usr/bin/env ruby
#

## http://blog.neontology.com/articles/2006/05/10/beautiful-ruby-in-textmate
## http://www.arachnoid.com/ruby/rubyBeautifier.html
##
## Ruby beautifier, version 1.3, 04/03/2006
## Copyright (c) 2006, P. Lutus
## TextMate modifications by T. Burks
## Vim modifications by Luis Mondesi
## Released under the GPL
#
#$tabSize = 2
#$tabStr = " "
#
## indent regexp tests
#
#$indentExp = [
#   /^module\b/,
#   /(=\s*|^)if\b/,
#   /(=\s*|^)until\b/,
#   /(=\s*|^)for\b/,
#   /(=\s*|^)unless\b/,
#   /(=\s*|^)while\b/,
#   /(=\s*|^)begin\b/,
#   /(=\s*|^)case\b/,
#   /\bthen\b/,
#   /^class\b/,
#   /^rescue\b/,
#   /^def\b/,
#   /\bdo\b/,
#   /^else\b/,
#   /^elsif\b/,
#   /^ensure\b/,
#   /\bwhen\b/,
#   /\{[^\}]*$/,
#   /\[[^\]]*$/
#]
#
## outdent regexp tests
#
#$outdentExp = [
#   /^rescue\b/,
#   /^ensure\b/,
#   /^elsif\b/,
#   /^end\b/,
#   /^else\b/,
#   /\bwhen\b/,
#   /^[^\{]*\}/,
#   /^[^\[]*\]/
#]
#
#def makeTab(tab)
#   return (tab < 0)?"":$tabStr * $tabSize * tab
#end
#
#def addLine(line,tab)
#   line.strip!
#   line = makeTab(tab)+line if line.length > 0
#   return line + "\n"
#end
#
#def beautifyRuby
#   commentBlock = false
#   multiLineArray = Array.new
#   multiLineStr = ""
#   tab = 0
#   source = STDIN.read
#   dest = ""
#   source.split("\n").each do |line|
#      # combine continuing lines
#      if(!(line =~ /^\s*#/) && line =~ /[^\\]\\\s*$/)
#         multiLineArray.push line
#         multiLineStr += line.sub(/^(.*)\\\s*$/,"\\1")
#         next
#      end
#
#      # add final line
#      if(multiLineStr.length > 0)
#         multiLineArray.push line
#         multiLineStr += line.sub(/^(.*)\\\s*$/,"\\1")
#      end
#
#      tline = ((multiLineStr.length > 0)?multiLineStr:line).strip
#      if(tline =~ /^=begin/)
#         commentBlock = true
#      end
#      if(commentBlock)
#         # add the line unchanged
#         dest += line + "\n"
#      else
#         commentLine = (tline =~ /^#/)
#         if(!commentLine)
#            # throw out sequences that will
#            # only sow confusion
#            tline.gsub!(/\/.*?\//,"")
#            tline.gsub!(/%r\{.*?\}/,"")
#            tline.gsub!(/%r(.).*?\1/,"")
#            tline.gsub!(/\\\"/,"'")
#            tline.gsub!(/".*?"/,"\"\"")
#            tline.gsub!(/'.*?'/,"''")
#            tline.gsub!(/#\{.*?\}/,"")
#            $outdentExp.each do |re|
#               if(tline =~ re)
#                  tab -= 1
#                  break
#               end
#            end
#         end
#         if (multiLineArray.length > 0)
#            multiLineArray.each do |ml|
#               dest += addLine(ml,tab)
#            end
#            multiLineArray.clear
#            multiLineStr = ""
#         else
#            dest += addLine(line,tab)
#         end
#         if(!commentLine)
#            $indentExp.each do |re|
#               if(tline =~ re && !(tline =~ /\s+end\s*$/))
#                  tab += 1
#                  break
#               end
#            end
#         end
#      end
#      if(tline =~ /^=end/)
#         commentBlock = false
#      end
#   end
#   STDOUT.write(dest)
#   # uncomment this to complain about mismatched blocks
#   #if(tab != 0)
#   #  STDERR.puts "Indentation error: #{tab}"
#   #end 
#end
#
#beautifyRuby 
#
PVERSION = "Version 2.9, 10/24/2008"

module RBeautify

   # user-customizable values

   RBeautify::TabStr = " "
   RBeautify::TabSize = 2

   # indent regexp tests

   IndentExp = [
      /^module\b/,
      /^class\b/,
      /^if\b/,
      /(=\s*|^)until\b/,
      /(=\s*|^)for\b/,
      /^unless\b/,
      /(=\s*|^)while\b/,
      /(=\s*|^)begin\b/,
      /(^| )case\b/,
      /\bthen\b/,
      /^rescue\b/,
      /^def\b/,
      /\bdo\b/,
      /^else\b/,
      /^elsif\b/,
      /^ensure\b/,
      /\bwhen\b/,
      /\{[^\}]*$/,
      /\([^\)]*$/,
      /\[[^\]]*$/
   ]

   # outdent regexp tests

   OutdentExp = [
      /^rescue\b/,
      /^ensure\b/,
      /^elsif\b/,
      /^end\b/,
      /^else\b/,
      /\bwhen\b/,
      /^[^\{]*\}/,
      /^[^\(]*\)/,
      /^[^\[]*\]/
   ]

   def RBeautify.rb_make_tab(tab)
      return (tab < 0)?"":TabStr * TabSize * tab
   end

   def RBeautify.rb_add_line(line,tab)
      line.strip!
      line = rb_make_tab(tab) + line if line.length > 0
      return line
   end

   def RBeautify.beautify_string(source, path = "")
      comment_block = false
      in_here_doc = false
      here_doc_term = ""
      program_end = false
      multiLine_array = []
      multiLine_str = ""
      tab = 0
      output = []
      source.each do |line|
         line.chomp!
         if(!program_end)
            # detect program end mark
            if(line =~ /^__END__$/)
               program_end = true
            else
               # combine continuing lines
               if(!(line =~ /^\s*#/) && line =~ /[^\\]\\\s*$/)
                  multiLine_array.push line
                  multiLine_str += line.sub(/^(.*)\\\s*$/,"\\1")
                  next
               end

               # add final line
               if(multiLine_str.length > 0)
                  multiLine_array.push line
                  multiLine_str += line.sub(/^(.*)\\\s*$/,"\\1")
               end

               tline = ((multiLine_str.length > 0)?multiLine_str:line).strip
               if(tline =~ /^=begin/)
                  comment_block = true
               end
               if(in_here_doc)
                  in_here_doc = false if tline =~ %r{\s*#{here_doc_term}\s*}
               else # not in here_doc
                  if tline =~ %r{=\s*<<}
                     here_doc_term = tline.sub(%r{.*=\s*<<-?\s*([_|\w]+).*},"\\1")
                     in_here_doc = here_doc_term.size > 0
                  end
               end
            end
         end
         if(comment_block || program_end || in_here_doc)
            # add the line unchanged
            output << line
         else
            comment_line = (tline =~ /^#/)
            if(!comment_line)
               # throw out sequences that will
               # only sow confusion
               while tline.gsub!(/\{[^\{]*?\}/,"")
               end
               while tline.gsub!(/\[[^\[]*?\]/,"")
               end
               while tline.gsub!(/'.*?'/,"")
               end
               while tline.gsub!(/".*?"/,"")
               end
               while tline.gsub!(/\`.*?\`/,"")
               end
               while tline.gsub!(/\([^\(]*?\)/,"")
               end
               while tline.gsub!(/\/.*?\//,"")
               end
               while tline.gsub!(/%r(.).*?\1/,"")
               end
               # delete end-of-line comments
               tline.sub!(/#[^\"]+$/,"")
               # convert quotes
               tline.gsub!(/\\\"/,"'")
               OutdentExp.each do |re|
                  if(tline =~ re)
                     tab -= 1
                     break
                  end
               end
            end
            if (multiLine_array.length > 0)
               multiLine_array.each do |ml|
                  output << rb_add_line(ml,tab)
               end
               multiLine_array.clear
               multiLine_str = ""
            else
               output << rb_add_line(line,tab)
            end
            if(!comment_line)
               IndentExp.each do |re|
                  if(tline =~ re && !(tline =~ /\s+end\s*$/))
                     tab += 1
                     break
                  end
               end
            end
         end
         if(tline =~ /^=end/)
            comment_block = false
         end
      end
      error = (tab != 0)
      STDERR.puts "Error: indent/outdent mismatch: #{tab}." if error
      return output.join("\n") + "\n",error
   end # beautify_string

   def RBeautify.beautify_file(path)
      error = false
      if(path == '-') # stdin source
         source = STDIN.read
         source = source.split("\n")  unless source.is_a? Array
         dest,error = beautify_string(source,"stdin")
         print dest
      else # named file source
         source = File.read(path)
         dest,error = beautify_string(source,path)
         if(source != dest)
            # make a backup copy
            File.open(path + "~","w") { |f| f.write(source) }
            # overwrite the original
            File.open(path,"w") { |f| f.write(dest) }
         end
      end
      return error
   end # beautify_file

   def RBeautify.main(*args)
      error = false
      args ||= ARGV
      if(!args[0])
         STDERR.puts "usage: Ruby filenames or \"-\" for stdin."
         exit 0
      end
      args.each do |path|
         error = (beautify_file(path))?true:error
      end
      error = (error)?1:0
      exit error
   end # main
end # module RBeautify

RBeautify.main '-'



