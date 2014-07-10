

#########################################################
# generate code for "while" command (assumed to be first parse word)
# only braced arguments are generated, anything else generates an error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_while {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] == 1} {
        ::tsp::addError compUnit "while command must have two arguments"
        return [list void "" ""]
    }

    if {[llength $tree] != 3} {
        ::tsp::addError compUnit "while command has more than two argument"
        return [list void "" ""]
    }

    set exprComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $exprComponent type rawtext exprtext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "expr argument not a braced expression"
        return [list void "" ""]
    }

    set rc [catch {set exprTypeCode [::tsp::compileBooleanExpr compUnit $exprtext]} result]
    if {$rc != 0} {
        ::tsp::addError compUnit "couldn't parse expr: \"$exprtext\", $result"
        return [list void "" ""]
    }
    
    lassign $exprTypeCode type exprCode

    set bodyRange [lindex [lindex $tree 2] 1]
    set bodyCode [::tsp::parse_body compUnit $bodyRange]

    append code "while ( " $exprCode " ) {\n"
    ::tsp::incrIndent compUnit
    append code [::tsp::indent compUnit $bodyCode]
    ::tsp::incrIndent compUnit -1
    append code "}\n"
    return [list void "" $code]
}


