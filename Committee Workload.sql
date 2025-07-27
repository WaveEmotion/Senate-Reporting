-- Committee Workload and Partisan Breakdown
SELECT 
    dc.CommitteeName,
    dc.CommitteeType,
    COUNT(DISTINCT CASE WHEN fbs.IsCurrentStatus = 1 THEN fbs.BillKey END) AS ActiveBills,
    COUNT(DISTINCT fca.SenatorKey) AS Members,
    SUM(CASE WHEN ds.PartyAffiliation = 'Democratic' THEN 1 ELSE 0 END) AS DemocraticMembers,
    SUM(CASE WHEN ds.PartyAffiliation = 'Republican' THEN 1 ELSE 0 END) AS RepublicanMembers,
    COUNT(DISTINCT fvr.VoteRecordKey) AS CommitteeVotes,
    MIN(dd.FullDate) AS FirstSessionDate,
    MAX(dd.FullDate) AS LastSessionDate
FROM DimCommittee dc
LEFT JOIN FactBillStatus fbs ON dc.CommitteeKey = fbs.BillKey -- Assuming relationship
LEFT JOIN FactCommitteeAssignment fca ON dc.CommitteeKey = fca.CommitteeKey AND fca.AssignmentEndDate IS NULL
LEFT JOIN DimSenator ds ON fca.SenatorKey = ds.SenatorKey
LEFT JOIN FactVoteRecord fvr ON dc.CommitteeKey = fvr.CommitteeKey
LEFT JOIN DimDate dd ON fvr.DateKey = dd.DateKey
WHERE dc.IsActive = 1
GROUP BY dc.CommitteeName, dc.CommitteeType
ORDER BY ActiveBills DESC;