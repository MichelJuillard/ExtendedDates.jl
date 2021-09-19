abstract type SimpleDate <: Dates.TimeType end

SIMPLEPERIODS = (:Year, :Semester, :Quarter, :Month, :Week, :Day, :Undated)

# weeks computations
function week_per_year()
    weeks = Dict()
    cummulativeweeks = 0
    for y = 0:2500
        w = Dates.week(Dates.Date(y, 12, 28))
        cummulativeweeks += w
        weeks[y] = Dict([("max_weeks", w), ("cum_weeks", cummulativeweeks)])
    end
    return weeks
end

if !@isdefined WEEKTABLE
    const WEEKTABLE = week_per_year()
end

"""
    localUTInstant{T}

The `localUTInstant` represents a machine timeline based on UT time (1 day = one revolution of
the earth). The `T` is a `Period` parameter that indicates the resolution or precision of
the instant.
"""
struct UTInstant{P<:Dates.DatePeriod} <: Dates.Instant
    periods::P
end

# Adding new date types to SimpleDate

for (T1, T2) in (
    (:Year, :YearDate),
    (:Quarter, :QuarterDate),
    (:Month, :MonthDate),
    (:Week, :WeekDate),
    (:Day, :DayDate),
)
    @eval begin
        struct $T2 <: SimpleDate
            instant::Dates.UTInstant{Dates.$T1}
            $T2(instant::Dates.UTInstant{Dates.$T1}) = new(instant)
        end
    end
end


# Adding new periods to TimeType
for (T1, T2) in ((:Semester, :SemesterDate), (:Undated, :UndatedDate))
    @eval begin
        struct $T2 <: SimpleDate
            instant::UTInstant{$T1}
            $T2(instant::UTInstant{$T1}) = new(instant)
        end
    end
end



# Convenience default constructors
UTY(x) = Dates.UTInstant(Dates.Year(x))
UTS(x) = localUTInstant(Semester(x))
UTQ(x) = Dates.UTInstant(Dates.Quarter(x))
UTM(x) = Dates.UTInstant(Dates.Month(x))
UTW(x) = Dates.UTInstant(Dates.Week(x))
UTD(x) = Dates.UTInstant(Dates.Day(x))
UTU(x) = localUTInstant(Undated(x))

"""
    argerror([msg]) -> Union{ArgumentError, Nothing}

Return an `ArgumentError` object with the given message,
or [`nothing`](@ref) if no message is provided. For use by `validargs`.
"""
argerror(msg::String) = ArgumentError(msg)
argerror() = nothing

### CONSTRUCTORS ###
# Core constructors
"""
    Year(y) -> Year

Construct a `Year` type. Argument must be convertible to [`Int64`](@ref).
"""
function Year(y::Int64)
    return Year(UTY(yearfromepoch(y)))
end

function yearfromepoch(y)
    return y - 1
end

"""
    Semester(y, [q]) -> Quarter

Construct a `Semester` type by parts. Arguments must be convertible to [`Int64`](@ref).
"""
function Semester(y::Int64, s::Int64 = 1)
    err = validargs(Semester, y, s)
    err === nothing || throw(err)
    return Semester(UTS(totalsemesters(y, s)))
end

function validargs(::Type{Semester}, y::Int64, s::Int64)
    0 < s < 3 || return argerror("Semester: $s out of range (1:2)")
    return argerror()
end

function totalsemesters(y, s)
    return 2 * yearfromepoch(y) + s
end

"""
    Quarter(y, [q]) -> Quarter

Construct a `Quarter` type by parts. Arguments must be convertible to [`Int64`](@ref).
"""
function Quarter(y::Int64, q::Int64 = 1)
    err = validargs(Quarter, y, q)
    err === nothing || throw(err)
    return Quarter(UTQ(totalquarters(y, q)))
end

function validargs(::Type{Quarter}, y::Int64, q::Int64)
    0 < q < 5 || return argerror("Quarter: $q out of range (1:4)")
    return argerror()
end

function totalquarters(y, q)
    return 4 * yearfromepoch(y) + q
end

