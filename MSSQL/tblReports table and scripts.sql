CREATE TABLE ReportLayouts (
    rptKey NVARCHAR(16) PRIMARY KEY,        -- Unique REport Key
    rptName NVARCHAR(100) NOT NULL,         -- Name of the Report
    rptLayoutJson NVARCHAR(MAX) NOT NULL,   -- Stores the template/rules as JSON
    rptDscrptn NVARCHAR(255) NULL,          -- Description of the Report
    rptCrtdBy NVARCHAR(100) NULL,           -- This report was created by
    rptCrtdDt DATETIME DEFAULT GETDATE(),   -- Date this report was created
    rptUpdBy NVARCHAR(100) NULL,            -- This report was updated By
    rptUpdDt DATETIME DEFAULT GETDATE()     -- Last date Report was updated
);