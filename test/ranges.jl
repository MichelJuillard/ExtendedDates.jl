# This file is a part of Julia. License is MIT: https://julialang.org/license

module RangesTest

import Dates
using Test
using ExtendedDates

using InteractiveUtils: subtypes

let
    YD = YearDate
    SD = SemesterDate
    QD = QuarterDate
    MD = MonthDate
    WD = WeekDate
    DD = DayDate
    UD = UndatedDate
    for (f1, l1, f2, l2, f3, l3, f4, l4, period) in (
        (
            YD(2014),
            YD(2013),
            YD(2014),
            YD(2014),
            YD(-20),
            YD(20),
            typemin(YD),
            typemax(YD),
            (Dates.Year,),
        ),
        (
            SD(2014, 1),
            SD(2013, 1),
            SD(2014, 1),
            SD(2014, 1),
            SD(-2000, 1),
            SD(2000, 1),
            typemin(SD),
            typemax(SD),
            (Dates.Year, Semester),
        ),
        (
            QD(2014, 1),
            QD(2013, 1),
            QD(2014, 1),
            QD(2014, 1),
            QD(-2000, 1),
            QD(2000, 1),
            typemin(QD),
            typemax(QD),
            (Dates.Year, Semester, Dates.Quarter),
        ),
        (
            MD(2014, 1),
            MD(2013, 1),
            MD(2014, 1),
            MD(2014, 1),
            MD(-2000, 1),
            MD(2000, 1),
            typemin(MD),
            typemax(MD),
            (Dates.Year, Semester, Dates.Quarter, Dates.Month),
        ),
        (
            WD(2014, 1),
            WD(2013, 1),
            WD(2014, 1),
            WD(2014, 1),
            WD(1, 1),
            WD(2000, 1),
            typemin(WD),
            typemax(WD),
            (Dates.Week,),
        ),
        (
            DD(2014, 1, 1),
            DD(2013, 1, 1),
            DD(2014, 1, 1),
            DD(2014, 1, 1),
            DD(-2000, 1, 1),
            DD(2000, 1, 1),
            typemin(DD),
            typemax(DD),
            (Dates.Year, Semester, Dates.Quarter, Dates.Month, Dates.Week, Dates.Day),
        ),
        (
            UD(2014),
            UD(2013),
            UD(2014),
            UD(2014),
            UD(-2000),
            UD(2000),
            typemin(UD),
            typemax(UD),
            (Undated,),
        ),
    )

        for P in period
            for pos_step in (P(1), P(2), P(50), P(2048), P(10000))
                # empty range
                dr = f1:pos_step:l1
                len = length(dr)
                @test len == 0
                @test isa(len, Int64)
                @test isempty(dr)
                @test first(dr) == f1
                @test last(dr) < f1
                @test length([i for i in dr]) == 0
                @test_throws ArgumentError minimum(dr)
                @test_throws ArgumentError maximum(dr)
                @test_throws BoundsError dr[1]
                @test findall(in(dr), dr) == Int64[]
                @test [dr;] == typeof(f1)[]
                @test isempty(reverse(dr))
                @test length(reverse(dr)) == 0
                @test first(reverse(dr)) < f1
                @test last(reverse(dr)) >= f1
                @test issorted(dr)
                @test sortperm(dr) === StepRange{Int64,Int}(1:1:0)
                @test !(f1 in dr)
                @test !(l1 in dr)
                @test !(f1 - pos_step in dr)
                @test !(l1 + pos_step in dr)
                @test dr == []
                @test hash(dr) == hash([])

                for (f, l) in ((f2, l2), (f3, l3))# , (f4, l4))
                    dr = f:pos_step:l
                    len = length(dr)
                    @test len > 0
                    @test isa(len, Int64)
                    @test !isempty(dr)
                    @test first(dr) == f
                    @test last(dr) <= l
                    @test minimum(dr) == first(dr)
                    @test maximum(dr) == last(dr)
                    @test dr[1] == f
                    @test dr[end] <= l
                    @test iterate(dr) == (first(dr), (length(dr), 1))
                    if len < 10#000
                        dr1 = [i for i in dr]
                        @test length(dr1) == len
                        @test findall(in(dr), dr) == [1:len;]
                        @test length([dr;]) == len
                        @test dr == dr1
                        @test hash(dr) == hash(dr1)
                    end
                    @test !isempty(reverse(dr))
                    @test length(reverse(dr)) == len
                    @test last(reverse(dr)) == f
                    @test issorted(dr)
                    @test f in dr
                end
            end

            for neg_step in (P(-1), P(-2), P(-50), P(-2048), P(-10000))
                # empty range
                dr = l1:neg_step:f1
                len = length(dr)
                @test len == 0
                @test isa(len, Int64)
                @test isempty(dr)
                @test first(dr) == l1
                @test last(dr) > l1
                @test length([i for i in dr]) == 0
                @test_throws ArgumentError minimum(dr)
                @test_throws ArgumentError maximum(dr)
                @test_throws BoundsError dr[1]
                @test findall(in(dr), dr) == Int64[]
                @test [dr;] == typeof(f1)[]
                @test isempty(reverse(dr))
                @test length(reverse(dr)) == 0
                @test first(reverse(dr)) > l1
                @test last(reverse(dr)) <= l1
                @test issorted(dr)
                @test sortperm(dr) === StepRange{Int64,Int}(1:1:0)
                @test !(l1 in dr)
                @test !(l1 in dr)
                @test !(l1 - neg_step in dr)
                @test !(l1 + neg_step in dr)
                @test dr == []
                @test hash(dr) == hash([])

                for (f, l) in ((f2, l2), (f3, l3))#, (f4, l4))
                    dr = l:neg_step:f
                    len = length(dr)
                    @test len > 0
                    @test isa(len, Int64)
                    @test !isempty(dr)
                    @test first(dr) == l
                    @test last(dr) >= f
                    @test minimum(dr) == last(dr)
                    @test maximum(dr) == first(dr)
                    @test dr[1] == l
                    @test dr[end] >= f
                    @test iterate(dr) == (first(dr), (length(dr), 1))

                    if len < 10000
                        dr1 = [i for i in dr]
                        @test length(dr1) == len
                        @test findall(in(dr), dr) == [1:len;]
                        @test length([dr;]) == len
                        @test dr == dr1
                        @test hash(dr) == hash(dr1)
                    end
                    @test !isempty(reverse(dr))
                    @test length(reverse(dr)) == len
                    @test issorted(dr) == (len <= 1)
                    @test l in dr
                end
            end
        end
    end
