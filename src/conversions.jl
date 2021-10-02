# This file is a part of Julia. License is MIT: https://julialang.org/license

# Conversion/Promotion

for T in
    (:DayDate, :WeekDate, :MonthDate, :QuarterDate, :SemesterDate, :YearDate, :UndatedDate)
    @eval begin
        $T(dt::Dates.TimeType) = convert($T, dt)
    end
end
