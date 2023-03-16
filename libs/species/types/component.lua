local class = require 'class'

for name, enum in pairs(class.enums) do
    for index, subenum in enum.Iter() do
        p(name, index, subenum)
    end
end