end

# Dates are physical units, and ranges should require an explicit step.
# See #19896 and https://discourse.julialang.org/t/type-restriction-on-unitrange/6557/12
if VERSION >= v"1.7.0"
    @test_throws MethodError DayDate(2013, 1, 1):DayDate(2013, 2, 1)
end

# All the range representations we want to test
# Date ranges
dr = DayDate(2013, 1, 1):Day(1):DayDate(2013, 2, 1)
dr1 = DayDate(2013, 1, 1):Day(1):DayDate(2013, 1, 1)
dr2 = DayDate(2013, 1, 1):Day(1):DayDate(2012, 2, 1) # empty range
dr3 = DayDate(2013, 1, 1):Day(-1):DayDate(2012) # negative step
# Big ranges
dr4 = DayDate(0):Day(1):DayDate(20000, 1, 1)
dr5 = DayDate(0):Day(1):DayDate(200000, 1, 1)
dr6 = DayDate(0):Day(1):DayDate(2000000, 1, 1)
dr7 = DayDate(0):Day(1):DayDate(20000000, 1, 1)
dr8 = DayDate(0):Day(1):DayDate(200000000, 1, 1)
dr9 = typemin(DayDate):Day(1):typemax(DayDate)
# Other steps
dr10 = typemax(DayDate):Day(-1):typemin(DayDate)
dr11 = typemin(DayDate):Week(1):typemax(DayDate)

dr12 = typemin(DayDate):Month(1):typemax(DayDate)
dr13 = typemin(DayDate):Year(1):typemax(DayDate)

dr14 = typemin(DayDate):Week(10):typemax(DayDate)
dr15 = typemin(DayDate):Month(100):typemax(DayDate)
dr16 = typemin(DayDate):Year(1000):typemax(DayDate)
dr17 = typemax(DayDate):Week(-10000):typemin(DayDate)
dr18 = typemax(DayDate):Month(-100000):typemin(DayDate)
dr19 = typemax(DayDate):Year(-1000000):typemin(DayDate)
dr20 = typemin(DayDate):Day(2):typemax(DayDate)

