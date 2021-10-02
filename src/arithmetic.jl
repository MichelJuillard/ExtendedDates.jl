
# TimeType-Year arithmetic
function (+)(y::YearDate, dy::Year)
    return YearDate(UTY(Year(value(y) + Dates.value(dy))))
end

function (+)(dy::Year, y::YearDate)
    return YearDate(UTY(Year(value(y) + Dates.value(dy))))
end

function (-)(y::YearDate, dy::Year)
    return YearDate(UTY(Year(value(y) - Dates.value(dy))))
end

function (+)(y::SemesterDate, dy::Year)
    return SemesterDate(UTS(value(y) + 2 * value(dy)))
end

function (+)(dy::Year, y::SemesterDate)
    return SemesterDate(UTS(value(y) + 2 * value(dy)))
end

function (-)(y::SemesterDate, dy::Year)
    return SemesterDate(UTS(value(y) - 2 * value(dy)))
end

function (+)(y::SemesterDate, dy::Semester)
    return SemesterDate(UTS(value(y) + value(dy)))
end

function (+)(dy::Semester, y::SemesterDate)
    return SemesterDate(UTS(value(y) + value(dy)))
end

function (-)(y::SemesterDate, dy::Semester)
    return SemesterDate(UTS(value(y) - value(dy)))
end

function (+)(y::QuarterDate, dy::Year)
    return QuarterDate(UTQ(value(y) + 4 * value(dy)))
end

function (+)(dy::Year, y::QuarterDate)
    return QuarterDate(UTQ(value(y) + 4 * value(dy)))
end

function (-)(y::QuarterDate, dy::Year)
    return QuarterDate(UTQ(value(y) - 4 * value(dy)))
end

function (+)(y::QuarterDate, dy::Semester)
    return QuarterDate(UTQ(value(y) + 2 * value(dy)))
end

function (+)(dy::Semester, y::QuarterDate)
    return QuarterDate(UTQ(value(y) + 2 * value(dy)))
end

function (-)(y::QuarterDate, dy::Semester)
    return QuarterDate(UTQ(value(y) - 2 * value(dy)))
end

function (+)(y::QuarterDate, dy::Quarter)
    return QuarterDate(UTQ(value(y) + value(dy)))
end

function (+)(dy::Quarter, y::QuarterDate)
    return QuarterDate(UTQ(value(y) + value(dy)))
end

function (-)(y::QuarterDate, dy::Quarter)
    return QuarterDate(UTQ(value(y) - value(dy)))
end

function (+)(y::MonthDate, dy::Year)
    return MonthDate(UTM(value(y) + 12 * value(dy)))
end

function (+)(dy::Year, y::MonthDate)
    return MonthDate(UTM(value(y) + 12 * value(dy)))
end

function (-)(y::MonthDate, dy::Year)
    return MonthDate(UTM(value(y) - 12 * value(dy)))
end

function (+)(y::MonthDate, dy::Semester)
    return MonthDate(UTM(value(y) + 6 * value(dy)))
end

function (+)(dy::Semester, y::MonthDate)
    return MonthDate(UTM(value(y) + 6 * value(dy)))
end

function (-)(y::MonthDate, dy::Semester)
    return MonthDate(UTM(value(y) - 6 * value(dy)))
end

function (+)(y::MonthDate, dy::Quarter)
    return MonthDate(UTM(value(y) + 3 * value(dy)))
end

function (+)(dy::Quarter, y::MonthDate)
    return MonthDate(UTM(value(y) + 3 * value(dy)))
end

function (-)(y::MonthDate, dy::Quarter)
    return MonthDate(UTM(value(y) - 3 * value(dy)))
end

function (+)(y::MonthDate, dy::Month)
    return MonthDate(UTM(value(y) + value(dy)))
end

function (+)(dy::Month, y::MonthDate)
    return MonthDate(UTM(value(y) + value(dy)))
end

function (-)(y::MonthDate, dy::Month)
    return MonthDate(UTM(value(y) - value(dy)))
end

function (+)(w::WeekDate, dy::Year)
    y = year(w)
    return WeekDate(UTW(value(w) + weeksinyear(y, y + value(dy))))
end

function (+)(dy::Year, w::WeekDate)
    y = year(w)
    return WeekDate(UTW(value(w) + weeksinyear(y, y + value(dy))))
end

function (-)(w::WeekDate, dy::Year)
    y = year(w)
    return WeekDate(UTW(value(w) - weeksinyear(y - value(dy), y)))
end

function (+)(w::WeekDate, dy::Semester)
    d1 = DayDate(UTD(Dates.WEEKEPOCH + 7 * value(w)))
    d2 = d1 + dy
    if dayofweek(d2) > 4
        return WeekDate(year(d2), week(d2)) + Week(1)
    else
        return WeekDate(year(d2), week(d2))
    end
end

function (+)(dy::Semester, w::WeekDate)
    return w + dy
end

function (-)(w::WeekDate, dy::Semester)
    d1 = DayDate(UTD(Dates.WEEKEPOCH + 7 * value(w)))
    d2 = d1 - dy
    if dayofweek(d2) > 4
        return WeekDate(year(d2), week(d2)) + Week(1)
    else
        return WeekDate(year(d2), week(d2))
    end
end

function (+)(w::WeekDate, dy::Quarter)
    d1 = DayDate(UTD(Dates.WEEKEPOCH + 7 * value(w)))
    d2 = d1 + dy
    if dayofweek(d2) > 4
        return WeekDate(year(d2), week(d2)) + Week(1)
    else
        return WeekDate(year(d2), week(d2))
    end
