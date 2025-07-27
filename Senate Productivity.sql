-- Senate Productivity by Party and Session (Corrected)
SELECT 
    dd.CongressionalSession,
    ds.PartyAffiliation,
    COUNT(DISTINCT fb.BillKey) AS BillsSponsored,
    COUNT(DISTINCT fbs.BillKey) AS BillsPassed,
    CAST(COUNT(DISTINCT fbs.BillKey) * 100.0 / NULLIF(COUNT(DISTINCT fb.BillKey), 0) 
        AS DECIMAL(5,2)) AS PassageRate,
    AVG(fv.VotesCast) AS AvgVotesPerSenator,
    CAST(SUM(CASE WHEN fvr.VoteCast = 'Yea' THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(fvr.VoteRecordKey) AS DECIMAL(5,2)) AS PartyUnityScore
FROM DimSenator ds
JOIN FactBillSponsorship fb ON ds.SenatorKey = fb.SenatorKey
JOIN DimDate dd ON fb.DateKey = dd.DateKey
LEFT JOIN FactBillStatus fbs ON fb.BillKey = fbs.BillKey AND fbs.StatusCode = 'PASS'
LEFT JOIN (
    SELECT SenatorKey, COUNT(*) AS VotesCast 
    FROM FactVoteRecord 
    GROUP BY SenatorKey
) fv ON ds.SenatorKey = fv.SenatorKey
LEFT JOIN FactVoteRecord fvr ON ds.SenatorKey = fvr.SenatorKey
WHERE fb.IsPrimarySponsor = 1
GROUP BY dd.CongressionalSession, ds.PartyAffiliation
ORDER BY dd.CongressionalSession, BillsSponsored DESC;