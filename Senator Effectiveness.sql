-- Individual Senator Effectiveness Metrics
SELECT 
    ds.FullName,
    ds.PartyAffiliation,
    ds.StateName,
    COUNT(DISTINCT CASE WHEN fb.IsPrimarySponsor = 1 THEN fb.BillKey END) AS BillsSponsored,
    COUNT(DISTINCT CASE WHEN fb.IsPrimarySponsor = 0 THEN fb.BillKey END) AS BillsCosponsored,
    COUNT(DISTINCT CASE WHEN fbs.StatusCode = 'PASS' AND fb.IsPrimarySponsor = 1 THEN fb.BillKey END) AS BillsEnacted,
    COUNT(DISTINCT fca.CommitteeKey) AS CommitteeAssignments,
    COUNT(DISTINCT fvr.VoteRecordKey) AS VotesCast,
    CAST(COUNT(DISTINCT CASE WHEN fvr.VoteCast = 'Yea' AND fvr.VoteResult = 'Passed' THEN fvr.VoteRecordKey END) * 100.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN fvr.VoteResult = 'Passed' THEN fvr.VoteRecordKey END), 0) AS DECIMAL(5,2)) AS SuccessVotePercentage,
    CAST(COUNT(DISTINCT CASE WHEN fvr.VoteCast = 'Yea' AND ds2.PartyAffiliation = ds.PartyAffiliation THEN fvr.VoteRecordKey END) * 100.0 /
        NULLIF(COUNT(DISTINCT fvr.VoteRecordKey), 0) AS DECIMAL(5,2)) AS PartyLoyaltyScore
FROM DimSenator ds
LEFT JOIN FactBillSponsorship fb ON ds.SenatorKey = fb.SenatorKey
LEFT JOIN FactBillStatus fbs ON fb.BillKey = fbs.BillKey
LEFT JOIN FactCommitteeAssignment fca ON ds.SenatorKey = fca.SenatorKey AND fca.AssignmentEndDate IS NULL
LEFT JOIN FactVoteRecord fvr ON ds.SenatorKey = fvr.SenatorKey
LEFT JOIN (
    SELECT VoteRecordKey, VoteCast, VoteResult 
    FROM FactVoteRecord
    GROUP BY VoteRecordKey, VoteCast, VoteResult
) v ON fvr.VoteRecordKey = v.VoteRecordKey
LEFT JOIN DimSenator ds2 ON fvr.SenatorKey = ds2.SenatorKey
WHERE ds.IsCurrent = 1
GROUP BY ds.FullName, ds.PartyAffiliation, ds.StateName
ORDER BY BillsEnacted DESC;