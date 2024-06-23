CREATE TABLE [dbo].[tblArlns] (
    [arln_id]       INT          IDENTITY (1, 1) NOT NULL,
    [arln_nme]      VARCHAR (50) CONSTRAINT [DF_tblArlns_arln_nme] DEFAULT ('Not specified') NOT NULL,
    [arln_isactive] BIT          CONSTRAINT [DF_tblArlns_arln_isactive] DEFAULT ((1)) NULL,
    [arln_srt_ordr] SMALLINT     CONSTRAINT [DF_tblArlns_arln_srt_ordr] DEFAULT ((1000)) NOT NULL,
    CONSTRAINT [PK_tblArlns] PRIMARY KEY CLUSTERED ([arln_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Arln ID Primary Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArlns', @level2type = N'COLUMN', @level2name = N'arln_id';

