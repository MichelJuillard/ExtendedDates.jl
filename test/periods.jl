# This file is a part of Julia. License is MIT: https://julialang.org/license

module PeriodsTest

import Dates
using ExtendedDates
using Test

@testset "basic arithmetic" begin
    @test -Year(1) == Year(-1)
    @test Year(1) > Year(0)
    @test (Year(1) < Year(0)) == false
    @test Year(1) == Year(1)
    @test Year(1) != 1
    @test Year(1) + Year(1) == Year(2)
    @test Year(1) - Year(1) == zero(Year)
    @test 1 == one(Year)
    @test_throws MethodError Year(1) * Year(1) == Year(1)
    t = Year(1)
    t2 = Year(2)
    @test ([t, t, t, t, t] .+ Year(1)) == ([t2, t2, t2, t2, t2])
    @test (Year(1) .+ [t, t, t, t, t]) == ([t2, t2, t2, t2, t2])
    @test ([t2, t2, t2, t2, t2] .- Year(1)) == ([t, t, t, t, t])
    @test_throws MethodError ([t, t, t, t, t] .* Year(1)) == ([t, t, t, t, t])
    @test ([t, t, t, t, t] * 1) == ([t, t, t, t, t])
    @test ([t, t, t, t, t] .% t2) == ([t, t, t, t, t])
    @test div.([t, t, t, t, t], Year(1)) == ([1, 1, 1, 1, 1])
    @test mod.([t, t, t, t, t], Year(2)) == ([t, t, t, t, t])
    @test [t, t, t] / t2 == [0.5, 0.5, 0.5]
    @test abs(-t) == t
    @test sign(t) == sign(t2) == 1
    @test sign(-t) == sign(-t2) == -1
    @test sign(Year(0)) == 0
end
@testset "div/mod/gcd/lcm/rem" begin
    @test Year(10) % Year(4) == Year(2)
    @test gcd(Year(10), Year(4)) == Year(2)
    @test lcm(Year(10), Year(4)) == Year(20)
    @test div(Year(10), Year(3)) == 3
    @test div(Year(10), Year(4)) == 2
    @test div(Year(10), 4) == Year(2)
    @test Year(10) / Year(4) == 2.5

    @test mod(Year(10), Year(4)) == Year(2)
    @test mod(Year(-10), Year(4)) == Year(2)
    @test mod(Year(10), 4) == Year(2)
    @test mod(Year(-10), 4) == Year(2)

    @test rem(Year(10), Year(4)) == Year(2)
    @test rem(Year(-10), Year(4)) == Year(-2)
    @test rem(Year(10), 4) == Year(2)
    @test rem(Year(-10), 4) == Year(-2)
end

