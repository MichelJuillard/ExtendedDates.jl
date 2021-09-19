# This file is a part of Julia. License is MIT: https://julialang.org/license

module TypesTest

using Dates
using Test
using Periods

# Create "test" check manually
y = Dates.Year(1)
s = Periods.Semester
q = Dates.Quarter(1)
m = Dates.Month(1)
w = Dates.Week(1)
d = Dates.Day(1)
h = Dates.Hour(1)
mi = Dates.Minute(1)
s = Dates.Second(1)
ms = Dates.Millisecond(1)
@testset "Periods construction by parts" begin
    test = Periods.Year(Periods.UTY(2012))
    @test Periods.Year(2013) == test

    test = Periods.Day(Periods.UTD(Dates.value(Dates.Date(2013))))
    @test Periods.Day(2013) == test
    @test Periods.Day(2013, 1) == test
    @test Periods.Day(2013, 1, 1) == test

    @test Periods.Day(y) == Periods.Day(1)
    @test Periods.Day(y, m) == Periods.Day(1, 1)
    @test Periods.Day(y, m, d) == Periods.Day(1, 1, 1)
    @test Periods.Day(Dates.Day(10), Dates.Month(2), y) == Periods.Day(1, 2, 10)

    test = Periods.Week(Periods.UTW(Periods.WEEKTABLE[2012]["cum_weeks"] + 1))
    @test Periods.Week(2013) == test
    @test Periods.Week(2013, 1) == test

    @test Periods.Week(y) == Periods.Week(1)
    @test Periods.Week(y, w) == Periods.Week(1, 1)
    @test Periods.Week(Dates.Week(10), y) == Periods.Week(1, 10)

    test = Periods.Month(Periods.UTM(2012 * 12 + 1))
    @test Periods.Month(2013) == test
    @test Periods.Month(2013, 1) == test

    @test Periods.Month(y) == Periods.Month(1)
    @test Periods.Month(y, m) == Periods.Month(1, 1)
    @test Periods.Month(Dates.Month(10), y) == Periods.Month(1, 10)

    test = Periods.Quarter(Periods.UTQ(2012 * 4 + 1))
    @test Periods.Quarter(2013) == test
    @test Periods.Quarter(2013, 1) == test

    @test Periods.Quarter(y) == Periods.Quarter(1)
    @test Periods.Quarter(y, q) == Periods.Quarter(1, 1)
    @test Periods.Quarter(Dates.Quarter(3), y) == Periods.Quarter(1, 3)

    test = Periods.Semester(Periods.UTS(2012 * 2 + 1))
    @test Periods.Semester(2013) == test
    @test Periods.Semester(2013, 1) == test

    @test Periods.Semester(y) == Periods.Semester(1)
    @test Periods.Semester(y, s) == Periods.Semester(1, 1)
    @test Periods.Semester(Periods.SemesterPeriod(2), y) == Periods.Semester(1, 2)
end

