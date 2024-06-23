CREATE TABLE [dbo].[tblRsvrtns] (
    [RsrvtnID]        UNIQUEIDENTIFIER CONSTRAINT [DF_tblRsvrtns_RsrvtnID] DEFAULT (newid()) NOT NULL,
    [RsrvtnCstmrID]   INT              NOT NULL,
    [RsrvtnDateTm]    SMALLDATETIME    CONSTRAINT [DF_tblRsvrtns_RsrvtnDateTm] DEFAULT (getutcdate()) NOT NULL,
    [RsrvtnActive]    BIT              CONSTRAINT [DF_tblRsvrtns_RsrvtnActive] DEFAULT ((1)) NOT NULL,
    [RsvrtnCreated]   SMALLDATETIME    CONSTRAINT [DF_tblRsvrtns_RsvrtnCreated] DEFAULT (getutcdate()) NOT NULL,
    [RsvrtnCreatedBy] NVARCHAR (128)   CONSTRAINT [DF_tblRsvrtns_RsvrtnCreatedBy] DEFAULT ('System') NOT NULL,
    [RsvrtnUpdt]      SMALLDATETIME    NULL,
    [RsvrtnUpdtBy]    NVARCHAR (128)   NULL,
    CONSTRAINT [PK_tblRsvrtns] PRIMARY KEY CLUSTERED ([RsrvtnID] ASC)
);

