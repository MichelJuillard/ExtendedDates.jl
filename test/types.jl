# This file is a part of Julia. License is MIT: https://julialang.org/license

module TypesTest

import Dates
using Test
using ExtendedDates

# Create "test" check manually
y = Year(1)
s = SemesterDate
q = Quarter(1)
m = Month(1)
w = Week(1)
d = Day(1)
h = Hour(1)
mi = Minute(1)
s = Second(1)
ms = Millisecond(1)
@testset "SimpleDate construction by parts" begin
    test = YearDate(ExtendedDates.UTY(2012))
    @test YearDate(2013) == test

    test = DayDate(ExtendedDates.UTD(Dates.value(Dates.Date(2013))))
    @test DayDate(2013) == test
    @test DayDate(2013, 1) == test
    @test DayDate(2013, 1, 1) == test

    @test DayDate(y) == DayDate(1)
    @test DayDate(y, m) == DayDate(1, 1)
    @test DayDate(y, m, d) == DayDate(1, 1, 1)
    @test DayDate(Day(10), Month(2), y) == DayDate(1, 2, 10)

    test = WeekDate(ExtendedDates.UTW(ExtendedDates.WEEKTABLE[2012]["cum_weeks"] + 1))
    @test WeekDate(2013) == test
    @test WeekDate(2013, 1) == test

    @test WeekDate(y) == WeekDate(1)
    @test WeekDate(y, w) == WeekDate(1, 1)
    @test WeekDate(Week(10), y) == WeekDate(1, 10)

    test = MonthDate(ExtendedDates.UTM(2012 * 12 + 1))
    @test MonthDate(2013) == test
    @test MonthDate(2013, 1) == test

    @test MonthDate(y) == MonthDate(1)
    @test MonthDate(y, m) == MonthDate(1, 1)
    @test MonthDate(Month(10), y) == MonthDate(1, 10)

    test = QuarterDate(ExtendedDates.UTQ(2012 * 4 + 1))
    @test QuarterDate(2013) == test
    @test QuarterDate(2013, 1) == test

    @test QuarterDate(y) == QuarterDate(1)
    @test QuarterDate(y, q) == QuarterDate(1, 1)
    @test QuarterDate(Quarter(3), y) == QuarterDate(1, 3)

    test = SemesterDate(ExtendedDates.UTS(2012 * 2 + 1))
    @test SemesterDate(2013) == test
    @test SemesterDate(2013, 1) == test

    @test SemesterDate(y) == SemesterDate(1)
    @test SemesterDate(y, s) == SemesterDate(1, 1)
    @test SemesterDate(Semester(2), y) == SemesterDate(1, 2)
end

