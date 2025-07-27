SELECT 
    c.CommitteeName,
    COUNT(DISTINCT b.BillKey) AS BillsReferred,
    COUNT(DISTINCT v.VoteRecordKey) AS VotesTaken,
    COUNT(DISTINCT CASE WHEN bs.StatusCode = 'PASS' THEN b.BillKey END) AS BillsPassed
FROM DimCommittee c
LEFT JOIN FactVoteRecord v ON c.CommitteeKey = v.CommitteeKey
LEFT JOIN DimBill b ON v.BillKey = b.BillKey
LEFT JOIN FactBillStatus bs ON b.BillKey = bs.BillKey
GROUP BY c.CommitteeName
ORDER BY BillsReferred DESC;