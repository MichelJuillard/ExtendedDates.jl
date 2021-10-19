"""
    AbstractPeriodToken

A token used in parsing or formatting a period string. Each subtype must
define the tryparsenext and format methods.

"""
abstract type AbstractPeriodToken end

"""
    tryparsenext(tok::AbstractPeriodToken, str::String, i::Int, len::Int)

`tryparsenext` parses for the `tok` token in `str` starting at index `i`.
`len` is the length of the string.

If parsing succeeds, returns a tuple of 2 elements `(res, idx)`, where:

* `res` is the result of the parsing.
* `idx::Int`, is the index _after_ the index at which parsing ended.
"""
function tryparsenext end


# Information for parsing and formatting date time values.
struct SimpleDateFormat{S,T<:Tuple}
    tokens::T
end

### Token types ###

struct PeriodPart{letter} <: AbstractPeriodToken
    width::Int
    fixed::Bool
end

@inline min_width(d::PeriodPart) = d.fixed ? d.width : 1
@inline max_width(d::PeriodPart) = d.fixed ? d.width : 0

function _show_content(io::IO, d::PeriodPart{c}) where {c}
    for i = 1:d.width
        print(io, c)
    end
end

function Base.show(io::IO, d::PeriodPart{c}) where {c}
    print(io, "PeriodPart(")
    _show_content(io, d)
    print(io, ")")
end

### Parse tokens

for c in "ysqmwd"
    @eval begin
        @inline function tryparsenext(d::PeriodPart{$c}, str, i, len)
            return tryparsenext_base10(str, i, len, min_width(d), max_width(d))
        end
    end
end

for (tok, fn) in zip("uU", Any[Dates.monthabbr_to_value, Dates.monthname_to_value])
    @eval @inline function tryparsenext(d::PeriodPart{$tok}, str, i, len, locale)
        next = tryparsenext_word(str, i, len, locale, max_width(d))
        next === nothing && return nothing
        word, i = next
        val = $fn(word, locale)
        val == 0 && return nothing
        return val, i
    end
end

### Format tokens

for (c, fn) in zip("ysqmwd", Any[year, semester, quarter, month, week, day])
    @eval function format(io, d::PeriodPart{$c}, p)
        print(io, string($fn(p), base = 10, pad = d.width))
    end
end

for (tok, fn) in zip("uU", Any[Dates.monthabbr, Dates.monthname])
    @eval function format(io, d::PeriodPart{$tok}, p)
        print(io, $fn(month(p)))
    end
end


### Delimiters

struct Delim{T,length} <: AbstractPeriodToken
    d::T
end

Delim(d::T) where {T<:AbstractChar} = Delim{T,1}(d)
Delim(d::String) = Delim{String,length(d)}(d)

@inline function tryparsenext(d::Delim{<:AbstractChar,N}, str, i::Int, len) where {N}
    for j = 1:N
        i > len && return nothing
        next = iterate(str, i)
        @assert next !== nothing
        c, i = next
        c != d.d && return nothing
    end
    return true, i
end

@inline function tryparsenext(d::Delim{String,N}, str, i::Int, len) where {N}
    i1 = i
    i2 = firstindex(d.d)
    for j = 1:N
        if i1 > len
            return nothing
        end
        next1 = iterate(str, i1)
        @assert next1 !== nothing
        c1, i1 = next1
        next2 = iterate(d.d, i2)
        @assert next2 !== nothing
        c2, i2 = next2
        if c1 != c2
            return nothing
        end
    end
    return true, i1
end

@inline function format(io, d::Delim, dt)
    print(io, d.d)
end

function _show_content(io::IO, d::Delim{<:AbstractChar,N}) where {N}
    if d.d in keys(CONVERSION_SPECIFIERS)
        for i = 1:N
            print(io, '\\', d.d)
        end
    else
        for i = 1:N
            print(io, d.d)
        end
    end
end

function _show_content(io::IO, d::Delim)
    for c in d.d
        if c in keys(CONVERSION_SPECIFIERS)
            print(io, '\\')
        end
        print(io, c)
    end
end

function Base.show(io::IO, d::Delim)
    print(io, "Delim(")
    _show_content(io, d)
    print(io, ")")
end

### DateFormat construction

abstract type DayOfWeekToken end # special addition to Period types

# Map conversion specifiers or character codes to tokens.
# Note: Allow addition of new character codes added by packages
const CONVERSION_SPECIFIERS = Dict{Char,Type}(
    'y' => Year,
    's' => Semester,
    'q' => Quarter,
    'm' => Month,
    'u' => Month,
    'U' => Month,
    'w' => Week,
    'd' => Day,
)

