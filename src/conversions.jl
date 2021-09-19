# This file is a part of Julia. License is MIT: https://julialang.org/license

# Conversion/Promotion

for T in (:Day, :Week, :Month, :Quarter, :Semester, :Year, :Undated)
    @eval begin
        $T(dt::Dates.TimeType) = convert($T, dt)
    end
end

