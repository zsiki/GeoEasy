#
# Copyright (C) 2017 Zoltan Siki siki1958 (at) gmail (dot) com
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#	Convert XML to list
#	@param xml input xml data
proc xml2list xml {
# skip <? xml ... ?> and <!DOCTYPE >
	regsub {^[ \n\r\t]*<\?xml .*\?>[ \t\n\r]*<!DOCTYPE +gama-.* +SYSTEM \"gama-.*\.dtd\">} $xml "" xml
# remove everything before <gama-local-adjustment ...
regsub {^.*<gama-local-adjustment } $xml "<gama-local-adjustment " xml
# remove all html like comment start and end tag <!-- ... -->
	regsub -all -- {<!--} $xml "" xml
	regsub -all -- {-->} $xml "" xml

     regsub -all {>\s*<} [string trim $xml " \n\t<>"] "\} \{" xml
     set xml [string map {> "\} \{#text \{" < "\}\} \{"}  $xml]
     set res ""   ;# string to collect the result
     set stack {} ;# track open tags
     set rest {}
     foreach item "{$xml}" {
         switch -regexp -- $item {
            ^# {append res "{[lrange $item 0 end]} " ; #text item}
            ^/ {
                regexp {/(.+)} $item -> tagname ;# end tag
				set tagname [string trim $tagname]
                set expected [lindex $stack end]
                if {$tagname!=$expected} {error "$item != $expected"}
                set stack [lrange $stack 0 end-1]
                append res "\}\} "
          }
            /$ { # singleton - start and end in one <> group
               regexp {([^ ]+)( (.+))?/$} $item -> tagname - rest
               set rest [lrange [string map {= " "} $rest] 0 end]
               append res "{$tagname [list $rest] {}} "
            }
            default {
               set tagname [lindex $item 0] ;# start tag
               set rest [lrange [string map {= " "} $item] 1 end]
               lappend stack $tagname
               append res "\{$tagname [list $rest] \{"
            }
         }
         if {[llength $rest]%2} {error "att's not paired: $rest"}
     }
     if {[llength $stack]} {error "unresolved: $stack"}
     string map {"\} \}" "\}\}"} [lindex $res 0]
}

# Now that this went so well, I'll throw in the converse:

#
#	Convert list to XML
#	@param list
proc list2xml {list} {
    switch -- [llength $list] {
        2 {lindex $list 1}
        3 {
            foreach {tag attributes children} $list break
            set res <$tag
            foreach {name value} $attributes {
                append res " $name=\"$value\""
            }
            if {[llength $children]} {
                append res >
                foreach child $children {
                    append res [list2xml $child]
                }
                append res </$tag>
            } else {append res />}
        }
        default {error "could not parse $list"}
    }
}
