# This file is a part of DynareJulia. License is GNU GPL v.3: https://www.gnu.org/licenses/. 

"""
    ExtendedDates

The `ExtendedDates` module extends Julia `Dates` module by providing dates at different frequencies:
YearDate`, `SemesterDate`, `QuarterDate`, `MonthDate`, `WeekDate`, `DayDate` and `UndatedDate` types.
All of them use their own proleptic Gregorian calendar at corresponding frequency. This is primarily aimed
at providing the time index of timeseries at various frequencies.

`Dates.Period` types `Semester` and `Undated` are also provided.

```jldoctest
julia> y = YearDate(2017)
2017

julia> s = SemesterDate(2017, 2)
2017-S2

julia> q = QuarterDate(2017, 3)
2017-Q3

julia> m = MonthDate(2017, 10)
2017-10

julia> w = WeekDate(2017, 52)
2017-W52

julia> d = DayDate(2017, 9, 15)
2017-09-15

julia> u = UndatedDate(3)
3

```

Please see the manual for more information.
"""
module ExtendedDates

import Base: ==, div, fld, mod, rem, gcd, lcm, +, -, *, /, %, broadcast
using Printf: @sprintf

using Base.Iterators
using Dates
    
include("periods.jl")
include("types.jl")
include("accessors.jl")
include("query.jl")
include("arithmetic.jl")
include("conversions.jl")
include("ranges.jl")
include("adjusters.jl")
include("rounding.jl")
include("io.jl")
include("parse.jl")

# re-export all Dates names
export Period, DatePeriod, TimePeriod,
    Year, Quarter, Month, Week, Day, Hour, Minute, Second, Millisecond,
    Microsecond, Nanosecond,
    TimeZone, UTC, TimeType, DateTime, Date, Time,
    # periods.jl
    canonicalize,
    # accessors.jl
    yearmonthday, yearmonth, monthday, year, month, week, day,
    hour, minute, second, millisecond, dayofmonth,
    microsecond, nanosecond,
    # query.jl
    dayofweek, isleapyear, daysinmonth, daysinyear, dayofyear, dayname, dayabbr,
    dayofweekofmonth, daysofweekinmonth, monthname, monthabbr,
    quarterofyear, dayofquarter,
    Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday,
    Mon, Tue, Wed, Thu, Fri, Sat, Sun,
    January, February, March, April, May, June,
    July, August, September, October, November, December,
    Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec,
    # conversions.jl
    unix2datetime, datetime2unix, now, today,
    rata2datetime, datetime2rata, julian2datetime, datetime2julian,
    # adjusters.jl
    firstdayofweek, lastdayofweek,
    firstdayofmonth, lastdayofmonth,
    firstdayofyear, lastdayofyear,
    firstdayofquarter, lastdayofquarter,
    adjust, tonext, toprev, tofirst, tolast,
    # io.jl
    ISODateTimeFormat, ISODateFormat, ISOTimeFormat, DateFormat, RFC1123Format, @dateformat_str

# ExtendDates exported names
export Semester, Undated,
    YearDate, SemesterDate, QuarterDate, MonthDate, WeekDate, DayDate, UndatedDate
    


end # module