end

function (+)(dy::Quarter, w::WeekDate)
    return w + dy
end

function (-)(w::WeekDate, dy::Quarter)
    return WeekDate(UTW(value(w) - value(dy)))
end

function (+)(w::WeekDate, dy::Month)
    d1 = DayDate(UTD(Dates.WEEKEPOCH + 7 * value(w)))
    d2 = d1 + dy
    if dayofweek(d2) > 4
        return WeekDate(year(d2), week(d2)) + Week(1)
    else
        return WeekDate(year(d2), week(d2))
    end
end

function (+)(dy::Month, w::WeekDate)
    return w + dy
end

function (-)(w::WeekDate, dy::Month)
    return WeekDate(UTW(value(w) - value(dy)))
end

function (+)(w::WeekDate, dy::Week)
    # Date of Thursday week w
    d1 = DayDate(UTD(7 * (value(w) - 1) + 4))
    d2 = d1 + dy
    y2 = year(d2)
    w2 = week(d2)
    if dayofweek(d2) > 4
        if w2 == weeksinyear(y2)
            return WeekDate(y2 + 1, 1)
        else
            return WeekDate(y2, w2 + 1)
        end
    else
        return WeekDate(y2, w2)
    end
end

function (+)(dy::Week, w::WeekDate)
    return w + dy
end

function (-)(w::WeekDate, dy::Week)
    return WeekDate(UTW(value(w) - value(dy)))
end

function (+)(y::DayDate, dy::Year)
    yy, mm, dd = yearmonthday(y)
    y2 = yy + value(dy)
    ld = daysinmonth(y2, mm)
    return DayDate(y2, mm, (dd > ld) ? ld : dd)
end

function (+)(dy::Year, y::DayDate)
    return y + dy
end

function (-)(y::DayDate, dy::Year)
    yy, mm, dd = yearmonthday(y)
    y2 = yy - value(dy)
    ld = daysinmonth(y2, mm)
    return DayDate(y2, mm, (dd > ld) ? ld : dd)
end

function (+)(d::DayDate, ds::Semester)
    y1, m1, d1 = yearmonthday(d)
    dm = 6 * value(ds)
    y2 = Dates.yearwrap(y1, m1, dm)
    m2 = Dates.monthwrap(m1, dm)
    ld = daysinmonth(y2, m2)
    return DayDate(y2, m2, (d1 > ld) ? ld : d1)
end

function (+)(dy::Year, y::DayDate)
    return y + dy
end

function (-)(d::DayDate, ds::Semester)
    y1, m1, d1 = yearmonthday(d)
    dm = 6 * value(ds)
    y2 = Dates.yearwrap(y1, m1, -6 * dm)
    m2 = Dates.monthwrap(m1, dm)
    ld = daysinmonth(y2, m2)
    return DayDate(y2, m2, (d1 > ld) ? ld : d1)
end

function (+)(d::DayDate, dq::Quarter)
    y1, m1, d1 = yearmonthday(d)
    dm = 3 * value(dq)
    y2 = Dates.yearwrap(y1, m1, dm)
    m2 = Dates.monthwrap(m1, dm)
    ld = daysinmonth(y2, m2)
    return DayDate(y2, m2, (d1 > ld) ? ld : d1)
end

function (+)(dy::Quarter, y::DayDate)
    return y + dy
end

function (-)(d::DayDate, dq::Quarter)
    y1, m1, d1 = yearmonthday(d)
    dm = 6 * value(dq)
    y2 = Dates.yearwrap(y1, m1, -dm)
    m2 = Dates.monthwrap(m1, dm)
    ld = daysinmonth(y2, m2)
    return DayDate(y2, m2, (d1 > ld) ? ld : d1)
end

function (+)(d::DayDate, dm::Month)
    y1, m1, d1 = yearmonthday(d)
    y2 = Dates.yearwrap(y1, m1, value(dm))
    m2 = Dates.monthwrap(m1, value(dm))
    ld = daysinmonth(y2, m2)
    return DayDate(y2, m2, (d1 > ld) ? ld : d1)
end

function (+)(dy::Month, y::DayDate)
    return y + dy
end

function (-)(d::DayDate, dm::Month)
    y1, m1, d1 = yearmonthday(d)
    y2 = Dates.yearwrap(y1, m1, -value(dm))
    m2 = Dates.monthwrap(m1, -value(dm))
    ld = daysinmonth(y2, m2)
    return DayDate(y2, m2, (d1 > ld) ? ld : d1)
end

function (+)(y::DayDate, dy::Week)
    return DayDate(UTD(value(y) + 7 * value(dy)))
end

function (+)(dy::Week, y::DayDate)
    return y + dy
end

function (-)(y::DayDate, dy::Week)
    return DayDate(UTD(value(y) - 7 * value(dy)))
end

function (+)(y::DayDate, dy::Day)
    return DayDate(UTD(value(y) + value(dy)))
end

function (+)(dy::Day, y::DayDate)
    return DayDate(UTD(value(y) + value(dy)))
end

function (-)(y::DayDate, dy::Day)
    return DayDate(UTD(value(y) - value(dy)))
end

function (+)(y::UndatedDate, dy::Undated)
    return UndatedDate(UTU(value(y) + value(dy)))
end

function (+)(dy::Undated, y::UndatedDate)
    return UndatedDate(UTU(value(y) + value(dy)))
end

function (-)(y::UndatedDate, dy::Undated)
    return UndatedDate(UTU(value(y) - value(dy)))
end
