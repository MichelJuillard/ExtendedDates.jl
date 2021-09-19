# This file is a part of Julia. License is MIT: https://julialang.org/license

# Given a start and end date, how many steps/periods are in between
guess(a::YearDate, b::YearDate, c) = Int64(div(value(b - a), year(c)))
guess(a::SemesterDate, b::SemesterDate, c) = Int64(div(value(b - a), semester(c)))
guess(a::QuarterDate, b::QuarterDate, c) = Int64(div(value(b - a), quarter(c)))
guess(a::MonthDate, b::MonthDate, c) = Int64(div(value(b - a), month(c)))
guess(a::WeekDate, b::WeekDate, c) = Int64(div(value(b - a), week(c)))
guess(a::DayDate, b::DayDate, c) = Int64(div(value(b - a), day(c)))
guess(a::UndatedDate, b::UndatedDate, c) = Int64(div(value(b - a), undated(c)))
function len(a, b, c)
    lo, hi, st = min(a, b), max(a, b), abs(c)
    i = guess(a, b, c)
    v = lo + st * i
    prev = v  # Ensure `v` does not overflow
    while v <= hi && prev <= v
        prev = v
        v += st
        i += 1
    end
    return i - 1
end

