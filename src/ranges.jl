# This file is a part of Julia. License is MIT: https://julialang.org/license

# Given a start and end date, how many steps/periods are in between
guess(a::YearDate, b::YearDate, c::Year) = Int64(div(value(b - a), value(c)))
guess(a::YearDate, b::YearDate, c::Semester) = Int64(div(2 * value(b - a), value(c)))
guess(a::YearDate, b::YearDate, c::Quarter) = Int64(div(4 * value(b - a), value(c)))
guess(a::YearDate, b::YearDate, c::Month) = Int64(div(12 * value(b - a), value(c)))
guess(a::SemesterDate, b::SemesterDate, c::Year) = Int64(div(value(b - a), semesters(c)))
guess(a::SemesterDate, b::SemesterDate, c::Semester) = Int64(div(value(b - a), value(c)))
guess(a::SemesterDate, b::SemesterDate, c::Quarter) = Int64(div(2 * value(b - a), value(c)))
guess(a::SemesterDate, b::SemesterDate, c::Month) = Int64(div(6 * value(b - a), value(c)))
guess(a::QuarterDate, b::QuarterDate, c::Year) = Int64(div(value(b - a), quarters(c)))
guess(a::QuarterDate, b::QuarterDate, c::Semester) = Int64(div(value(b - a), quarters(c)))
guess(a::QuarterDate, b::QuarterDate, c::Quarter) = Int64(div(value(b - a), value(c)))
guess(a::QuarterDate, b::QuarterDate, c::Month) = Int64(div(3 * value(b - a), value(c)))
guess(a::MonthDate, b::MonthDate, c::Year) = Int64(div(value(b - a), months(c)))
guess(a::MonthDate, b::MonthDate, c::Semester) = Int64(div(value(b - a), months(c)))
guess(a::MonthDate, b::MonthDate, c::Quarter) = Int64(div(value(b - a), months(c)))
guess(a::MonthDate, b::MonthDate, c::Month) = Int64(div(value(b - a), value(c)))
guess(a::WeekDate, b::WeekDate, c::Year) = Int64(div(value(b - a), weeks(c)))
guess(a::WeekDate, b::WeekDate, c::Semester) = Int64(div(value(b - a), weeks(c)))
guess(a::WeekDate, b::WeekDate, c::Quarter) = Int64(div(value(b - a), weeks(c)))
guess(a::WeekDate, b::WeekDate, c::Month) = Int64(div(value(b - a), weeks(c)))
guess(a::WeekDate, b::WeekDate, c::Week) = Int64(div(value(b - a), value(c)))
guess(a::WeekDate, b::WeekDate, c::Day) = Int64(7 * div(value(b - a), value(c)))
guess(a::DayDate, b::DayDate, c::Year) = Int64(div(value(b - a), days(c)))
guess(a::DayDate, b::DayDate, c::Semester) = Int64(div(value(b - a), days(c)))
guess(a::DayDate, b::DayDate, c::Quarter) = Int64(div(value(b - a), days(c)))
guess(a::DayDate, b::DayDate, c::Month) = Int64(div(value(b - a), days(c)))
guess(a::DayDate, b::DayDate, c::Week) = Int64(div(value(b - a), days(c)))
guess(a::DayDate, b::DayDate, c::Day) = Int64(div(value(b - a), value(c)))
guess(a::UndatedDate, b::UndatedDate, c) = Int64(div(value(b - a), value(c)))
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
Base.length(r::StepRange{<:SimpleDate}) =
    isempty(r) ? Int64(0) : len(r.start, r.stop, r.step) + 1
# Period ranges hook into Int64 overflow detection
Base.length(r::StepRange{<:Dates.Period}) =
    length(StepRange(value(r.start), value(r.step), value(r.stop)))

# Overload Base.steprange_last because `rem` is not overloaded for `TimeType`s
function Base.steprange_last(start::T, step, stop) where {T<:SimpleDate}
    if isa(step, AbstractFloat)
        throw(ArgumentError("StepRange should not be used with floating point"))
    end
    z = zero(step)
    step == z && throw(ArgumentError("step cannot be zero"))

    if stop == start
        last = stop
    else
        if (step > z) != (stop > start)
            last = Base.steprange_last_empty(start, step, stop)
        else
            diff = stop - start
            if (diff > zero(diff)) != (stop > start)
                throw(OverflowError())
            end
            remain = stop - (start + step * len(start, stop, step))
            last = stop - remain
        end
    end
    last
end

import Base.in
function in(x::T, r::StepRange{T}) where {T<:SimpleDate}
    n = len(first(r), x, step(r)) + 1
    n >= 1 && n <= length(r) && r[n] == x
end

Base.iterate(r::StepRange{<:SimpleDate}) =
    length(r) <= 0 ? nothing : (r.start, (length(r), 1))
Base.iterate(r::StepRange{<:SimpleDate}, (l, i)) =
    l <= i ? nothing : (r.start + r.step * i, (l, i + 1))

+(x::Period, r::AbstractRange{<:SimpleDate}) = (x+first(r)):step(r):(x+last(r))
+(r::AbstractRange{<:SimpleDate}, x::Period) = x + r
-(r::AbstractRange{<:SimpleDate}, x::Period) = (first(r)-x):step(r):(last(r)-x)
*(x::Period, r::AbstractRange{<:Real}) = (x*first(r)):(x*step(r)):(x*last(r))
*(r::AbstractRange{<:Real}, x::Period) = x * r
/(r::AbstractRange{<:P}, x::P) where {P<:Period} = (first(r)/x):(step(r)/x):(last(r)/x)

# Combinations of types and periods for which the range step is regular
Base.RangeStepStyle(::Type{<:OrdinalRange{<:SimpleDate,<:Dates.FixedPeriod}}) =
    Base.RangeStepRegular()
