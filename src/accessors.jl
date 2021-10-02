
# Convert # of Rata Die days to proleptic Gregorian calendar y,m,d,w
# Reference: http://mysite.verizon.net/aesir_research/date/date0.htm

# Accessor functions
value(sp::SimpleDate) = sp.instant.periods.value
value(p::Period) = p.value
function days(q::QuarterDate)
    y1, q1 = divrem(value(q), 4)
    m1 = 3 * q1
    return value(DayDate(y1, m1, daysinmonth(m1)))
end
function days(m::MonthDate)
    y1, m1 = divrem(value(m), 12)
    return value(DayDate(y1, m1, daysinmonth(m1)))
end
days(w::WeekDate) = 7 * value(w)
days(d::DayDate) = value(d)
weeks(w::WeekDate) = value(w)
months(m::MonthDate) = value(m)
quarters(q::QuarterDate) = value(q)
semesters(s::SemesterDate) = value(s)
year(y::YearDate) = value(y) + 1
year(s::SemesterDate) = div(value(s) - 1, 2) + 1
year(q::QuarterDate) = div(value(q) - 1, 4) + 1
year(m::MonthDate) = div(value(m) - 1, 12) + 1
year(w::WeekDate) = Dates.year((value(w) * 7))
year(d::DayDate) = Dates.year(value(d))
semester(s::SemesterDate) = rem(abs(value(s)) - 1, 2) + 1
semester(q::QuarterDate) = rem(abs(value(q)) - 1, 2) + 1
semester(m::MonthDate) = div(rem(abs(value(m)) - 1, 12), 2) + 1
semester(d::DayDate) = semester(value(d))
quarter(q::QuarterDate) = rem(abs(value(q)) - 1, 4) + 1
quarter(m::MonthDate) = div(rem(abs(value(m)) - 1, 12), 4) + 1
quarter(d::DayDate) = quarter(value(d))
month(m::MonthDate) = rem(abs(value(m)) - 1, 12) + 1
month(d::DayDate) = month(value(d))
week(w::WeekDate) = Dates.week(value(w) * 7)
week(d::DayDate) = Dates.week(value(d))
day(d::DayDate) = Dates.day(value(d))

# accessor functions for number of days
year(d::Int64) = Dates.year(d)

function semester(d::Int64)
    y, m = Dates.yearmonth(d)
    return (m < 7) ? 1 : 2
end

function quarter(d::Int64)
    y, m = Dates.yearmonth(d)
    return div(m - 1, 3) + 1
end

function month(d::Int64)
    y, m = Dates.yearmonth(d)
    return m
end

week(d) = Dates.week(d)
day(d) = Dates.day(d)

dayofmonth(dt::DayDate) = day(dt)

yearmonth(dt::DayDate) = Dates.yearmonth(days(dt))
monthday(dt::DayDate) = Dates.monthday(days(dt))
yearmonthday(dt::DayDate) = Dates.yearmonthday(days(dt))

# Documentation for exported accessors
for func in (:year, :month, :quarter)
    name = string(func)
    @eval begin
        @doc """
            $($name)(dt::Dates.TimeType) -> Int64

        The $($name) of a `Date` or `DateTime` as an [`Int64`](@ref).
        """ $func(dt::Dates.TimeType)
    end
end

"""
    week(dt::Dates.TimeType) -> Int64

Return the [ISO week date](https://en.wikipedia.org/wiki/ISO_week_date) of a `Date` or
`DateTime` as an [`Int64`](@ref). Note that the first week of a year is the week that
contains the first Thursday of the year, which can result in dates prior to January 4th
being in the last week of the previous year. For example, `week(Date(2005, 1, 1))` is the 53rd
week of 2004.

# Examples
```jldoctest
julia> Dates.week(Date(1989, 6, 22))
25

julia> Dates.week(Date(2005, 1, 1))
53

julia> Dates.week(Date(2004, 12, 31))
53
```
"""
week(dt::Dates.TimeType)

for func in (:day, :dayofmonth)
    name = string(func)
    @eval begin
        @doc """
            $($name)(dt::Dates.TimeType) -> Int64

        The day of month of a `Date` or `DateTime` as an [`Int64`](@ref).
        """ $func(dt::Dates.TimeType)
    end
end
