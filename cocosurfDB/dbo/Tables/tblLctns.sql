CREATE TABLE [dbo].[tblLctns] (
    [lctn_Id]      SMALLINT       IDENTITY (1, 1) NOT NULL,
    [lctn_tpe]     CHAR (2)       NOT NULL,
    [lctn_nme]     VARCHAR (50)   NOT NULL,
    [lctn_dsc]     VARCHAR (256)  NOT NULL,
    [lctn_UnqID]   VARCHAR (24)   NOT NULL,
    [lctn_address] NVARCHAR (256) NULL,
    [lctn_active]  BIT            CONSTRAINT [DF_tblLctns_lctn_active] DEFAULT ((1)) NOT NULL,
    [lctn_dflt]    BIT            CONSTRAINT [DF_tblLctns_lctn_dflt] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblLctns] PRIMARY KEY CLUSTERED ([lctn_Id] ASC, [lctn_tpe] ASC, [lctn_nme] ASC)
);