@testset "various input types for Date/DateTime" begin
    test = DayDate(1, 1, 1)
    @test DayDate(Int8(1), Int8(1), Int8(1)) == test
    @test DayDate(UInt8(1), UInt8(1), UInt8(1)) == test
    @test DayDate(Int16(1), Int16(1), Int16(1)) == test
    @test DayDate(UInt8(1), UInt8(1), UInt8(1)) == test
    @test DayDate(Int32(1), Int32(1), Int32(1)) == test
    @test DayDate(UInt32(1), UInt32(1), UInt32(1)) == test
    @test DayDate(Int64(1), Int64(1), Int64(1)) == test
    @test DayDate('\x01', '\x01', '\x01') == test
    @test DayDate(true, true, true) == test
    @test_throws ArgumentError DayDate(false, true, false)
    @test DayDate(false, true, true) == test - Day(366)
    @test_throws ArgumentError DayDate(true, true, false)
    @test DayDate(UInt64(1), UInt64(1), UInt64(1)) == test
    @test DayDate(0, UInt64(12), UInt64(30)) == test - Day(2)
    @test DayDate(Int128(1), Int128(1), Int128(1)) == test
    @test_throws InexactError DayDate(
        170141183460469231731687303715884105727,
        Int128(1),
        Int128(1),
    )
    @test DayDate(UInt128(1), UInt128(1), UInt128(1)) == test
    @test DayDate(big(1), big(1), big(1)) == test
    @test DayDate(big(1), big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test DayDate(BigFloat(1), BigFloat(1), BigFloat(1)) == test
    @test DayDate(complex(1), complex(1), complex(1)) == test
    @test DayDate(Float64(1), Float64(1), Float64(1)) == test
    @test DayDate(Float32(1), Float32(1), Float32(1)) == test
    @test DayDate(Float16(1), Float16(1), Float16(1)) == test
    @test DayDate(Rational(1), Rational(1), Rational(1)) == test
    @test_throws InexactError DayDate(BigFloat(1.2), BigFloat(1), BigFloat(1))
    @test_throws InexactError DayDate(1 + im, complex(1), complex(1))
    @test_throws InexactError DayDate(1.2, 1.0, 1.0)
    @test_throws InexactError DayDate(1.2f0, 1.0f0, 1.0f0)
    @test_throws InexactError DayDate(3 // 4, Rational(1), Rational(1)) == test

    test = WeekDate(1, 1)
    @test WeekDate(Int8(1), Int8(1)) == test
    @test WeekDate(UInt8(1), UInt8(1)) == test
    @test WeekDate(Int16(1), Int16(1)) == test
    @test WeekDate(UInt8(1), UInt8(1)) == test
    @test WeekDate(Int32(1), Int32(1)) == test
    @test WeekDate(UInt32(1), UInt32(1)) == test
    @test WeekDate(Int64(1), Int64(1)) == test
    @test WeekDate('\x01', '\x01') == test
    @test WeekDate(true, true) == test
    @test_throws ArgumentError WeekDate(0)
    @test_throws ArgumentError WeekDate(false, false)
    @test_throws ArgumentError WeekDate(true, false)
    @test WeekDate(UInt64(1), UInt64(1)) == test
    @test WeekDate(Int128(1), Int128(1)) == test
    @test_throws InexactError WeekDate(170141183460469231731687303715884105727, Int128(1))
    @test WeekDate(UInt128(1), UInt128(1)) == test
    @test WeekDate(big(1), big(1)) == test
    @test WeekDate(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test WeekDate(BigFloat(1), BigFloat(1)) == test
    @test WeekDate(complex(1), complex(1)) == test
    @test WeekDate(Float64(1), Float64(1)) == test
    @test WeekDate(Float32(1), Float32(1)) == test
    @test WeekDate(Float16(1), Float16(1)) == test
    @test WeekDate(Rational(1), Rational(1)) == test
    @test_throws InexactError WeekDate(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError WeekDate(1 + im, complex(1))
    @test_throws InexactError WeekDate(1.2, 1.0)
    @test_throws InexactError WeekDate(1.2f0, 1.0f0)
    @test_throws InexactError WeekDate(3 // 4, Rational(1)) == test

    test = MonthDate(1, 1)
    @test MonthDate(Int8(1), Int8(1)) == test
    @test MonthDate(UInt8(1), UInt8(1)) == test
    @test MonthDate(Int16(1), Int16(1)) == test
    @test MonthDate(UInt8(1), UInt8(1)) == test
    @test MonthDate(Int32(1), Int32(1)) == test
    @test MonthDate(UInt32(1), UInt32(1)) == test
    @test MonthDate(Int64(1), Int64(1)) == test
    @test MonthDate('\x01', '\x01') == test
    @test MonthDate(true, true) == test
    @test_throws ArgumentError MonthDate(false, false)
    @test MonthDate(false, true) == test - Dates.Month(12)
    @test_throws ArgumentError MonthDate(true, false)
    @test MonthDate(UInt64(1), UInt64(1)) == test
    @test MonthDate(0, UInt64(12)) == test - Dates.Month(1)
    @test MonthDate(Int128(1), Int128(1)) == test
    @test_throws InexactError MonthDate(170141183460469231731687303715884105727, Int128(1))
    @test MonthDate(UInt128(1), UInt128(1)) == test
    @test MonthDate(big(1), big(1)) == test
    @test MonthDate(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test MonthDate(BigFloat(1), BigFloat(1)) == test
    @test MonthDate(complex(1), complex(1)) == test
    @test MonthDate(Float64(1), Float64(1)) == test
    @test MonthDate(Float32(1), Float32(1)) == test
    @test MonthDate(Float16(1), Float16(1)) == test
    @test MonthDate(Rational(1), Rational(1)) == test
    @test_throws InexactError MonthDate(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError MonthDate(1 + im, complex(1))
    @test_throws InexactError MonthDate(1.2, 1.0)
    @test_throws InexactError MonthDate(1.2f0, 1.0f0)
    @test_throws InexactError MonthDate(3 // 4, Rational(1)) == test

    test = QuarterDate(1, 1)
    @test QuarterDate(Int8(1), Int8(1)) == test
    @test QuarterDate(UInt8(1), UInt8(1)) == test
    @test QuarterDate(Int16(1), Int16(1)) == test
    @test QuarterDate(UInt8(1), UInt8(1)) == test
    @test QuarterDate(Int32(1), Int32(1)) == test
    @test QuarterDate(UInt32(1), UInt32(1)) == test
    @test QuarterDate(Int64(1), Int64(1)) == test
    @test QuarterDate('\x01', '\x01') == test
    @test QuarterDate(true, true) == test
    @test_throws ArgumentError QuarterDate(false, false)
    @test QuarterDate(false, true) == test - Dates.Quarter(4)
    @test_throws ArgumentError QuarterDate(true, false)
    @test QuarterDate(UInt64(1), UInt64(1)) == test
    @test QuarterDate(0, UInt64(4)) == test - Dates.Quarter(1)
    @test QuarterDate(Int128(1), Int128(1)) == test
    @test_throws InexactError QuarterDate(
        170141183460469231731687303715884105727,
        Int128(1),
    )
    @test QuarterDate(UInt128(1), UInt128(1)) == test
    @test QuarterDate(big(1), big(1)) == test
    @test QuarterDate(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test QuarterDate(BigFloat(1), BigFloat(1)) == test
    @test QuarterDate(complex(1), complex(1)) == test
    @test QuarterDate(Float64(1), Float64(1)) == test
    @test QuarterDate(Float32(1), Float32(1)) == test
    @test QuarterDate(Float16(1), Float16(1)) == test
    @test QuarterDate(Rational(1), Rational(1)) == test
    @test_throws InexactError QuarterDate(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError QuarterDate(1 + im, complex(1))
    @test_throws InexactError QuarterDate(1.2, 1.0)
    @test_throws InexactError QuarterDate(1.2f0, 1.0f0)
    @test_throws InexactError QuarterDate(3 // 4, Rational(1)) == test

    test = SemesterDate(1, 1)
    @test SemesterDate(Int8(1), Int8(1)) == test
    @test SemesterDate(UInt8(1), UInt8(1)) == test
    @test SemesterDate(Int16(1), Int16(1)) == test
    @test SemesterDate(UInt8(1), UInt8(1)) == test
    @test SemesterDate(Int32(1), Int32(1)) == test
    @test SemesterDate(UInt32(1), UInt32(1)) == test
    @test SemesterDate(Int64(1), Int64(1)) == test
    @test SemesterDate('\x01', '\x01') == test
    @test SemesterDate(true, true) == test
    @test_throws ArgumentError SemesterDate(false, false)
    @test SemesterDate(false, true) == test - Semester(2)
    @test_throws ArgumentError SemesterDate(true, false)
    @test SemesterDate(UInt64(1), UInt64(1)) == test
    @test SemesterDate(0, UInt64(2)) == test - Semester(1)
    @test SemesterDate(Int128(1), Int128(1)) == test
    @test_throws InexactError SemesterDate(
        170141183460469231731687303715884105727,
        Int128(1),
    )
    @test SemesterDate(UInt128(1), UInt128(1)) == test
    @test SemesterDate(big(1), big(1)) == test
    @test SemesterDate(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test SemesterDate(BigFloat(1), BigFloat(1)) == test
    @test SemesterDate(complex(1), complex(1)) == test
    @test SemesterDate(Float64(1), Float64(1)) == test
    @test SemesterDate(Float32(1), Float32(1)) == test
    @test SemesterDate(Float16(1), Float16(1)) == test
    @test SemesterDate(Rational(1), Rational(1)) == test
    @test_throws InexactError SemesterDate(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError SemesterDate(1 + im, complex(1))
    @test_throws InexactError SemesterDate(1.2, 1.0)
    @test_throws InexactError SemesterDate(1.2f0, 1.0f0)
    @test_throws InexactError SemesterDate(3 // 4, Rational(1)) == test

    test = YearDate(1)
    @test YearDate(Int8(1)) == test
    @test YearDate(UInt8(1)) == test
    @test YearDate(Int16(1)) == test
    @test YearDate(UInt8(1)) == test
    @test YearDate(Int32(1)) == test
    @test YearDate(UInt32(1)) == test
    @test YearDate(Int64(1)) == test
    @test YearDate('\x01') == test
    @test YearDate(true) == test
    @test YearDate(false) == test - Year(1)
    @test YearDate(UInt64(1)) == test
    @test YearDate(0) == test - Year(1)
    @test YearDate(Int128(1)) == test
    @test_throws InexactError YearDate(170141183460469231731687303715884105727)
    @test YearDate(UInt128(1)) == test
    @test YearDate(big(1)) == test
    @test YearDate(big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test YearDate(BigFloat(1)) == test
    @test YearDate(complex(1)) == test
    @test YearDate(Float64(1)) == test
    @test YearDate(Float32(1)) == test
    @test YearDate(Float16(1)) == test
    @test YearDate(Rational(1)) == test
    @test_throws InexactError YearDate(BigFloat(1.2))
    @test_throws InexactError YearDate(1 + im)
    @test_throws InexactError YearDate(1.2)
    @test_throws InexactError YearDate(1.2f0)
    @test_throws InexactError YearDate(3 // 4) == test

    test = UndatedDate(1)
    @test UndatedDate(Int8(1)) == test
    @test UndatedDate(UInt8(1)) == test
    @test UndatedDate(Int16(1)) == test
    @test UndatedDate(UInt8(1)) == test
    @test UndatedDate(Int32(1)) == test
    @test UndatedDate(UInt32(1)) == test
    @test UndatedDate(Int64(1)) == test
    @test UndatedDate('\x01') == test
    @test UndatedDate(true) == test
    @test UndatedDate(false) == test - Undated(1)
    @test UndatedDate(UInt64(1)) == test
    @test UndatedDate(0) == test - Undated(1)
    @test UndatedDate(Int128(1)) == test
    @test_throws InexactError UndatedDate(170141183460469231731687303715884105727)
    @test UndatedDate(UInt128(1)) == test
    @test UndatedDate(big(1)) == test
    @test UndatedDate(big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test UndatedDate(BigFloat(1)) == test
    @test UndatedDate(complex(1)) == test
    @test UndatedDate(Float64(1)) == test
    @test UndatedDate(Float32(1)) == test
    @test UndatedDate(Float16(1)) == test
    @test UndatedDate(Rational(1)) == test
    @test_throws InexactError UndatedDate(BigFloat(1.2))
    @test_throws InexactError UndatedDate(1 + im)
    @test_throws InexactError UndatedDate(1.2)
    @test_throws InexactError UndatedDate(1.2f0)
    @test_throws InexactError UndatedDate(3 // 4) == test

    # Semesters, Quarters, Months, Weeks Days must be in range 
    @test_throws ArgumentError DayDate(2013, 0, 1)
    @test_throws ArgumentError DayDate(2013, 13, 1)
    @test_throws ArgumentError DayDate(2013, 1, 0)
    @test_throws ArgumentError DayDate(2013, 1, 32)

    @test_throws ArgumentError WeekDate(2013, 0)
    @test_throws ArgumentError WeekDate(2013, 54)

    @test_throws ArgumentError MonthDate(2013, 0)
    @test_throws ArgumentError MonthDate(2013, 13)

    @test_throws ArgumentError QuarterDate(2013, 0)
    @test_throws ArgumentError QuarterDate(2013, 5)

    @test_throws ArgumentError SemesterDate(2013, 0)
    @test_throws ArgumentError SemesterDate(2013, 3)

end
a = Dates.DateTime(2000)
b = Dates.Date(2000)
c = Dates.Time(0)
@testset "DateTime traits" begin
    for (T1, T2) in zip(
        (:DayDate, :WeekDate, :MonthDate, :QuarterDate, :YearDate),
        (:Day, :Week, :Month, :Quarter, :Year),
    )
        @eval begin
            @test ExtendedDates.calendar($T1(2000)) == Dates.ISOCalendar
            @test eps($T1) == Dates.$T2(1)
            @test zero($T1) == Dates.$T2(0)
            @test isfinite($T1)
        end
    end
end
@testset "Date-DateTime conversion/promotion" begin
    for T in (
        :DayDate,
        :WeekDate,
        :MonthDate,
        :QuarterDate,
        :SemesterDate,
        :YearDate,
        :UndatedDate,
    )
        @eval begin
            a = $T(2000)
            b = $T(2000)
            @test $T(a) == a
            @test $T(a) == b
            @test $T(b) == b
            @test a == b
            @test a == a
            @test b == a
            @test b == b
            @test !(a < b)
            @test !(b < a)
            b = $T(2001)
            @test b > a
            @test a < b
            @test a != b
        end
    end
end

@testset "min and max" begin
    for T in (
        :DayDate,
        :WeekDate,
        :MonthDate,
        :QuarterDate,
        :SemesterDate,
        :YearDate,
        :UndatedDate,
    )
        @eval begin
            a = $T(2000)
            b = $T(2001)
            @test min(a, b) == a
            @test min(b, a) == a
            @test min(a) == a
            @test max(a, b) == b
            @test max(b, a) == b
            @test max(b) == b
            @test minmax(a, b) == (a, b)
            @test minmax(b, a) == (a, b)
            @test minmax(a) == (a, a)
        end
    end

    for T in (:DayDate, :WeekDate, :MonthDate, :QuarterDate, :SemesterDate)
        @eval begin
            a = $T(2000, 1)
            b = $T(2000, 2)
            @test min(a, b) == a
            @test min(b, a) == a
            @test min(a) == a
            @test max(a, b) == b
            @test max(b, a) == b
            @test max(b) == b
            @test minmax(a, b) == (a, b)
            @test minmax(b, a) == (a, b)
            @test minmax(a) == (a, a)
        end
    end

    @test DayDate(2000, 1, 1) < DayDate(2000, 1, 2)

end

end