y = Year(1)
q = Quarter(1)
m = Month(1)
w = Week(1)
d = Day(1)
emptyperiod = ((y + d) - d) - y
@testset "Period arithmetic" begin
    @test Year(y) == y
    @test Quarter(q) == q
    @test Month(m) == m
    @test Week(w) == w
    @test Day(d) == d
    @test Year(convert(Int8, 1)) == y
    @test Year(convert(UInt8, 1)) == y
    @test Year(convert(Int16, 1)) == y
    @test Year(convert(UInt16, 1)) == y
    @test Year(convert(Int32, 1)) == y
    @test Year(convert(UInt32, 1)) == y
    @test Year(convert(Int64, 1)) == y
    @test Year(convert(UInt64, 1)) == y
    @test Year(convert(Int128, 1)) == y
    @test Year(convert(UInt128, 1)) == y
    @test Year(convert(BigInt, 1)) == y
    @test Year(convert(BigFloat, 1)) == y
    @test Year(convert(Complex, 1)) == y
    @test Year(convert(Rational, 1)) == y
    @test Year(convert(Float16, 1)) == y
    @test Year(convert(Float32, 1)) == y
    @test Year(convert(Float64, 1)) == y
    @test y == y
    @test m == m
    @test w == w
    @test d == d
    y2 = Year(2)
    @test y < y2
    @test y2 > y
    @test y != y2

    @test Year(Int8(1)) == y
    @test Year(UInt8(1)) == y
    @test Year(Int16(1)) == y
    @test Year(UInt16(1)) == y
    @test Year(Int(1)) == y
    @test Year(UInt(1)) == y
    @test Year(Int64(1)) == y
    @test Year(UInt64(1)) == y
    @test Year(UInt128(1)) == y
    @test Year(UInt128(1)) == y
    @test Year(big(1)) == y
    @test Year(BigFloat(1)) == y
    @test Year(float(1)) == y
    @test Year(Float32(1)) == y
    @test Year(Rational(1)) == y
    @test Year(complex(1)) == y
    @test_throws InexactError Year(BigFloat(1.2)) == y
    @test_throws InexactError Year(1.2) == y
    @test_throws InexactError Year(Float32(1.2)) == y
    @test_throws InexactError Year(3 // 4) == y
    @test_throws InexactError Year(complex(1.2)) == y
    @test_throws InexactError Year(Float16(1.2)) == y
    @test Year(true) == y
    @test Year(false) != y
    @test_throws MethodError Year(:hey) == y
    @test Year(real(1)) == y
    @test_throws InexactError Year(m) == y
    @test_throws MethodError Year(w) == y
    @test_throws MethodError Year(d) == y
    @test Year(Date(2013, 1, 1)) == Year(2013)
    @test Year(DateTime(2013, 1, 1)) == Year(2013)
    @test typeof(y + m) <: Dates.CompoundPeriod
    @test typeof(m + y) <: Dates.CompoundPeriod
    @test typeof(y + w) <: Dates.CompoundPeriod
    @test typeof(y + d) <: Dates.CompoundPeriod
    @test y > m
    @test d < w
    @test typemax(Year) == Year(typemax(Int64))
    @test typemax(Year) + y == Year(-9223372036854775808)
    @test typemin(Year) == Year(-9223372036854775808)
end
@testset "Period-Real arithmetic" begin
    @test_throws MethodError y + 1 == Year(2)
    @test_throws MethodError y + true == Year(2)
    @test_throws InexactError y + Year(1.2)
    @test y + Year(1.0f0) == Year(2)
    @test y * 4 == Year(4)
    @test y * 4.0f0 == Year(4)
    @test Year(2) * 0.5 == y
    @test Year(2) * 3 // 2 == Year(3)
    @test_throws InexactError y * 0.5
    @test_throws InexactError y * 3 // 4
    @test Year(4) / 2 == Year(2)
    @test Year(4) / 2.0f0 == Year(2)
    @test Year(4) / 0.5 == Year(8)
    @test Year(4) / 2 // 3 == Year(6)
    @test_throws InexactError Year(4) / 3.0
    @test_throws InexactError Year(4) / 3 // 2
    @test div(y, 2) == Year(0)
    @test_throws MethodError div(2, y) == Year(2)
    @test div(y, y) == 1
    @test y * 10 % Year(5) == Year(0)
    @test_throws MethodError (y > 3) == false
    @test_throws MethodError (4 < y) == false
    @test 1 != y
    t = [y, y, y, y, y]
    @test t .+ Year(2) == [Year(3), Year(3), Year(3), Year(3), Year(3)]

    let x = Year(5), y = Year(2)
        @test div(x, y) * y + rem(x, y) == x
        @test fld(x, y) * y + mod(x, y) == x
    end
end
@testset "Associativity" begin
    dt = DayDate(2012, 12, 21)
    test = ((((dt + y) - m) + w) - d)
    @test test == dt + y - m + w - d
    @test test == y - m + w - d + dt
    @test test == dt - m + y - d + w
    @test test == dt + (y - m + w - d)
    @test test == dt + y - m + w - d
    @test (dt + Year(4)) + Day(1) == dt + (Year(4) + Day(1))
    @test DayDate(2014, 1, 29) + Month(1) + Day(1) + Month(1) + Day(1) ==
          DayDate(2014, 1, 29) + Day(1) + Month(1) + Month(1) + Day(1)
    @test DayDate(2014, 1, 29) + Month(1) + Day(1) ==
          DayDate(2014, 1, 29) + Day(1) + Month(1)
end
@testset "traits" begin
    @test ExtendedDates._units(Year(0)) == " years"
    @test ExtendedDates._units(Year(1)) == " year"
    @test ExtendedDates._units(Year(-1)) == " year"
    @test ExtendedDates._units(Year(2)) == " years"
    @test string(Year(0)) == "0 years"
    @test string(Year(1)) == "1 year"
    @test string(Year(-1)) == "-1 year"
    @test string(Year(2)) == "2 years"
    @test isfinite(Year)
    @test isfinite(Year(0))
    @test zero(Year) == Year(0)
    @test zero(Year(10)) == Year(0)
    @test zero(Month) == Month(0)
    @test zero(Month(10)) == Month(0)
    @test zero(Day) == Day(0)
    @test zero(Day(10)) == Day(0)
    @test Year(-1) < Year(1)
    @test !(Year(-1) > Year(1))
    @test Year(1) == Year(1)
    @test Year(1) != 1
    @test 1 != Year(1)
    @test Month(-1) < Month(1)
    @test !(Month(-1) > Month(1))
    @test Month(1) == Month(1)
    @test Day(-1) < Day(1)
    @test !(Day(-1) > Day(1))
    @test Day(1) == Day(1)

    # issue #27076
    @test Year(1) != Dates.Millisecond(1)
    @test Dates.Millisecond(1) != Year(1)
end


@testset "basic properties" begin
    @test Year("1") == y
    @test Quarter("1") == q
    @test Month("1") == m
    @test Week("1") == w
    @test Day("1") == d
    @test_throws ArgumentError Year("1.0")
    @test Year(parse(Float64, "1.0")) == y

    dt = DayDate(2014)
    @test typeof(Year(dt)) <: Year
    @test typeof(Quarter(dt)) <: Quarter
    @test typeof(Month(dt)) <: Month
    @test typeof(Week(dt)) <: Week
    @test typeof(Day(dt)) <: Day
end
@testset "Default values" begin
    @test ExtendedDates.default(Year) == y
    @test ExtendedDates.default(Quarter) == q
    @test ExtendedDates.default(Month) == m
    @test ExtendedDates.default(Week) == w
    @test ExtendedDates.default(Day) == d
end
@testset "Conversions" begin
    @test ExtendedDates.days(d) == 1
    @test ExtendedDates.days(w) == 7
end
@testset "issue #9214" begin
    @test emptyperiod == ((d + y) - y) - d == ((d + y) - d) - y
    @test string(emptyperiod) == "empty period"
    @test y - m == 11m
end
@testset "compound periods and types" begin
    # compound periods should avoid automatically converting period types
    @test sprint(show, y + m) == string(y + m)
    @test convert(Dates.CompoundPeriod, y) + m == y + m
    if VERSION >= v"1.7"
        @test Dates.periods(convert(Dates.CompoundPeriod, y)) ==
            convert(Dates.CompoundPeriod, y).periods
    end
end
@testset "compound period simplification" begin
    # reduce compound periods into the most basic form
    @test Dates.canonicalize(-y + d).periods == Period[-y, d]
    @test Dates.canonicalize(-y + m - w + d).periods == Period[-11m, -6d]
    @test DayDate(2009, 2, 1) - (Month(1) + Day(1)) == DayDate(2008, 12, 31)
    @test_throws MethodError (Month(1) + Day(1)) - DayDate(2009, 2, 1)
end

@testset "Dates.canonicalize Period" begin
    # reduce individual Period into most basic Dates.CompoundPeriod
    @test Dates.canonicalize(Day(7)) == Dates.canonicalize(Week(1))
    @test Dates.canonicalize(Month(12)) == Dates.canonicalize(Year(1))
    Dates.canonicalize(Dates.CompoundPeriod([Day(1), Hour(12)]))
end
@testset "unary ops and vectorized period arithmetic" begin
    pa = [1y 1m 1w 1d]
    cpa = [1y 1m 1w 1d]

    @test +pa == pa == -(-pa)
    @test -pa == map(-, pa)
    @test 1y .+ pa == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test (1y + 1m) .+ pa == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]
    @test pa .+ 1y == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test pa .+ (1y + 1m) == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]

    @test 1y .+ cpa == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test (1y + 1m) .+ cpa == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]
    @test cpa .+ 1y == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test cpa .+ (1y + 1m) == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]

    @test 1y .+ pa == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test (1y + 1m) .+ pa == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]
    @test pa .+ 1y == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test pa .+ (1y + 1m) == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]

    @test 1y .+ cpa == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test (1y + 1m) .+ cpa == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]
    @test cpa .+ 1y == [2y 1y + 1m 1y + 1w 1y + 1d]
    @test cpa .+ (1y + 1m) == [2y + 1m 1y + 2m 1y + 1m + 1w 1y + 1m + 1d]

    @test 1y .- pa == [0y 1y - 1m 1y - 1w 1y - 1d]
    @test (1y + 1m) .- pa == [1m 1y 1y + 1m - 1w 1y + 1m - 1d]
    @test pa .- (1y + 1m) == [-1m -1y -1y - 1m + 1w -1y - 1m + 1d]
    @test pa .- 1y == [0y 1m - 1y -1y + 1w -1y + 1d]

    @test 1y .- cpa == [0y 1y - 1m 1y - 1w 1y - 1d]
    @test (1y + 1m) .- cpa == [1m 1y 1y + 1m - 1w 1y + 1m - 1d]
    @test cpa .- 1y == [0y -1y + 1m -1y + 1w -1y + 1d]
    @test cpa .- (1y + 1m) == [-1m -1y -1y - 1m + 1w -1y - 1m + 1d]


    @test [1y 1m; 1w 1d] + [1y 1y; 1y 1y] == [2y 1y+1m; 1y+1w 1y+1d]
    @test [1y 1m; 1w 1d] - [1y 1y; 1y 1y] == [0y 1m-1y; 1w-1y 1d-1y]
