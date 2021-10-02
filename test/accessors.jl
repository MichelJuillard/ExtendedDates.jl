# This file is a part of Julia. License is MIT: https://julialang.org/license

module AccessorsTest

import Dates
using ExtendedDates
using Test

@testset "year/semester/quarter/month/week/day" begin
    # year, month, and day return the indivial components
    # of yearmonthday, avoiding additional calculations when possible
    @test year(-1) == 0
    @test semester(-1) == 2
    @test quarter(-1) == 4
    @test month(-1) == 12
    #    @test week(-1) == 52 # 0 and negative days not working !!
    @test day(-1) == 30

    @test year(0) == 0
    @test semester(0) == 2
    @test quarter(0) == 4
    @test month(0) == 12
    #    @test week(0) == 52 # 0 and negative days not working !!
    @test day(0) == 31

    @test year(1) == 1
    @test semester(1) == 1
    @test quarter(1) == 1
    @test month(1) == 1
    @test week(1) == 1
    @test day(1) == 1

    @test year(730120) == 2000
    @test month(730120) == 1
    @test day(730120) == 1
end

@testset "year, month, day, hour, minute, second over many years" begin
    let from = 1, to = 2, y = 0, s = 0, q = 0, m = 0, w = 1, d = 0
        dd = Dates.dayofweek(Dates.Date(from, 1, 1))
        for y = from:to
            maxweek = ExtendedDates.weeksinyear(y)
            for m = 1:12
                for d = 1:Dates.daysinmonth(y, m)
                    dt = DayDate(y, m, d)
                    s = div(rem(m - 1, 12), 6) + 1
                    q = div(rem(m - 1, 12), 3) + 1
                    @test y == year(dt)
                    @test m == month(dt)
                    @test d == day(dt)
                    @test s == semester(dt)
                    @test q == quarter(dt)
                    @test w == week(dt)
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
    @test week(DayDate(2005, 1, 1)) == 53
    @test week(DayDate(2005, 1, 2)) == 53
    @test week(DayDate(2005, 12, 31)) == 52
    @test week(DayDate(2007, 1, 1)) == 1
    @test week(DayDate(2007, 12, 30)) == 52
    @test week(DayDate(2007, 12, 31)) == 1
    @test week(DayDate(2008, 1, 1)) == 1
    @test week(DayDate(2008, 12, 28)) == 52
    @test week(DayDate(2008, 12, 29)) == 1
    @test week(DayDate(2008, 12, 30)) == 1
    @test week(DayDate(2008, 12, 31)) == 1
    @test week(DayDate(2009, 1, 1)) == 1
    @test week(DayDate(2009, 12, 31)) == 53
    @test week(DayDate(2010, 1, 1)) == 53
    @test week(DayDate(2010, 1, 2)) == 53
    @test week(DayDate(2010, 1, 2)) == 53
    # Tests from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=1999
    dt = DayDate(1999, 12, 27)
    check = (52, 52, 52, 52, 52, 52, 52, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2)
    for i = 1:21
        @test week(dt) == check[i]
        dt = dt + Dates.Day(1)
    end
    # Tests from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=2000
    dt = DayDate(2000, 12, 25)
    for i = 1:21
        @test week(dt) == check[i]
        dt = dt + Dates.Day(1)
    end
    # Test from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=2030
    dt = DayDate(2030, 12, 23)
    for i = 1:21
        @test week(dt) == check[i]
        dt = dt + Dates.Day(1)
    end
    # Tests from http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=2004
    dt1 = DayDate(2004, 12, 20)
    check = (52, 52, 52, 52, 52, 52, 52, 53, 53, 53, 53, 53, 53, 53, 1, 1, 1, 1, 1, 1, 1)
    for i = 1:21
        @test week(dt1) == check[i]
        dt1 = dt1 + Dates.Day(1)
    end
end
@testset "Vectorized accessors" begin
    a = DayDate(2014, 1, 1)
    dr = [a, a, a, a, a, a, a, a, a, a]
    @test year.(dr) == repeat([2014], 10)
    @test month.(dr) == repeat([1], 10)
    @test day.(dr) == repeat([1], 10)
end

end
