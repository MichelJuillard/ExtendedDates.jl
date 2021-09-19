# Adding Semester to Date.DatePeriod
struct Semester <: Dates.DatePeriod
    value::Int64
    Semester(v::Number) = new(v)
end

# Adding Undated to Dates.DatePeriod
struct Undated <: Dates.DatePeriod
    value::UInt64
    Undated(v::Number) = new(v)
end
value(d::Semester) = d.value
value(d::Undated) = d.value

