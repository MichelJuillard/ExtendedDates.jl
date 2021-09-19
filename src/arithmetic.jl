
# TimeType-Year arithmetic
for (T1, T2) in zip(
    (:Day, :Week, :Month, :Quarter, :Year),
    (:DayDate, :WeekDate, :MonthDate, :QuarterDate, :YearDate),
)
    @eval begin
        function (+)(y::$T2, dy::Dates.$T1)
            return $T2(Dates.UTInstant{Dates.$T1}(Dates.$T1(value(y) + Dates.value(dy))))
        end

        function (+)(dy::Dates.$T1, y::$T2)
            return $T2(Dates.UTInstant{Dates.$T1}(Dates.$T1(value(y) + Dates.value(dy))))
        end

        function (-)(y::$T2, dy::Dates.$T1)
            return $T2(Dates.UTInstant{Dates.$T1}(Dates.$T1(value(y) - Dates.value(dy))))
        end
    end
end

function (+)(y::SemesterDate, dy::Semester)
    return Semester(Periods.UTS(value(y) + value(dy)))
end

function (+)(dy::Semester, y::SemesterDate)
    return Semester(PeriodsUTS(value(y) + value(dy)))
end

function (-)(y::SemesterDate, dy::Semester)
    return Semester(Periods.UTS(value(y) - value(dy)))
end

function (+)(y::UndatedDate, dy::Undated)
    return Undated(Periods.UTU(value(y) + value(dy)))
end

function (+)(dy::Undated, y::UndatedDate)
    return Undated(PeriodsUTU(value(y) + value(dy)))
end

function (-)(y::UndatedDate, dy::Undated)
    return Undated(Periods.UTU(value(y) - value(dy)))
end
