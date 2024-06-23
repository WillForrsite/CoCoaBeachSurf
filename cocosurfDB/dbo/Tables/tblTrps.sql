CREATE TABLE [dbo].[tblTrps] (
    [trpID]              INT            IDENTITY (2024000001, 1) NOT NULL,
    [trpRsrvtnID]        NVARCHAR (8)   NOT NULL,
    [trpPckDate]         DATE           NOT NULL,
    [trpPckTm]           TIME (7)       NOT NULL,
    [trpPssngrs]         TINYINT        CONSTRAINT [DF_tblTrps_TrpPckLctnPssngrs] DEFAULT ((0)) NOT NULL,
    [trpCst]             MONEY          CONSTRAINT [DF_tblTrps_trpCst] DEFAULT ((0)) NOT NULL,
    [trpPckLctnTpe]      SMALLINT       NOT NULL,
    [trpPckLctnUnqID]    VARCHAR (24)   NOT NULL,
    [trpPckLctnSubUnqID] VARCHAR (24)   NULL,
    [trpPckLctnTm]       TIME (7)       NULL,
    [trpDrpLctnTpe]      SMALLINT       NOT NULL,
    [trpDrpLctnUnqID]    VARCHAR (24)   NOT NULL,
    [trpDrpLctnSubUnqID] NCHAR (10)     NULL,
    [trpDrpLctnTm]       TIME (7)       NULL,
    [trpWC]              BIT            CONSTRAINT [DF_tblTrps_trpWhlChr] DEFAULT ((0)) NULL,
    [trpWCfld]           NCHAR (10)     NULL,
    [trpAddtnfo]         VARCHAR (256)  NULL,
    [trpCrtdDtTm]        SMALLDATETIME  CONSTRAINT [DF_tblTrps_trpCrtdDtTm] DEFAULT (getutcdate()) NOT NULL,
    [trpCrtdBy]          NVARCHAR (128) CONSTRAINT [DF_tblTrps_trpCrtdBy] DEFAULT ('System') NOT NULL,
    [trpUpdt]            SMALLDATETIME  NULL,
    [trpUpdtBy]          NVARCHAR (128) NULL,
    CONSTRAINT [PK_tblTrps] PRIMARY KEY CLUSTERED ([trpRsrvtnID] ASC, [trpID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblTrpsID]
    ON [dbo].[tblTrps]([trpID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblTrpsPckDate]
    ON [dbo].[tblTrps]([trpPckDate] ASC);

