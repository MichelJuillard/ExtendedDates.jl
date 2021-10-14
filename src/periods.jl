# The default constructors for Periods work well in almost all cases
# P(x) = new((convert(Int64,x))
# The following definitions are for Period-specific safety
for period in (:Year, :Semester, :Quarter, :Month, :Week, :Day)
    period_str = string(period)
    accessor_str = lowercase(period_str)
    # Convenience method for show()
    @eval _units(x::$period) = " " * $accessor_str * (abs(value(x)) == 1 ? "" : "s")
    # periodisless
    @eval periodisless(x::$period, y::$period) = value(x) < value(y)
    # AbstractString parsing (mainly for IO code)
    @eval $period(x::AbstractString) = $period(Base.parse(Int64, x))
    # The period type is printed when output, thus it already implies its own typeinfo
    @eval Base.typeinfo_implicit(::Type{$period}) = true
    # Period accessors
    typs = [:YearDate, :SemesterDate, :QuarterDate, :MonthDate, :WeekDate, :DayDate]
    reference =
        period === :Week ?
        " For details see [`$accessor_str(::Union{Date, DateTime})`](@ref)." : ""
    for typ_str in typs
        @eval begin
            @doc """
                $($period_str)(dt::$($typ_str)) -> $($period_str)

            The $($accessor_str) part of a $($typ_str) as a `$($period_str)`.$($reference)
            """ $period(dt::$(Symbol(typ_str))) = $period($(Symbol(accessor_str))(dt))
        end
    end
    @eval begin
        @doc """
            $($period_str)(v)

        Construct a `$($period_str)` object with the given `v` value. Input must be
        losslessly convertible to an [`Int64`](@ref).
        """ $period(v)
    end
end

_units(y::Year) = " year" * (abs(value(y)) == 1 ? "" : "s")
_units(s::Semester) = " semester" * (abs(value(s)) == 1 ? "" : "s")
_units(q::Quarter) = " quarter" * (abs(value(q)) == 1 ? "" : "s")
_units(m::Month) = " month" * (abs(value(m)) == 1 ? "" : "s")
_units(w::Week) = " week" * (abs(value(w)) == 1 ? "" : "s")
_units(d::Day) = " day" * (abs(value(d)) == 1 ? "" : "s")
_units(u::Undated) = ""

#Print/show/traits
Base.print(io::IO, x::Period) = print(io, value(x), _units(x))
Base.show(io::IO, ::MIME"text/plain", x::Period) = print(io, x)
Base.show(io::IO, p::P) where {P<:Period} = print(io, P, '(', value(p), ')')

days(c::Semester) = 182.62125 * value(c)
# See https://en.wikipedia.org/wiki/ISO_week_date
# There are 20871 weeks in 400 years
weeks(c::Day) = div(value(c), 7)
weeks(c::Week) = value(c)
weeks(c::Month) = 4.348125 * value(c)
weeks(c::Quarter) = 13.044375 * value(c)
weeks(c::Semester) = 26.08875 * value(c)
weeks(c::Year) = 52.1775 * value(c)
months(c::Day) = div(value(c), 30.436875)
months(c::Week) = div(value(c), 4.34812)
months(c::Month) = value(c)
months(c::Quarter) = 3 * value(c)
months(c::Semester) = 6 * value(c)
months(c::Year) = 12 * value(c)
quarters(c::Day) = div(value(c), 91.310625)
quarters(c::Week) = div(value(c), 13.044385)
quarters(c::Month) = div(value(c), 3)
quarters(c::Quarter) = value(c)
quarters(c::Semester) = 2 * value(c)
quarters(c::Year) = 4 * value(c)
semesters(c::Day) = div(value(c), 182.62125)
semesters(c::Week) = div(value(c), 26.08877)
semesters(c::Month) = div(value(c), 6)
semesters(c::Quarter) = div(value(c), 2)
semesters(c::Semester) = value(c)
semesters(c::Year) = 2 * value(c)
years(c::Day) = div(value(c), 365.2425)
years(c::Week) = div(value(c), 52.1775)
years(c::Month) = div(value(c), 12)
years(c::Quarter) = div(value(c), 4)
years(c::Semester) = div(value(c), 2)
years(c::Year) = value(c)

# Default values (as used by SimplePeriods)
"""
    default(p::Period) -> Period

Returns a sensible "default" value for the input Period by returning `T(1)` for Year,
Semeter, Quarter, Month, Day and Undated.
"""
function default end

