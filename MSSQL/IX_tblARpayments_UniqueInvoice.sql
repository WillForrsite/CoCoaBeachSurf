CREATE UNIQUE NONCLUSTERED INDEX IX_tblARpayments_UniqueInvoice
ON tblARpayments(pmtinvID)
WHERE pmtinvID <> '';