@testset "various input types for Date/DateTime" begin
    test = Periods.Day(1, 1, 1)
    @test Periods.Day(Int8(1), Int8(1), Int8(1)) == test
    @test Periods.Day(UInt8(1), UInt8(1), UInt8(1)) == test
    @test Periods.Day(Int16(1), Int16(1), Int16(1)) == test
    @test Periods.Day(UInt8(1), UInt8(1), UInt8(1)) == test
    @test Periods.Day(Int32(1), Int32(1), Int32(1)) == test
    @test Periods.Day(UInt32(1), UInt32(1), UInt32(1)) == test
    @test Periods.Day(Int64(1), Int64(1), Int64(1)) == test
    @test Periods.Day('\x01', '\x01', '\x01') == test
    @test Periods.Day(true, true, true) == test
    @test_throws ArgumentError Periods.Day(false, true, false)
    @test Periods.Day(false, true, true) == test - Dates.Day(366)
    @test_throws ArgumentError Periods.Day(true, true, false)
    @test Periods.Day(UInt64(1), UInt64(1), UInt64(1)) == test
    @test Periods.Day(0, UInt64(12), UInt64(30)) == test - Dates.Day(2)
    @test Periods.Day(Int128(1), Int128(1), Int128(1)) == test
    @test_throws InexactError Periods.Day(
        170141183460469231731687303715884105727,
        Int128(1),
        Int128(1),
    )
    @test Periods.Day(UInt128(1), UInt128(1), UInt128(1)) == test
    @test Periods.Day(big(1), big(1), big(1)) == test
    @test Periods.Day(big(1), big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test Periods.Day(BigFloat(1), BigFloat(1), BigFloat(1)) == test
    @test Periods.Day(complex(1), complex(1), complex(1)) == test
    @test Periods.Day(Float64(1), Float64(1), Float64(1)) == test
    @test Periods.Day(Float32(1), Float32(1), Float32(1)) == test
    @test Periods.Day(Float16(1), Float16(1), Float16(1)) == test
    @test Periods.Day(Rational(1), Rational(1), Rational(1)) == test
    @test_throws InexactError Periods.Day(BigFloat(1.2), BigFloat(1), BigFloat(1))
    @test_throws InexactError Periods.Day(1 + im, complex(1), complex(1))
    @test_throws InexactError Periods.Day(1.2, 1.0, 1.0)
    @test_throws InexactError Periods.Day(1.2f0, 1.0f0, 1.0f0)
    @test_throws InexactError Periods.Day(3 // 4, Rational(1), Rational(1)) == test

    test = Periods.Week(1, 1)
    @test Periods.Week(Int8(1), Int8(1)) == test
    @test Periods.Week(UInt8(1), UInt8(1)) == test
    @test Periods.Week(Int16(1), Int16(1)) == test
    @test Periods.Week(UInt8(1), UInt8(1)) == test
    @test Periods.Week(Int32(1), Int32(1)) == test
    @test Periods.Week(UInt32(1), UInt32(1)) == test
    @test Periods.Week(Int64(1), Int64(1)) == test
    @test Periods.Week('\x01', '\x01') == test
    @test Periods.Week(true, true) == test
    @test_throws ArgumentError Periods.Week(0)
    @test_throws ArgumentError Periods.Week(false, false)
    @test_throws ArgumentError Periods.Week(true, false)
    @test Periods.Week(UInt64(1), UInt64(1)) == test
    @test Periods.Week(Int128(1), Int128(1)) == test
    @test_throws InexactError Periods.Week(
        170141183460469231731687303715884105727,
        Int128(1),
    )
    @test Periods.Week(UInt128(1), UInt128(1)) == test
    @test Periods.Week(big(1), big(1)) == test
    @test Periods.Week(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test Periods.Week(BigFloat(1), BigFloat(1)) == test
    @test Periods.Week(complex(1), complex(1)) == test
    @test Periods.Week(Float64(1), Float64(1)) == test
    @test Periods.Week(Float32(1), Float32(1)) == test
    @test Periods.Week(Float16(1), Float16(1)) == test
    @test Periods.Week(Rational(1), Rational(1)) == test
    @test_throws InexactError Periods.Week(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError Periods.Week(1 + im, complex(1))
    @test_throws InexactError Periods.Week(1.2, 1.0)
    @test_throws InexactError Periods.Week(1.2f0, 1.0f0)
    @test_throws InexactError Periods.Week(3 // 4, Rational(1)) == test

    test = Periods.Month(1, 1)
    @test Periods.Month(Int8(1), Int8(1)) == test
    @test Periods.Month(UInt8(1), UInt8(1)) == test
    @test Periods.Month(Int16(1), Int16(1)) == test
    @test Periods.Month(UInt8(1), UInt8(1)) == test
    @test Periods.Month(Int32(1), Int32(1)) == test
    @test Periods.Month(UInt32(1), UInt32(1)) == test
    @test Periods.Month(Int64(1), Int64(1)) == test
    @test Periods.Month('\x01', '\x01') == test
    @test Periods.Month(true, true) == test
    @test_throws ArgumentError Periods.Month(false, false)
    @test Periods.Month(false, true) == test - Dates.Month(12)
    @test_throws ArgumentError Periods.Month(true, false)
    @test Periods.Month(UInt64(1), UInt64(1)) == test
    @test Periods.Month(0, UInt64(12)) == test - Dates.Month(1)
    @test Periods.Month(Int128(1), Int128(1)) == test
    @test_throws InexactError Periods.Month(
        170141183460469231731687303715884105727,
        Int128(1),
    )
    @test Periods.Month(UInt128(1), UInt128(1)) == test
    @test Periods.Month(big(1), big(1)) == test
    @test Periods.Month(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test Periods.Month(BigFloat(1), BigFloat(1)) == test
    @test Periods.Month(complex(1), complex(1)) == test
    @test Periods.Month(Float64(1), Float64(1)) == test
    @test Periods.Month(Float32(1), Float32(1)) == test
    @test Periods.Month(Float16(1), Float16(1)) == test
    @test Periods.Month(Rational(1), Rational(1)) == test
    @test_throws InexactError Periods.Month(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError Periods.Month(1 + im, complex(1))
    @test_throws InexactError Periods.Month(1.2, 1.0)
    @test_throws InexactError Periods.Month(1.2f0, 1.0f0)
    @test_throws InexactError Periods.Month(3 // 4, Rational(1)) == test

    test = Periods.Quarter(1, 1)
    @test Periods.Quarter(Int8(1), Int8(1)) == test
    @test Periods.Quarter(UInt8(1), UInt8(1)) == test
    @test Periods.Quarter(Int16(1), Int16(1)) == test
    @test Periods.Quarter(UInt8(1), UInt8(1)) == test
    @test Periods.Quarter(Int32(1), Int32(1)) == test
    @test Periods.Quarter(UInt32(1), UInt32(1)) == test
    @test Periods.Quarter(Int64(1), Int64(1)) == test
    @test Periods.Quarter('\x01', '\x01') == test
    @test Periods.Quarter(true, true) == test
    @test_throws ArgumentError Periods.Quarter(false, false)
    @test Periods.Quarter(false, true) == test - Dates.Quarter(4)
    @test_throws ArgumentError Periods.Quarter(true, false)
    @test Periods.Quarter(UInt64(1), UInt64(1)) == test
    @test Periods.Quarter(0, UInt64(4)) == test - Dates.Quarter(1)
    @test Periods.Quarter(Int128(1), Int128(1)) == test
    @test_throws InexactError Periods.Quarter(
        170141183460469231731687303715884105727,
        Int128(1),
    )
    @test Periods.Quarter(UInt128(1), UInt128(1)) == test
    @test Periods.Quarter(big(1), big(1)) == test
    @test Periods.Quarter(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test Periods.Quarter(BigFloat(1), BigFloat(1)) == test
    @test Periods.Quarter(complex(1), complex(1)) == test
    @test Periods.Quarter(Float64(1), Float64(1)) == test
    @test Periods.Quarter(Float32(1), Float32(1)) == test
    @test Periods.Quarter(Float16(1), Float16(1)) == test
    @test Periods.Quarter(Rational(1), Rational(1)) == test
    @test_throws InexactError Periods.Quarter(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError Periods.Quarter(1 + im, complex(1))
    @test_throws InexactError Periods.Quarter(1.2, 1.0)
    @test_throws InexactError Periods.Quarter(1.2f0, 1.0f0)
    @test_throws InexactError Periods.Quarter(3 // 4, Rational(1)) == test

    test = Periods.Semester(1, 1)
    @test Periods.Semester(Int8(1), Int8(1)) == test
    @test Periods.Semester(UInt8(1), UInt8(1)) == test
    @test Periods.Semester(Int16(1), Int16(1)) == test
    @test Periods.Semester(UInt8(1), UInt8(1)) == test
    @test Periods.Semester(Int32(1), Int32(1)) == test
    @test Periods.Semester(UInt32(1), UInt32(1)) == test
    @test Periods.Semester(Int64(1), Int64(1)) == test
    @test Periods.Semester('\x01', '\x01') == test
    @test Periods.Semester(true, true) == test
    @test_throws ArgumentError Periods.Semester(false, false)
    @test Periods.Semester(false, true) == test - Periods.SemesterPeriod(2)
    @test_throws ArgumentError Periods.Semester(true, false)
    @test Periods.Semester(UInt64(1), UInt64(1)) == test
    @test Periods.Semester(0, UInt64(2)) == test - Periods.SemesterPeriod(1)
    @test Periods.Semester(Int128(1), Int128(1)) == test
    @test_throws InexactError Periods.Semester(
        170141183460469231731687303715884105727,
        Int128(1),
    )
    @test Periods.Semester(UInt128(1), UInt128(1)) == test
    @test Periods.Semester(big(1), big(1)) == test
    @test Periods.Semester(big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test Periods.Semester(BigFloat(1), BigFloat(1)) == test
    @test Periods.Semester(complex(1), complex(1)) == test
    @test Periods.Semester(Float64(1), Float64(1)) == test
    @test Periods.Semester(Float32(1), Float32(1)) == test
    @test Periods.Semester(Float16(1), Float16(1)) == test
    @test Periods.Semester(Rational(1), Rational(1)) == test
    @test_throws InexactError Periods.Semester(BigFloat(1.2), BigFloat(1))
    @test_throws InexactError Periods.Semester(1 + im, complex(1))
    @test_throws InexactError Periods.Semester(1.2, 1.0)
    @test_throws InexactError Periods.Semester(1.2f0, 1.0f0)
    @test_throws InexactError Periods.Semester(3 // 4, Rational(1)) == test

    test = Periods.Year(1)
    @test Periods.Year(Int8(1)) == test
    @test Periods.Year(UInt8(1)) == test
    @test Periods.Year(Int16(1)) == test
    @test Periods.Year(UInt8(1)) == test
    @test Periods.Year(Int32(1)) == test
    @test Periods.Year(UInt32(1)) == test
    @test Periods.Year(Int64(1)) == test
    @test Periods.Year('\x01') == test
    @test Periods.Year(true) == test
    @test Periods.Year(false) == test - Dates.Year(1)
    @test Periods.Year(UInt64(1)) == test
    @test Periods.Year(0) == test - Dates.Year(1)
    @test Periods.Year(Int128(1)) == test
    @test_throws InexactError Periods.Year(170141183460469231731687303715884105727)
    @test Periods.Year(UInt128(1)) == test
    @test Periods.Year(big(1)) == test
    @test Periods.Year(big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test Periods.Year(BigFloat(1)) == test
    @test Periods.Year(complex(1)) == test
    @test Periods.Year(Float64(1)) == test
    @test Periods.Year(Float32(1)) == test
    @test Periods.Year(Float16(1)) == test
    @test Periods.Year(Rational(1)) == test
    @test_throws InexactError Periods.Year(BigFloat(1.2))
    @test_throws InexactError Periods.Year(1 + im)
    @test_throws InexactError Periods.Year(1.2)
    @test_throws InexactError Periods.Year(1.2f0)
    @test_throws InexactError Periods.Year(3 // 4) == test

    test = Periods.Undated(1)
    @test Periods.Undated(Int8(1)) == test
    @test Periods.Undated(UInt8(1)) == test
    @test Periods.Undated(Int16(1)) == test
    @test Periods.Undated(UInt8(1)) == test
    @test Periods.Undated(Int32(1)) == test
    @test Periods.Undated(UInt32(1)) == test
    @test Periods.Undated(Int64(1)) == test
    @test Periods.Undated('\x01') == test
    @test Periods.Undated(true) == test
    @test Periods.Undated(false) == test - Periods.UndatedPeriod(1)
    @test Periods.Undated(UInt64(1)) == test
    @test Periods.Undated(0) == test - Periods.UndatedPeriod(1)
    @test Periods.Undated(Int128(1)) == test
    @test_throws InexactError Periods.Undated(170141183460469231731687303715884105727)
    @test Periods.Undated(UInt128(1)) == test
    @test Periods.Undated(big(1)) == test
    @test Periods.Undated(big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test Periods.Undated(BigFloat(1)) == test
    @test Periods.Undated(complex(1)) == test
    @test Periods.Undated(Float64(1)) == test
    @test Periods.Undated(Float32(1)) == test
    @test Periods.Undated(Float16(1)) == test
    @test Periods.Undated(Rational(1)) == test
    @test_throws InexactError Periods.Undated(BigFloat(1.2))
    @test_throws InexactError Periods.Undated(1 + im)
    @test_throws InexactError Periods.Undated(1.2)
    @test_throws InexactError Periods.Undated(1.2f0)
    @test_throws InexactError Periods.Undated(3 // 4) == test

    # Semesters, Quarters, Months, Weeks Days must be in range 
    @test_throws ArgumentError Periods.Day(2013, 0, 1)
    @test_throws ArgumentError Periods.Day(2013, 13, 1)
    @test_throws ArgumentError Periods.Day(2013, 1, 0)
    @test_throws ArgumentError Periods.Day(2013, 1, 32)

    @test_throws ArgumentError Periods.Week(2013, 0)
    @test_throws ArgumentError Periods.Week(2013, 54)

    @test_throws ArgumentError Periods.Month(2013, 0)
    @test_throws ArgumentError Periods.Month(2013, 13)

    @test_throws ArgumentError Periods.Quarter(2013, 0)
    @test_throws ArgumentError Periods.Quarter(2013, 5)

    @test_throws ArgumentError Periods.Semester(2013, 0)
    @test_throws ArgumentError Periods.Semester(2013, 3)

end
a = Dates.DateTime(2000)
b = Dates.Date(2000)
c = Dates.Time(0)
@testset "DateTime traits" begin
    for T in (:Day, :Week, :Month, :Quarter, :Year)
        @eval begin
            @test Periods.calendar(Periods.$T(2000)) == Dates.ISOCalendar
            @test eps(Periods.$T) == Dates.$T(1)
            @test zero(Periods.$T) == Dates.$T(0)
            @test isfinite(Periods.$T)
        end
    end
end
@testset "Date-DateTime conversion/promotion" begin
    for T in (:Day, :Week, :Month, :Quarter, :Semester, :Year, :Undated)
        @eval begin
            a = Periods.$T(2000)
            b = Periods.$T(2000)
            @test Periods.$T(a) == a
            @test Periods.$T(a) == b
            @test Periods.$T(b) == b
            @test a == b
            @test a == a
            @test b == a
            @test b == b
            @test !(a < b)
            @test !(b < a)
            b = Periods.$T(2001)
            @test b > a
            @test a < b
            @test a != b
        end
    end
end

@testset "min and max" begin
    for T in (:Day, :Week, :Month, :Quarter, :Semester, :Year, :Undated)
        @eval begin
            a = Periods.$T(2000)
            b = Periods.$T(2001)
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

    for T in (:Day, :Week, :Month, :Quarter, :Semester)
        @eval begin
            a = Periods.$T(2000, 1)
            b = Periods.$T(2000, 2)
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

    @test Periods.Day(2000, 1, 1) < Periods.Day(2000, 1, 2)

end

end