"""
    Month(y, [m]) -> Month

Construct a `Month` type by parts. Arguments must be convertible to [`Int64`](@ref).
"""
function Month(y::Int64, m::Int64 = 1)
    err = validargs(Month, y, m)
    err === nothing || throw(err)
    return Month(UTM(totalmonths(y, m)))
end

function validargs(::Type{Month}, y::Int64, m::Int64)
    0 < m < 13 || return argerror("Month: $m out of range (1:12)")
    return argerror()
end

function totalmonths(y, m)
    return 12 * yearfromepoch(y) + m
end

"""
    Week(y, [w]) -> Week

Construct a `Week` type by parts. Arguments must be convertible to [`Int64`](@ref).
"""
function Week(y::Int64, w::Int64 = 1)
    err = validargs(Week, y, w)
    err === nothing || throw(err)
    return Week(UTW(totalweeks(y, w)))
end

function validargs(::Type{Week}, y::Int64, w::Int64)
    0 < y < 2500 || return argerror("Week: $y out of range (0:2500)")
    0 < w < 53 || return argerror("Week: $w out of range (1:53)")
    return argerror()
end

function totalweeks(y, w)
    return WEEKTABLE[y-1]["cum_weeks"] + w
end

"""
    Day(y, [m, d]) -> Day

Construct a `Day` type by parts. Arguments must be convertible to [`Int64`](@ref).
A `Day``is identical to  a `Dates.Date`
"""
function Day(y::Int64, m::Int64 = 1, d::Int64 = 1)
    err = Dates.validargs(Dates.Date, y, m, d)
    err === nothing || throw(err)
    return Day(Dates.UTD(Dates.totaldays(y, m, d)))
end

"""
    Undated(u) -> Undated

Construct a `Undated` type. Argument must be convertible to [`Int64`](@ref).
"""
function Undated(u::Int64)
    return Undated(UTU(u))
end

# Using Dates.Periods
DayDate(y::Dates.Year, m::Dates.Month = Dates.Month(1), d::Dates.Day = Dates.Day(1)) =
    DayDate(Dates.value(y), Dates.value(m), Dates.value(d))
WeekDate(y::Dates.Year, w::Dates.Week = Dates.Week(1)) =
    WeekDate(Dates.value(y), Dates.value(w))
MonthDate(y::Dates.Year, m::Dates.Month = Dates.Month(1)) =
    MonthDate.(Dates.value(y), Dates.value(m))
QuarterDate(y::Dates.Year, q::Dates.Quarter = Dates.Quarter(1)) =
    Date.Quarter(Dates.value(y), Dates.value(q))
SemesterDate(y::Dates.Year, s::Semester = Semester(1)) =
    SemesterDate(Dates.value(y), Dates.value(s))
YearDate(y::Dates.Year) = YearDate(Dates.value(y))

# To allow any order/combination of Dates.Periods
"""
    Semester(period::Dates.Period...) -> Semester

Construct a `Semester` type by `Period` type parts. Arguments may be in any order. `Semester` parts
not provided will default to the value of `Dates.default(period)`.
"""
function SemesterDate(period::Dates.Period, periods::Dates.Period...)
    y = Dates.Year(1)
    s = Semester(1)
    for p in (period, periods...)
        isa(p, Dates.Year) && (y = p::Dates.Year)
        isa(p, Semester) && (s = p::Semester)
    end
    return Semester(y, s)
end

function Quarter(period::Dates.Period, periods::Dates.Period...)
    y = Dates.Year(1)
    q = Dates.Quarter(1)
    for p in (period, periods...)
        isa(p, Dates.Year) && (y = p::Dates.Year)
        isa(p, Dates.Quarter) && (q = p::Dates.Quarter)
    end
    return Quarter(y, q)
end

function Month(period::Dates.Period, periods::Dates.Period...)
    y = Dates.Year(1)
    m = Dates.Month(1)
    for p in (period, periods...)
        isa(p, Dates.Year) && (y = p::Dates.Year)
        isa(p, Dates.Month) && (m = p::Dates.Month)
    end
    return Month(y, m)
end

function Week(period::Dates.Period, periods::Dates.Period...)
    y = Dates.Year(1)
    w = Dates.Week(1)
    for p in (period, periods...)
        isa(p, Dates.Year) && (y = p::Dates.Year)
        isa(p, Dates.Week) && (w = p::Dates.Week)
    end
    return Week(y, w)