# Default values are needed when a conversion specifier is used in a DateFormat for parsing
# and we have reached the end of the input string.
# Note: Allow `Any` value as a default to support extensibility
const CONVERSION_DEFAULTS = IdDict{Type,Any}(
    Year => Int64(1),
    Semester => Int64(1),
    Quarter => Int64(1),
    Month => Int64(1),
    Week => Int64(0),
    Day => Int64(1),
)

# Specifies the required fields in order to parse a TimeType
# Note: Allows for addition of new TimeTypes
const CONVERSION_TRANSLATIONS = IdDict{Type,Any}(
    Year => (Year,),
    Semester => (Year, Semester),
    Quarter => (Year, Quarter),
    Month => (Year, Month),
    Week => (Year, Week),
    Day => (Year, Month, Day),
    YearDate => (Year,),
    SemesterDate => (Year, Semester),
    QuarterDate => (Year, Quarter),
    MonthDate => (Year, Month),
    WeekDate => (Year, Week),
    DayDate => (Year, Month, Day),
)

"""
    SimpleDateFormat(format::AbstractString) -> SimpleDateFormat

Construct a period formatting object that can be used for parsing period strings or
formatting a period object as a string. The following character codes can be used to construct the `format`
string:

| Code       | Matches   | Comment                                                      |
|:-----------|:----------|:-------------------------------------------------------------|
| `y`        | 1996, 96  | Returns year of 1996, 0096                                   |
| `s`        | 1, 2      | Returns semester 1 or 2                                      |
| `q`        | 1, ..., 4 | Returns quarter 1, 2, 3, 4                                   |
| `m`        | 1, 01     | Matches 1 or 2-digit months                                  |
| `u`        | Jan       | Matches abbreviated months according to the `locale` keyword |
| `U`        | January   | Matches full month names according to the `locale` keyword   |
| `w`        | 1,..., 53 | Returns week 01 to 53                                        |
| `d`        | 1, 01     | Matches 1 or 2-digit days                                    |
| `yyyymmdd` | 19960101  | Matches fixed-width year, month, and day                     |

Characters not listed above are normally treated as delimiters between slots.
For example a `dt` string of "1996-Q1" would have a `format` string like
"y-Qq". If you need to use a code character as a delimiter you can escape it using
backslash. The date "1995y01m" would have the format "y\\ym\\m".

Creating a SimpleDateFormat object is expensive. Whenever possible, create it once and use it many times
or try the [`periodformat""`](@ref @periodformat_str) string macro. Using this macro creates the SimpleDateFormat
object once at macro expansion time and reuses it later. There are also several [pre-defined formatters](@ref
Common-Period-Formatters), listed later.

See [`DateTime`](@ref) and [`format`](@ref) for how to use a DateFormat object to parse and write Date strings
respectively.
"""
function SimpleDateFormat(f::AbstractString)
    tokens = AbstractPeriodToken[]
    prev = ()
    prev_offset = 1

    letters = String(collect(keys(CONVERSION_SPECIFIERS)))
    for m in eachmatch(Regex("(?<!\\\\)([\\Q$letters\\E])\\1*"), f)
        tran = replace(f[prev_offset:prevind(f, m.offset)], r"\\(.)" => s"\1")

        if !isempty(prev)
            letter, width = prev
            typ = CONVERSION_SPECIFIERS[letter]

            push!(tokens, PeriodPart{letter}(width, isempty(tran)))
        end

        if !isempty(tran)
            push!(tokens, Delim(length(tran) == 1 ? first(tran) : tran))
        end

        letter = f[m.offset]
        width = length(m.match)

        prev = (letter, width)
        prev_offset = m.offset + width
    end

    tran = replace(f[prev_offset:lastindex(f)], r"\\(.)" => s"\1")

    if !isempty(prev)
        letter, width = prev
        typ = CONVERSION_SPECIFIERS[letter]

        push!(tokens, PeriodPart{letter}(width, false))
    end

    if !isempty(tran)
        push!(tokens, Delim(length(tran) == 1 ? first(tran) : tran))
    end

    tokens_tuple = (tokens...,)
    return SimpleDateFormat{Symbol(f),typeof(tokens_tuple)}(tokens_tuple)
end

function Base.show(io::IO, pf::SimpleDateFormat)
    print(io, "periodformat\"")
    for t in pf.tokens
        _show_content(io, t)
    end
    print(io, '"')
end

Base.Broadcast.broadcastable(x::SimpleDateFormat) = Ref(x)