default(p::Union{T,Type{T}}) where {T<:Dates.DatePeriod} = T(1)

# like div but throw an error if remainder is nonzero
function divexact(x, y)
    q, r = divrem(x, y)
    r == 0 || throw(InexactError(:divexact, Int, x / y))
    return q
end

# other periods with fixed conversions but which aren't fixed time periods
const OtherPeriod = Union{Month,Quarter,Semester,Year}
let vmax = typemax(Int64) ÷ 12, vmin = typemin(Int64) ÷ 12
    @eval function Base.convert(::Type{Month}, x::Year)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Month, x))
        Month(value(x) * 12)
    end
end
Base.convert(::Type{Year}, x::Month) = Year(divexact(value(x), 12))
Base.promote_rule(::Type{Year}, ::Type{Month}) = Month

let vmax = typemax(Int64) ÷ 4, vmin = typemin(Int64) ÷ 4
    @eval function Base.convert(::Type{Quarter}, x::Year)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Quarter, x))
        Quarter(value(x) * 4)
    end
end
Base.convert(::Type{Year}, x::Quarter) = Year(divexact(value(x), 4))
Base.promote_rule(::Type{Year}, ::Type{Quarter}) = Quarter

let vmax = typemax(Int64) ÷ 3, vmin = typemin(Int64) ÷ 3
    @eval function Base.convert(::Type{Month}, x::Quarter)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Month, x))
        Month(value(x) * 3)
    end
end
Base.convert(::Type{Quarter}, x::Month) = Quarter(divexact(value(x), 3))
Base.promote_rule(::Type{Quarter}, ::Type{Month}) = Month

let vmax = typemax(Int64) ÷ 2, vmin = typemin(Int64) ÷ 2
    @eval function Base.convert(::Type{Semester}, x::Year)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Semester, x))
        Semester(value(x) * 2)
    end
end
Base.convert(::Type{Year}, x::Semester) = Year(divexact(value(x), 2))
Base.promote_rule(::Type{Year}, ::Type{Semester}) = Semester

let vmax = typemax(Int64) ÷ 2, vmin = typemin(Int64) ÷ 2
    @eval function Base.convert(::Type{Quarter}, x::Semester)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Quarter, x))
        Quarter(value(x) * 2)
    end
end
Base.convert(::Type{Semester}, x::Quarter) = Semester(divexact(value(x), 2))
Base.promote_rule(::Type{Semester}, ::Type{Quarter}) = Quarter

let vmax = typemax(Int64) ÷ 6, vmin = typemin(Int64) ÷ 6
    @eval function Base.convert(::Type{Month}, x::Semester)
        $vmin ≤ value(x) ≤ $vmax || throw(InexactError(:convert, Month, x))
        Month(value(x) * 6)
    end
end
Base.convert(::Type{Semester}, x::Month) = Semester(divexact(value(x), 6))
Base.promote_rule(::Type{Semester}, ::Type{Month}) = Month

Base.convert(::Type{Year}, x::Int64) = Year(x)
Base.convert(::Type{Semester}, x::Int64) = Semester(x)
Base.convert(::Type{Quarter}, x::Int64) = Quarter(x)
Base.convert(::Type{Month}, x::Int64) = Month(x)
Base.convert(::Type{Week}, x::Int64) = Week(x)
Base.convert(::Type{Day}, x::Int64) = Day(x)
Base.convert(::Type{Undated}, x::Int64) = Undated(x)

const zero_or_fixedperiod_seed = UInt === UInt64 ? 0x5b7fc751bba97516 : 0xeae0fdcb
const nonzero_otherperiod_seed = UInt === UInt64 ? 0xe1837356ff2d2ac9 : 0x170d1b00
otherperiod_seed(x::OtherPeriod) =
    iszero(value(x)) ? zero_or_fixedperiod_seed : nonzero_otherperiod_seed

Base.hash(x::Year, h::UInt) = hash(12 * value(x), h + otherperiod_seed(x))
Base.hash(x::Semester, h::UInt) = hash(6 * value(x), h + otherperiod_seed(x))
Base.hash(x::Quarter, h::UInt) = hash(3 * value(x), h + otherperiod_seed(x))
Base.hash(x::Month, h::UInt) = hash(value(x), h + otherperiod_seed(x))
