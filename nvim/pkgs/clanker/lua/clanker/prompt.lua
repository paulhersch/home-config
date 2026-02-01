---
--  Embeds the user prompt (stolen from prime)
---

local P = {}
local M = {}

P.base = [[
You are a software engineering assistant mean to create robust and conanical code
Check the contents of the file you are in for any helper functions or context
]]

-- Embed for visual mode, use the file as greater context
M.visual = function(file, selection, ft, extra_instructions)
    local final = P.base .. ([[
You receive a selection in neovim that you need to replace with new code.
consider the context of the selection and what you are supposed to be implementing.

<Example>
<Selection>
function add(a: number, b: number): number {
}
</Selection>
<Filecontext>
function add(a: number, b: number): number {
}
</Filecontext>
<Filetype>
typescript
</Filetype>
<Instructions>
Implement this function
</Instructions>
<Output>
function add(a: number, b: number): number {
    return a + b;
}
</Output>
<Notes>
* consider the used filetype
* only output the contents of OUTPUT
</Notes>
</Example>

if there are INSTRUCTIONS, follow those when changing SELECTION.  Do not deviate

<Selection>
%s
</Selection>
<Filecontext>
%s
</Filecontext>
<Filetype>
%s
</Filetype>
<Instructions>
%s
</Instructions>
    ]]):format(
        selection,
        ft,
        file,
        extra_instructions
    )
    return final
end

M.fill_func = function(file, func_to_change, ft, prompt)
    local final = ([[You have been given a function change.
Create the contents of the function.
If the function already contains contents, use those as context
Your response should be the complete function, including signature

<Example>
<Input>
<Text>
export function fizz_buzz(count: number): void {
}
</Text>
<Filecontext>
export function fizz_buzz(count: number): void {
}
</Filecontext>
<Filetype>
typescript
</Filetype>
</Input>
<Output>
function fizz_buzz(count: number): void {
  for (let i = 1; i <= count; i++) {
    if (i %% 15 === 0) {
      console.log("FizzBuzz");
    } else if (i %% 3 === 0) {
      console.log("Fizz");
    } else if (i %% 5 === 0) {
      console.log("Buzz");
    } else {
      console.log(i);
    }
  }
}
</Output>
<Notes>
* do not change function headers
* only return the function
* consider the used filetype
</Notes>
</Example>


if there are DIRECTIONS, follow those when changing this function.  Do not deviate

<Input>
<Filecontext>
%s
</Filecontext>
<Text>
%s
</Text>
<Filetype>
%s
</Filetype>
</Input>
<Directions>
%s
</Directions>
]]):format(file, func_to_change, ft, prompt)
    return final
end

return M