"""
    periodformat"Y-m-d"

Create a [`SimpleDateFormat`](@ref) object. Similar to `SimpleDateFormat("Y-m-d")`
but creates the DateFormat object once during macro expansion.

See [`SimpleDateFormat`](@ref) for details about format specifiers.
"""
macro periodformat_str(str)
    SimpleDateFormat(str)
end

default_format(::Type{Year}) = YearFormat
default_format(::Type{Semester}) = SemesterFormat
default_format(::Type{Quarter}) = QuarterFormat
default_format(::Type{Month}) = MonthFormat
default_format(::Type{Week}) = WeekFormat
default_format(::Type{Day}) = DayFormat
default_format(::Type{Undated}) = UndatedFormat

# Standard formats

"""
    Periods.YearFormat

# Example
```jldoctest
julia> Periods.format(Periods(2018, Year), YearFormat )
"2018"
```
"""
const YearFormat = SimpleDateFormat("yyyy")
"""
    Periods.SemesterFormat

# Example
```jldoctest
julia> Periods.format(Periods(2018, 1, Semester), SemesterFormat )
"2018-S1"
```
"""
const SemesterFormat = SimpleDateFormat("yyyy-Ss")
"""
    Periods.QuarterFormat

# Example
```jldoctest
julia> Periods.format(Periods(2018, 2, Quarter), QuarterFormat )
"2018-Q2"
```
"""
const QuarterFormat = SimpleDateFormat("yyyy-Qq")
"""
    Periods.MonthFormat

# Example
```jldoctest
julia> Periods.format(Periods(2018, 3, Month), MonthFormat )
"2018-03"
```
"""
const MonthFormat = SimpleDateFormat("yyyy-mm")
"""
    Periods.WeekFormat

# Example
```jldoctest
julia> Periods.format(Periods(2018, 4, Week), WeekFormat )
"2018-W04"
```
"""
const WeekFormat = SimpleDateFormat("yyyy-Www")
"""
    Periods.DayFormat

# Example
```jldoctest
julia> Periods.format(Periods(2018, 3, 11, Day), DayFormat )
"2018-03-11"
```
"""
const DayFormat = SimpleDateFormat("yyyy-mm-dd")

### API


"""
    SimpleDate(p::AbstractString, format::AbstractString) -> SimpleDate

Construct a `SimpleDate` by parsing the `p` period string following the pattern given
in the `format` string (see [`SimpleDateFormat`](@ref) for syntax).

!!! note
    This method creates a `SimpleDateFormat` object each time it is called. It is recommended
    that you create a [`SimpleDateFormat`](@ref) object instead and use that as the second
    argument to avoid performance loss when using the same format repeatedly.

# Example
```jldoctest
julia> SimpleDate("2020-01-01", "yyyy-mm-dd")
2020-01-01

julia> a = ("2020-01-01", "2020-01-02");

julia> [SimpleDate(p, dateformat"yyyy-mm-dd") for p ∈ a] # preferred
2-element Vector{SimpleDate}:
 2020-01-01
 2020-01-02
```
"""
function SimpleDate(p::AbstractString, format::AbstractString)
    parse(SimpleDate, p, SimpleDateFormat(format))
end

for TP in (:Year, :Semester, :Quarter, :Month, :Week, :Day, :Undated)
    sd = Symbol(TP, "Date")
    sf = Symbol(TP, "Format")
    @eval begin
        function $sd(p::AbstractString, format::AbstractString)
            parse($sd, p, SimpleDateFormat(format))
        end

        function $sd(p::AbstractString)
            parse($sd, p, $sf)
        end
    end
end

"""
    SimpleDate(p::AbstractString, pf::SimpleDateFormat) -> SimpleDate

Construct a `SimpleDate` by parsing the `p` period string following the
pattern given in the [`SimpleDateFormat`](@ref) object.

Similar to `SimpleDate(::AbstractString, ::AbstractString)` but more efficient when
repeatedly parsing similarly formatted period strings with a pre-created
`SimpleDateFormat` object.
"""
SimpleDate(p::AbstractString, pf::SimpleDateFormat) = parse(SimpleDate, p, pf)

for TP in
    (:YearDate, :SemesterDate, :QuarterDate, :MonthDate, :WeekDate, :DayDate, :UndatedDate)
    @eval begin
        @generated function format(io::IO, p::$TP, fmt::SimpleDateFormat{<:Any,T}) where {T}
            N = fieldcount(T)
            quote
                ts = fmt.tokens
                Base.@nexprs $N i -> format(io, ts[i], p)
            end
        end

        function format(p::$TP, fmt::SimpleDateFormat, bufsize = 10)
            # preallocate to reduce resizing
            io = IOBuffer(Vector{UInt8}(undef, bufsize), read = true, write = true)
            format(io, p, fmt)
            String(io.data[1:io.ptr-1])
        end
    end