end
@testset "Equality and hashing between OtherPeriod types" begin
    for x in (0, 1, 235, -4677, 15250)
        local x, y, z
        y = Year(x)
        z = convert(Month, y)
        @test y == z
        @test hash(y) == hash(z)

        y = Quarter(x)
        z = convert(Month, y)
        @test y == z
        @test hash(y) == hash(z)

        y = Year(x)
        z = convert(Quarter, y)
        @test y == z
        @test hash(y) == hash(z)
    end
end
@testset "Equality and hashing between FixedPeriod/OtherPeriod/Dates.CompoundPeriod (#37459)" begin
    function test_hash_equality(x, y)
        @test x == y
        @test y == x
        @test isequal(x, y)
        @test isequal(y, x)
        @test hash(x) == hash(y)
    end
    for FP in (Week, Day)
        for OP in (Year, Quarter, Month)
            test_hash_equality(FP(0), OP(0))
        end
    end
end

@testset "CompoundPeriod and Period isless()" begin
    #tests for allowed comparisons
    #OtherPeriod
    @test (2y - m < 25m + 1y) == true
    @test (2y < 25m + 1y) == true
    @test (25m + 1y < 2y) == false
end

if VERSION >= v"1.7"
    @testset "Convert CompoundPeriod to Period" begin
        @test convert(Month, Year(1) + Month(1)) === Month(13)
    end
end

end