drs = Any[
    dr,
    dr1,
    dr2,
    dr3,
    dr4,
    dr5,
    dr6,
    dr7,
    dr8,
    dr9,
    dr10,
    dr11,
    dr12,
    dr13,
    dr14,
    dr15,
    dr16,
    dr17,
    dr18,
    dr19,
    dr20,
]
drs2 = map(x -> DayDate(first(x)):step(x):DayDate(last(x)), drs)

@test map(length, drs) == map(x -> size(x)[1], drs)
@test map(length, drs) == map(x -> length(DayDate(first(x)):step(x):DayDate(last(x))), drs)
@test map(length, drs) == map(x -> length(reverse(x)), drs)
@test all(x -> findall(in(x), x) == [1:length(x);], drs[1:4])
@test isempty(dr2)
@test all(x -> reverse(x) == range(last(x), step = -step(x), length = length(x)), drs)
@test all(x -> minimum(x) == (step(x) < zero(step(x)) ? last(x) : first(x)), drs[4:end])
@test all(x -> maximum(x) == (step(x) < zero(step(x)) ? first(x) : last(x)), drs[4:end])
@test all(drs[1:3]) do dd
    for (i, d) in enumerate(dd)
        @test d == (first(dd) + Day(i - 1))
    end
    true
end
@test_throws MethodError dr .+ 1
a = DayDate(2013, 1, 1)
b = DayDate(2013, 2, 1)
@test map!(x -> x + Day(1), Vector{DayDate}(undef, 32), dr) ==
      [(a+Day(1)):Day(1):(b+Day(1));]
@test map(x -> x + Day(1), dr) == [(a+Day(1)):Day(1):(b+Day(1));]

@test map(x -> a in x, drs[1:4]) == [true, true, false, true]
@test a in dr
@test b in dr
@test DayDate(2013, 1, 3) in dr
@test DayDate(2013, 1, 15) in dr
@test DayDate(2013, 1, 26) in dr
@test !(DayDate(2012, 1, 1) in dr)

@test all(x -> sort(x) == (step(x) < zero(step(x)) ? reverse(x) : x), drs)
@test all(x -> step(x) < zero(step(x)) ? issorted(reverse(x)) : issorted(x), drs)

@test length(b:Day(-1):a) == 32
@test length(b:Day(1):a) == 0
@test length(b:Day(1):a) == 0
@test length(a:Day(2):b) == 16
@test last(a:Day(2):b) == DayDate(2013, 1, 31)
@test length(a:Day(7):b) == 5
@test last(a:Day(7):b) == DayDate(2013, 1, 29)
@test length(a:Day(32):b) == 1
@test last(a:Day(32):b) == DayDate(2013, 1, 1)
@test (a:Day(1):b)[1] == DayDate(2013, 1, 1)
@test (a:Day(1):b)[2] == DayDate(2013, 1, 2)
@test (a:Day(1):b)[7] == DayDate(2013, 1, 7)
@test (a:Day(1):b)[end] == b
@test first(a:Day(1):DayDate(20000, 1, 1)) == a
@test first(a:Day(1):DayDate(200000, 1, 1)) == a
@test first(a:Day(1):DayDate(2000000, 1, 1)) == a
@test first(a:Day(1):DayDate(20000000, 1, 1)) == a
@test first(a:Day(1):DayDate(200000000, 1, 1)) == a
@test first(a:Day(1):typemax(DayDate)) == a
@test first(typemin(DayDate):Day(1):typemax(DayDate)) == typemin(DayDate)

@test length(typemin(DayDate):Week(1):typemax(DayDate)) == 26351950414948059
# Big Month/Year ranges
@test length(typemin(DayDate):Month(1):typemax(DayDate)) == 6060531933867600
@test length(typemin(DayDate):Year(1):typemax(DayDate)) == 505044327822300

c = DayDate(2013, 6, 1)
@test length(a:Month(1):c) == 6
@test [a:Month(1):c;] == [a + Month(1) * i for i = 0:5]
@test [a:Month(2):DayDate(2013, 1, 2);] == [a]
@test [c:Month(-1):a;] == reverse([a:Month(1):c;])