end


"""
    format(p::SimpleDate, format::AbstractString) -> AbstractString

Construct a string by using a `SimpleDate` object and applying the provided `format`. The
following character codes can be used to construct the `format` string:

| Code       | Examples  | Comment                                                      |
|:-----------|:----------|:-------------------------------------------------------------|
| `y`        | 6         | Numeric year with a fixed width                              |
| `Y`        | 1996      | Numeric year with a minimum width                            |
| `m`        | 1, 12     | Numeric month with a minimum width                           |
| `u`        | Jan       | Month name shortened to 3-chars according to the `locale`    |
| `U`        | January   | Full month name according to the `locale` keyword            |
| `d`        | 1, 31     | Day of the month with a minimum width                        |
| `s`        | 1, 2      | Semester of the year                                         |
| `q`        | 1, 4      | Quarter of the year                                          |
| `w`        | 1, 53     | Week of the year with a minimum width                        |
The number of sequential code characters indicate the width of the code. A format of
`yyyy-mm` specifies that the code `y` should have a width of four while `m` a width of two.
Codes that yield numeric digits have an associated mode: fixed-width or minimum-width.
The fixed-width mode left-pads the value with zeros when it is shorter than the specified
width and truncates the value when longer. Minimum-width mode works the same as fixed-width
except that it does not truncate values longer than the width.

When creating a `format` you can use any non-code characters as a separator. For example to
generate the string "1996-Q1" you could use `format`: "yyyy-Qq".
Note that if you need to use a code character as a literal you can use the escape character
backslash. The string "1996y01m" can be produced with the format "yyyy\\ymm\\m".
"""

# show
function Base.print(io::IO, y::YearDate)
    format(io, y, YearFormat)
end

function Base.print(io::IO, s::SemesterDate)
    format(io, s, SemesterFormat)
end

function Base.print(io::IO, q::QuarterDate)
    format(io, q, QuarterFormat)
end

function Base.print(io::IO, m::MonthDate)
    format(io, m, MonthFormat)
end

function Base.print(io::IO, w::WeekDate)
    format(io, w, WeekFormat)
end

#function Base.print(io::IO, d::DayDate)
#    format(io, d, DayFormat)
#end

function Base.print(io::IO, u::UndatedDate)
    format(io, p, UndatedFormat)
end

function Base.print(io::IO, dd::DayDate)
    # don't use format - bypassing IOBuffer creation
    # saves a bit of time here.
    y, m, d = yearmonthday(dd)
    yy = y < 0 ? @sprintf("%05i", y) : lpad(y, 4, "0")
    mm = lpad(m, 2, "0")
    dd = lpad(d, 2, "0")
    print(io, "$yy-$mm-$dd")
end

for date_type in
    (:DayDate, :WeekDate, :MonthDate, :QuarterDate, :SemesterDate, :YearDate)
    # Human readable output (i.e. "2012-01-01")
    @eval Base.show(io::IO, ::MIME"text/plain", dt::$date_type) = print(io, dt)
    # Parsable output (i.e. Date("2012-01-01"))
    @eval Base.show(io::IO, dt::$date_type) = print(io, typeof(dt), "(\"", dt, "\")")
    # Parsable output will have type info displayed, thus it is implied
    @eval Base.typeinfo_implicit(::Type{$date_type}) = true
end

function simpleperiod(s::String) SimpleDate
    p = nothing
    try
        parts = split(s, '-')
        y = Base.parse(Int64, parts[1])
        if length(parts) == 1
            p = YearDate(y)
        elseif length(parts) == 2
            f = parts[2][1]
            if f == 'S'
                s = Base.parse(Int64, parts[2][2:end])
                p = SemesterDate(y, s)
            elseif f == 'Q'
                s = Base.parse(Int64, parts[2][2:end])
                p = QuarterDate(y, s)
            elseif f == 'W'
                s = Base.parse(Int64, parts[2][2:end])
                p = WeekDate(y, s)
            else
                s = Base.parse(Int64, parts[2])
                p = MonthDate(y, s)
            end
        elseif length(parts) == 3
            m = Base.parse(Int64, parts[2])
            d = Base.parse(Int64, parts[3])
            p = DayDate(y, m, d)
        else
            error("Can't parse $s")
        end
    catch
        error("Can't parse $s")
    end
    return p
end

simpleperiod(u::Int64) = UndatedDate(u)