end

function Day(period::Dates.Period, periods::Dates.Period...)
    y = Dates.Year(1)
    m = Dates.Month(1)
    d = Dates.Day(1)
    for p in (period, periods...)
        isa(p, Dates.Year) && (y = p::Dates.Year)
        isa(p, Dates.Month) && (m = p::Dates.Month)
        isa(p, Dates.Day) && (d = p::Dates.Day)
    end
    return Day(y, m, d)
end

# Fallback constructors
Year(y) = Year(Int64(y))
Semester(y, s = 1) = Semester(Int64(y), Int64(s))
Quarter(y, q = 1) = Quarter(Int64(y), Int64(q))
Month(y, m = 1) = Month(Int64(y), Int64(m))
Week(y, w = 1) = Week(Int64(y), Int64(w))
Day(y, m = 1, d = 1) = Day(Int64(y), Int64(m), Int64(d))
Undated(y) = Undated(Int64(y))

# Traits, Equality
Base.isfinite(::Union{Type{T},T}) where {T<:SimpleDate} = true
calendar(dt::T) where {T<:SimpleDate} = Dates.ISOCalendar

"""
    eps(::Type{YearDate}) -> Dates.Year
    eps(::Type{Semester}) -> Semester
    eps(::Type{Quarter}) -> Dates.Quarter
    eps(::Type{Month}) -> Dates.Month
    eps(::Type{Week}) -> Dates.Week
    eps(::Type{Day}) -> Dates.Day
    eps(::Type{Undated}) -> 1
    eps(::SimpleDate) -> Dates.Period

Return the smallest unit value supported by the `SimpleDate`.

# Examples
```jldoctest
julia> eps(Year)
1 year

julia> eps(Day)
1 day
"""
Base.eps(
    ::Union{
        Type{YearDate},
        Type{SemesterDate},
        Type{QuarterDate},
        Type{MonthDate},
        Type{WeekDate},
        Type{DayDate},
        Type{UndatedDate},
        SimpleDate,
    },
)

Base.eps(::Type{YearDate}) = Dates.Year(1)
Base.eps(::Type{SemesterDate}) = Semester(1)
Base.eps(::Type{QuarterDate}) = Dates.Quarter(1)
Base.eps(::Type{MonthDate}) = Dates.Month(1)
Base.eps(::Type{WeekDate}) = Dates.Week(1)
Base.eps(::Type{DayDate}) = Dates.Day(1)
Base.eps(::Type{UndatedDate}) = Int64(1)
Base.eps(::T) where {T<:SimpleDate} = eps(T)::Dates.Period

# zero returns dt::T - dt::T
Base.zero(::Type{YearDate}) = Dates.Year(0)
Base.zero(::Type{SemesterDate}) = Semester(0)
Base.zero(::Type{QuarterDate}) = Dates.Quarter(0)
Base.zero(::Type{MonthDate}) = Dates.Month(0)
Base.zero(::Type{WeekDate}) = Dates.Week(0)
Base.zero(::Type{DayDate}) = Dates.Day(0)
Base.zero(::Type{UndatedDate}) = Int64(0)
Base.zero(::T) where {T<:SimpleDate} = zero(T)::Dates.Period

Base.typemax(::Union{YearDate,Type{YearDate}}) = Year(252522163911149)
Base.typemin(::Union{YearDate,Type{YearDate}}) = Year(-252522163911150)
Base.typemax(::Union{SemesterDate,Type{SemesterDate}}) = Semester(252522163911149, 2)
Base.typemin(::Union{SemesterDate,Type{SemesterDate}}) = Semester(-252522163911150, 1)
Base.typemax(::Union{QuarterDate,Type{QuarterDate}}) = Quarter(252522163911149, 4)
Base.typemin(::Union{QuarterDate,Type{QuarterDate}}) = Quarter(-252522163911150, 1)
Base.typemax(::Union{MonthDate,Type{MonthDate}}) = Month(252522163911149, 12)
Base.typemin(::Union{MonthDate,Type{MonthDate}}) = Month(-252522163911150, 1)
Base.typemax(::Union{WeekDate,Type{WeekDate}}) = Week(252522163911149, 52)
Base.typemin(::Union{WeekDate,Type{WeekDate}}) = Week(-252522163911150, 1)
Base.typemax(::Union{DayDate,Type{DayDate}}) = Day(252522163911149, 12, 31)
Base.typemin(::Union{DayDate,Type{DayDate}}) = Day(-252522163911150, 1, 1)
Base.typemax(::Union{UndatedDate,Type{UndatedDate}}) = Undated(typemax(UInt64))
Base.typemin(::Union{UndatedDate,Type{UndatedDate}}) = Undated(0)

