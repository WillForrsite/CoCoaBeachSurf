CREATE TABLE dbo.tblARpaymentsDtl
(
    arPmtDtlID  BIGINT IDENTITY(1,1) PRIMARY KEY,
    invNbr      VARCHAR(20) NOT NULL,
    pmtID       VARCHAR(8)  NOT NULL,
    allocAmt    MONEY       NOT NULL,
    allocDt     DATETIME2(0) NOT NULL CONSTRAINT DF_tblARpaymentsDtl_allocDt DEFAULT SYSUTCDATETIME(),
    allocBy     NVARCHAR(128) NOT NULL,
    notes       NVARCHAR(MAX) NULL,

    -- Audit columns
    rowCrtdDtTm DATETIME2(0) NOT NULL CONSTRAINT DF_tblARpaymentsDtl_rowCrtdDtTm DEFAULT SYSUTCDATETIME(),
    rowCrtdBy   NVARCHAR(128) NOT NULL,
    rowUpdtDtTm DATETIME2(0) NULL,
    rowUpdtBy   NVARCHAR(128) NULL
);

CREATE NONCLUSTERED INDEX IX_tblARpaymentsDtl_invNbr
    ON dbo.tblARpaymentsDtl(invNbr)
    INCLUDE (allocAmt);

CREATE NONCLUSTERED INDEX IX_tblARpaymentsDtl_pmtID
    ON dbo.tblARpaymentsDtl(pmtID)
    INCLUDE (invNbr, allocAmt);