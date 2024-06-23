CREATE TABLE [dbo].[tblCstmrs] (
    [CstmrID]     INT            IDENTITY (202400001, 1) NOT NULL,
    [CstmrFN]     NVARCHAR (50)  NULL,
    [CstmrLN]     NVARCHAR (50)  NULL,
    [CstmrEml]    NVARCHAR (128) NULL,
    [CstmrPhn1]   NCHAR (12)     NULL,
    [CstmrPhn2]   NCHAR (12)     NULL,
    [CstmrCrtdDt] SMALLDATETIME  CONSTRAINT [DF_tblCstmrs_CstmrCrtdDt] DEFAULT (getutcdate()) NOT NULL,
    [CstmrCrtdBy] NVARCHAR (128) CONSTRAINT [DF_tblCstmrs_CstmrCrtdBy] DEFAULT ('System') NULL,
    [CstmrActv]   BIT            CONSTRAINT [DF_tblCstmrs_CstmrActv] DEFAULT ((1)) NOT NULL,
    [CstmrFllNme] AS             (concat([CstmrFN],' ',[CstmrLN])),
    [CstmrLNFN]   AS             (concat([CstmrLN],', ',[CstmrFN])),
    [Cstmrupdt]   SMALLDATETIME  NULL,
    [CstmrupdtBy] VARCHAR (128)  NULL,
    CONSTRAINT [PK_tblCstmrs] PRIMARY KEY CLUSTERED ([CstmrID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCstmrs_CstmrEml]
    ON [dbo].[tblCstmrs]([CstmrEml] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique email addresses only', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCstmrs', @level2type = N'INDEX', @level2name = N'IX_tblCstmrs_CstmrEml';

