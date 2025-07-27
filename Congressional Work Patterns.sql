-- Congressional Work Patterns by Month
SELECT 
    dd.MonthName,
    dd.Year,
    dd.CongressionalSession,
    COUNT(DISTINCT CASE WHEN dd.IsCongressionalSessionDay = 1 THEN dd.FullDate END) AS SessionDays,
    COUNT(DISTINCT fbs.BillKey) AS BillsIntroduced,
    COUNT(DISTINCT fvr.VoteRecordKey) AS VotesTaken,
    COUNT(DISTINCT CASE WHEN fbs.StatusCode = 'PASS' THEN fbs.BillKey END) AS BillsPassed,
    COUNT(DISTINCT CASE WHEN dd.IsHoliday = 1 THEN dd.FullDate END) AS Holidays,
    COUNT(DISTINCT CASE WHEN dd.IsCongressionalSessionDay = 0 AND dd.IsWeekday = 1 THEN dd.FullDate END) AS RecessWeekdays
FROM DimDate dd
LEFT JOIN FactBillStatus fbs ON dd.DateKey = fbs.DateKey AND fbs.StatusCode = 'INTRO'
LEFT JOIN FactVoteRecord fvr ON dd.DateKey = fvr.DateKey
WHERE dd.FullDate BETWEEN '2023-01-01' AND '2025-12-31'
GROUP BY dd.MonthName, dd.Year, dd.CongressionalSession, dd.MonthNumber
ORDER BY dd.Year, dd.MonthNumber;