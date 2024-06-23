CREATE TABLE [dbo].[tblHotels] (
    [htl_id]       INT          IDENTITY (1, 1) NOT NULL,
    [htl_nme]      VARCHAR (50) CONSTRAINT [DF_tblHotels_htl_nme] DEFAULT ('Not specified') NOT NULL,
    [htl_isactive] BIT          CONSTRAINT [DF_tblHotels_htl_isactive] DEFAULT ((1)) NULL,
    [htl_srt_ordr] SMALLINT     CONSTRAINT [DF_tblHotels_htl_srt_ordr] DEFAULT ((1000)) NOT NULL,
    CONSTRAINT [PK_tblHotels] PRIMARY KEY CLUSTERED ([htl_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hotel ID Primary Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHotels', @level2type = N'COLUMN', @level2name = N'htl_id';