# Periods promotion, isless, ==
Base.promote_rule(::Type{Dates.Year}, ::Type{Semester}) = Semester
Base.promote_rule(::Type{Semester}, ::Type{Dates.Quarter}) = Dates.Quarter
Base.promote_rule(::Type{Semester}, ::Type{Dates.Month}) = Dates.Month
Base.promote_rule(::Type{Semester}, ::Type{Dates.Week}) = Dates.Week
Base.promote_rule(::Type{Semester}, ::Type{Dates.Day}) = Dates.Day

# other periods with fixed conversions but which aren't fixed time periods
const OtherPeriod = Union{Dates.Month,Dates.Quarter,Semester,Dates.Year}

let vmax = typemax(Int64) ÷ 2, vmin = typemin(Int64) ÷ 2
    @eval function Base.convert(::Type{Semester}, x::Dates.Year)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Semester, x))
        Semester(value(x) * 2)
    end
end
Base.convert(::Type{Dates.Year}, x::Semester) = Dates.Year(divexact(value(x), 2))
#Base.promote_rule(::Type{Dates.Year}, ::Type{Semester}) = Semester

let vmax = typemax(Int64) ÷ 6, vmin = typemin(Int64) ÷ 6
    @eval function Base.convert(::Type{Dates.Month}, x::Semester)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Dates.Month, x))
        Dates.Month(value(x) * 6)
    end
end
Base.convert(::Type{Semester}, x::Dates.Month) = Semester(divexact(value(x), 6))
#Base.promote_rule(::Type{Semester}, ::Type{Dates.Month}) = Dates.Month

let vmax = typemax(Int64) ÷ 2, vmin = typemin(Int64) ÷ 2
    @eval function Base.convert(::Type{Dates.Quarter}, x::Semester)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Dates.Quarter, x))
        Dates.Quarter(value(x) * 3)
    end
end
Base.convert(::Type{Semester}, x::Dates.Quarter) = Dates.Quarter(divexact(value(x), 2))
#Base.promote_rule(::Type{Semester}, ::Type{Dates.Quarter}) = Dates.Quarter


# truncating conversions to milliseconds, nanoseconds and days:
# overflow can happen for periods longer than ~300,000 years
days(c::Semester) = 182.62125 * value(c)

"""
    islongyear(y)

Return `true` if and only if year `y` has 53 ISO-8601 weeks.

# Examples
```julia-repl
julia> islongyear(2020)
true

julia> islongyear(2021)
false
```
"""
function islongyear(y::Integer)
    mod(trunc(Int, y) + trunc(Int, y / 4) - trunc(Int, y / 100) + trunc(Int, y / 400), 7) ==
    4 ||
        mod(
            trunc(Int, y - 1) + trunc(Int, (y - 1) / 4) - trunc(Int, (y - 1) / 100) +
            trunc(Int, (y - 1) / 400),
            7,
        ) == 3
end

"""
    weeksinyear(y)

Return the number of ISO-8601 weeks in year `y`.

# Examples
```julia-repl
julia> islongyear(2020)
53

julia> islongyear(2021)
52
```
"""
function weeksinyear(y::Integer)
    islongyear(y) ? 53 : 52
end

"""
    numberofweeks(y, w)

Return the number of ISO-8601 weeks since Base Year = 1 in week `w` of year `y`.

# Examples
```julia-repl
julia> islongyear(2020)
53

julia> islongyear(2021)
52
```
"""
function numberofweeks(y::Integer, w::Integer)
    sum(weeksinyear.(1:(y-1))) + w
end