@test length(range(Date(2000), step = Day(1), length = 366)) == 366
let n = 100000
    local a = DayDate(2000)
    for i = 1:n
        @test length(range(a, step = Day(1), length = i)) == i
    end
    return a + Day(n)
end

@test typeof(step(DayDate(2000):Day(1):DayDate(2001))) == Day

a = DayDate(2013, 1, 1)
b = DayDate(2013, 2, 1)
d = DayDate(2020, 1, 1)
@test length(a:Year(1):d) == 8
@test first(a:Year(1):d) == a
@test last(a:Year(1):d) == d
@test length(a:Month(12):d) == 8
@test first(a:Month(12):d) == a
@test last(a:Month(12):d) == d
@test length(a:Week(52):d) == 8
@test first(a:Week(52):d) == a
@test last(a:Week(52):d) == DayDate(2019, 12, 24)
@test length(a:Day(365):d) == 8
@test first(a:Day(365):d) == a
@test last(a:Day(365):d) == DayDate(2019, 12, 31)

a = DayDate(2013, 1, 1)
b = DayDate(2013, 2, 1)
@test length(a:Year(1):DayDate(2020, 2, 1)) == 8
@test length(a:Year(1):DayDate(2020, 6, 1)) == 8
@test length(a:Year(1):DayDate(2020, 11, 1)) == 8
@test length(a:Year(1):DayDate(2020, 12, 31)) == 8
@test length(a:Year(1):DayDate(2021, 1, 1)) == 9
@test length(DayDate(2000):Year(-10):DayDate(1900)) == 11
@test length(DayDate(2000, 6, 23):Year(-10):DayDate(1900, 2, 28)) == 11
@test length(DayDate(2000, 1, 1):Year(1):DayDate(2000, 2, 1)) == 1

let n = 100000
    local a, b
    a = b = DayDate(0)
    for i = 1:n
        @test length(a:Year(1):b) == i
        b += Year(1)
    end
end

let n = 10000,
    a = DayDate(1985, 12, 5),
    b = DayDate(1986, 12, 27),
    c = DayDate(1985, 12, 5),
    d = DayDate(1986, 12, 27)

    for i = 1:n
        @test length(a:Month(1):b) == 13
        @test length(a:Year(1):b) == 2
        @test length(c:Month(1):d) == 13
        @test length(c:Year(1):d) == 2
        a += Day(1)
        b += Day(1)
    end
end

let n = 100000
    local a, b
    a = b = DayDate(2000)
    for i = 1:n
        @test length(a:Month(1):b) == i
        b += Month(1)
    end
end

@test length(Year(1):Year(1):Year(10)) == 10
@test length(Year(10):Year(-1):Year(1)) == 10
@test length(Year(10):Year(-2):Year(1)) == 5
if VERSION >= v"1.7.0"
    @test length(typemin(Year):Year(1):typemax(Year)) == 0 # overflow
    @test_throws MethodError DayDate(0):DayDate(2000)
end
@test_throws MethodError DayDate(0):Year(10)
@test length(range(DayDate(2000), step = Day(1), length = 366)) == 366
@test last(range(DayDate(2000), step = Day(1), length = 366)) == DayDate(2000, 12, 31)
@test last(range(DayDate(2001), step = Day(1), length = 365)) == DayDate(2001, 12, 31)
@test last(range(DayDate(2000), step = Day(1), length = 367)) ==
      last(range(DayDate(2000), step = Month(12), length = 2)) ==
      last(range(DayDate(2000), step = Year(1), length = 2))

# Issue 5
lastdaysofmonth = [DayDate(2014, i, daysinmonth(2014, i)) for i = 1:12]
@test [DayDate(2014, 1, 31):Month(1):DayDate(2015);] == lastdaysofmonth

# Range addition/subtraction:
let d = Day(1)
    @test (DayDate(2000):d:DayDate(2001)) + d == (DayDate(2000)+d:d:DayDate(2001)+d)
    @test (DayDate(2000):d:DayDate(2001)) - d == (DayDate(2000)-d:d:DayDate(2001)-d)
end

end  # RangesTest module
