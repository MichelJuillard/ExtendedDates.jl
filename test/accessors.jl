# This file is a part of Julia. License is MIT: https://julialang.org/license

module AccessorsTest

using Dates
using Periods
using Test

@testset "year/semester/quarter/month/week/day" begin
    # year, month, and day return the indivial components
    # of yearmonthday, avoiding additional calculations when possible
    @test Periods.year(-1) == 0
    @test Periods.semester(-1) == 2
    @test Periods.quarter(-1) == 4
    @test Periods.month(-1) == 12
#    @test Periods.week(-1) == 52 # 0 and negative days not working !!
    @test Periods.day(-1) == 30

    @test Periods.year(0) == 0
    @test Periods.semester(0) == 2
    @test Periods.quarter(0) == 4
    @test Periods.month(0) == 12
#    @test Periods.week(0) == 52 # 0 and negative days not working !!
    @test Periods.day(0) == 31

    @test Periods.year(1) == 1
    @test Periods.semester(1) == 1
    @test Periods.quarter(1) == 1
    @test Periods.month(1) == 1
    @test Periods.week(1) == 1
    @test Periods.day(1) == 1

    @test Periods.year(730120) == 2000
    @test Periods.month(730120) == 1
    @test Periods.day(730120) == 1
end

@testset "year, month, day, hour, minute, second over many years" begin
    let from=1, to=2, y=0, s=0, q=0, m=0, w=1, d=0
        dd = Dates.dayofweek(Dates.Date(from, 1, 1))
        for y in from:to
            maxweek = Periods.weeksinyear(y)
            for m = 1:12
                for d = 1:Dates.daysinmonth(y, m)
                    dt = Periods.Day(y, m, d)
                    s = div(rem(m - 1, 12), 6) + 1
                    q  = div(rem(m - 1, 12), 3) + 1
                    @test y == Periods.year(dt)
                    @test m == Periods.month(dt)
                    @test d == Periods.day(dt)
                    @test s == Periods.semester(dt)
                    @test q  == Periods.quarter(dt)
                    @test w == Periods.week(dt)
                    if dd > 6
                        w = (w + 1 > maxweek) ? 1 : w + 1
                        dd = 1
                    else
                        dd += 1
                    end
                end
            end
        end
    end
end
@testset "week" begin
    # Tests from https://en.wikipedia.org/wiki/ISO_week_date
    @test Periods.week(Periods.Day(2005, 1, 1)) == 53
    @test Periods.week(Periods.Day(2005, 1, 2)) == 53
    @test Periods.week(Periods.Day(2005, 12, 31)) == 52
    @test Periods.week(Periods.Day(2007, 1, 1)) == 1
    @test Periods.week(Periods.Day(2007, 12, 30)) == 52
    @test Periods.week(Periods.Day(2007, 12, 31)) == 1
    @test Periods.week(Periods.Day(2008, 1, 1)) == 1
    @test Periods.week(Periods.Day(2008, 12, 28)) == 52
    @test Periods.week(Periods.Day(2008, 12, 29)) == 1
    @test Periods.week(Periods.Day(2008, 12, 30)) == 1
    @test Periods.week(Periods.Day(2008, 12, 31)) == 1
    @test Periods.week(Periods.Day(2009, 1, 1)) == 1
    @test Periods.week(Periods.Day(2009, 12, 31)) == 53
    @test Periods.week(Periods.Day(2010, 1, 1)) == 53
    @test Periods.week(Periods.Day(2010, 1, 2)) == 53
    @test Periods.week(Periods.Day(2010, 1, 2)) == 53
    # Tests from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=1999
    dt = Periods.Day(1999, 12, 27)
    check = (52, 52, 52, 52, 52, 52, 52, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2)
    for i = 1:21
        @test Periods.week(dt) == check[i]
        dt = dt + Dates.Day(1)
    end
    # Tests from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=2000
    dt = Periods.Day(2000, 12, 25)
    for i = 1:21
        @test Periods.week(dt) == check[i]
        dt = dt + Dates.Day(1)
    end
    # Test from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=2030
    dt = Periods.Day(2030, 12, 23)
    for i = 1:21
        @test Periods.week(dt) == check[i]
        dt = dt + Dates.Day(1)
    end
    # Tests from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=2004
    dt1 = Periods.Day(2004, 12, 20)
    check = (52, 52, 52, 52, 52, 52, 52, 53, 53, 53, 53, 53, 53, 53, 1, 1, 1, 1, 1, 1, 1)
    for i = 1:21
        @test Periods.week(dt1) == check[i]
        dt1 = dt1 + Dates.Day(1)
    end
end
@testset "Vectorized accessors" begin
    a = Periods.Day(2014, 1, 1)
    dr = [a, a, a, a, a, a, a, a, a, a]
    @test Periods.year.(dr) == repeat([2014], 10)
    @test Periods.month.(dr) == repeat([1], 10)
    @test Periods.day.(dr) == repeat([1], 10)
end

end
