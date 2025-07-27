-- Cross-Party Collaboration Metrics
SELECT 
    db.BillNumber,
    db.Title,
    db.PrimarySubject,
    COUNT(DISTINCT CASE WHEN ds.PartyAffiliation = 'Democratic' THEN ds.SenatorKey END) AS DemocraticCosponsors,
    COUNT(DISTINCT CASE WHEN ds.PartyAffiliation = 'Republican' THEN ds.SenatorKey END) AS RepublicanCosponsors,
    COUNT(DISTINCT CASE WHEN ds.PartyAffiliation NOT IN ('Democratic', 'Republican') THEN ds.SenatorKey END) AS IndependentCosponsors,
    CAST(COUNT(DISTINCT CASE WHEN ds.PartyAffiliation = 'Republican' THEN ds.SenatorKey END) * 100.0 / 
        NULLIF(COUNT(DISTINCT ds.SenatorKey), 0) AS DECIMAL(5,2)) AS PctOppositionPartySupport,
    fvr.VoteResult,
    CASE WHEN COUNT(DISTINCT ds.PartyAffiliation) > 1 THEN 1 ELSE 0 END AS IsBipartisan
FROM DimBill db
JOIN FactBillSponsorship fbs ON db.BillKey = fbs.BillKey
JOIN DimSenator ds ON fbs.SenatorKey = ds.SenatorKey
LEFT JOIN (
    SELECT BillKey, VoteResult 
    FROM FactVoteRecord 
    WHERE VoteTypeKey IN (SELECT VoteTypeKey FROM DimVoteType WHERE VoteCategory = 'Substantive')
    GROUP BY BillKey, VoteResult
) fvr ON db.BillKey = fvr.BillKey
WHERE db.IsActive = 1
GROUP BY db.BillNumber, db.Title, db.PrimarySubject, fvr.VoteResult
HAVING COUNT(DISTINCT ds.PartyAffiliation) > 1
ORDER BY PctOppositionPartySupport DESC;