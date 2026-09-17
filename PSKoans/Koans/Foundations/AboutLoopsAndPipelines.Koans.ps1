using module PSKoans
[Koan(Position = 121)]
param()
<#
    The Pipeline & Loops

    A core tenet of PowerShell scripts is its pipeline. It's mainly just a fancy way
    of iterating over an array of items, so we'll also cover standard loops as well
    to give a comparison.

    Unlike standard loops, where altering the collection you're iterating through is
    considered  a terrible idea, so much so that many languages (including PowerShell)
    actually throw an error if you try, pipelines are designed to break apart a
    collection into its parts and operate on the pieces one at a time.

    As such, modifying the 'collection' mid-pipeline is very common. Pipelines are
    commonly used to take an array of input and perform multiple actions on each item
    before storing or outputting the result.
#>
Describe 'Pipelines and Loops' {

    Context 'The Pipeline' {

        It 'is used to process input in several stages' {
            # The .. operator is used to quickly create arrays with a range of numbers
            $Values = 1..5
            # Where-Object is a filtering cmdlet, used to discard selected objects mid-pipeline.
            $Values | Where-Object { $_ -lt 3 } | Should -Be @(1, 2)
        }

        It 'often uses $_ or $PSItem to indicate the current item in the pipeline' {
            <#
                The pipeline takes each element of the array and feeds them one by one
                into the next cmdlet.
            #>
            1..5 |
                ForEach-Object {
                    <#
                        ForEach-Object is a cmdlet that utilises the pipeline to create a
                        sort of loop, where each object that it receives from the pipeline
                        has the same set of actions performed on it.

                        In pipeline contexts, you will frequently see $_ or $PSItem variables
                        used. These are automatic variables used to denote 'the current
                        object in the pipeline'.
                    #>
                    $_ | Should -Be $PSItem
                    <#
                        Expressions not stored in a variable are dropped back to the output
                        stream. In pipelines, this means that they are passed along to the
                        next pipeline command. If a pipeline ends and it is not stored in a
                        variable, all output will eventually end up in the main output stream.

                        In the console, this will be displayed on screen.
                    #>
                    $_ + 2
                } |
                Should -Be __ # What happens to the array after we change each value?
        }

        It 'can store output after processing it through multiple cmdlets' {
            <#
                Values can be stored at the end of a pipeline by storing the entire
                pipeline sequence in a variable. This will create an array of the final
                values.
            #>
            $Strings = 3..7 |
                ForEach-Object { "Hello $_!" } | # Line breaks after a pipe character are OK!
                Where-Object { $_ -notlike '*5*' } # (Indents are optional.)
            __ | Should -Be $Strings
        }

        It 'can reference previous values from each pipeline segment with -PipelineVariable' {
            <#
                -PipelineVariable is a common parameter available to all cmdlets and advanced
                functions. It takes a single string value, which becomes an extra variable in
                the pipeline, similar to $PSItem or $_.

                However, rather than referencing the "current" item in the pipeline at that
                stage, it instead refers to the "current" item that is output from that
                specific pipeline step, allowing a pipeline to self-reference a value from
                earlier in the sequence.
            #>

            1..5 |
                Write-Output -PipelineVariable InitialValue |
                ForEach-Object { $_ * 2 } |
                ForEach-Object { "Initial: $InitialValue, Current: $_" } |
                Should -Be @(
                    "Initial: 1, Current: 2"
                    "Initial: __, Current: 4"
                    "Initial: 3, Current: __"
                    "Initial: __, Current: __"
                    "Initial: __, Current: __"
                )
        }
    }

    Context 'Loop Statements' {

        It 'can loop over a collection of items' {
            <#
                Standard loops are also available in PowerShell, but unlike most other languages we
                can still utilise PowerShell's output stream to bundle all their output by assigning
                the loop statement to a variable.
            #>
            $Values = foreach ($Number in 1..5) {
                <#
                    In these kinds of loops, the specified variable name ($Number in this case)
                    takes the place of the $_ or $PSItem automatic variables instead.
                #>
                $Number
            }
            __ | Should -Be $Values
        }

        It 'can loop a set number of times' {
            $Values = for ($num = 0; $num -lt 5; $num++) {
                <#
                    For loops are quite rare in native PowerShell code. They have their uses, but are
                    frequently too semantically obscure to have a place in PS's verbose ecosystem.
                #>
                $num
            }

            # What will the above loop store in $Values?
            $Values | Should -Be @(
                __
                __
                __
                __
                __
            )
        }

        It 'can loop while a condition is $true' {
            $Values = while ($true) {
                <#
                    Watch out for infinite loops!

                    Remember: an undeclared variable acts as zero until we increment it!
                    Incrementing a variable won't output the value
                    unless the expression is wrapped in parentheses.
                #>
                (++$Tick)

                <#
                    An alternative would be the following:
                    $returnvalue = ++$Tick
                    $returnvalue
                    Perhaps slightly more clear but more verbose
                #>

                if ($Tick -gt 2) {
                    break # the break statement breaks out of the current loop.
                }
            }
            __ | Should -Be $Values
        }

        It 'can loop one or more times depending on the conditional statement' {
            <#
                Do..While loops are just like their standard counterparts, but will always
                execute the loop at least once:
                    do { Do-Things } while ($condition -eq $true)

                There is also a Do..Until loop, which will run the loop while the condition
                evaluates to $false (i.e., until the condition becomes $true):
                    do { Do-Things } until ($condition -eq $true)
            #>
            $Values = do {
                'eat me!'
                # Exactly one iteration occurs despite the condition being $false.
            } while ($false)
            __ | Should -Be $Values
        }
    }

    Context 'Loops and Keywords' {
        
        It 'is possible to break a standard loop' {
            <#
                Standard loops in PowerShell can be broken out of using the keyword "break".
                This does not work the same way for pipeline cmdlets.
            #>
            $Values = foreach ($Number in 1..5) {
                $Number
                break
            }
            __ | Should -Be $Values # How quickly did we break?
        }
        
        It 'is possible to skip iterations of a standard loop' {
            <#
                Iterations can be skipped in standard PowerShell loops by using the keyword "continue".
                This is useful for scenarios such as when code should only run if a condition is true,
                or the opposite.
            #>
            $Values = foreach ($Number in 1..5) {
                <#
                    Sometimes you don't want to run the whole loop iteration. It can be used as a way
                    to exclude values from a loop, or to speed up processing.
                #>
                if ($Number -eq 3) {
                    continue
                }

                $Number
            }

            $Values | Should -Be @(
                __
                __
                __
                __
            )
        }
        
        It 'is possible to return a value from a standard loop' {
            <#
                Loops in PowerShell can also have values returned from them using
                the keyword "return". Returning a value stops the loop immediately
                and outputs the value from the current scope.

                Outputting using return in a loop will not respect any variable assignments
                in the same scope.
            #>
            $Number = 5
            $Values = $Number

            $Values += while ($Number -lt 10) {
                # While loops can also imitate For loops by increment an existing variable.
                $Number++
                
                if ($Number -gt 7) {
                    return ($Number - 5) # "return" stops running any more code in the current scope
                }
            }

            # What did return do? Does Values pick up the result?
            __ | Should -Be $Values
        }

        It 'has the same name but not the same behaviour' {
            <#
                PowerShell has a standard loop named foreach, but "foreach" is also an alias
                of the cmdlet ForEach-Object when it's put in a pipeline.

                This can be confusing, since they don't have the same behaviour with keywords!
                This is especially true for break and continue, but return as well. Using these
                keywords in a pipeline can be dangerous.
            #>

            $Values = 10 # Set $Values to 10 before the pipeline, then assign it to the output
            $Values = 1..5 |
                <#
                    Be careful with using the foreach alias for ForEach-Object. The keyword "break"
                    will not break only the loop when used in a pipeline, as with a standard loop.

                    Using keywords in pipelines can have unexpected results. In the worst case it
                    might terminate your entire running script or code, or alter the behaviour.
                #>
                foreach {
                    $_
                    break
                }
            $Values = 20 # Is the re-assigning of $Values respected with a dangerous pipeline-break?

            # How broken was the loop?
            __ | Should -Be $Values
        }

        It 'returns differently when used in a pipeline' {
            <#
                Returning a value from a whole pipeline is not a valid operation. When using "return"
                in a pipeline, it just returns the value from the current iteration, but does not break
                the pipeline.
            #>

            $Values = 1..5 | ForEach-Object {
                    return ($_ + 5) # Returning a value from a pipeline is only done from the current iteration
                }

            $Values | Should -Be @(
                __
                __
                __
                __
                __
            )
        }
    }
}
