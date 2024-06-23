CREATE TABLE [dbo].[tblLctnTpe] (
    [lctn_tpe_Id]     SMALLINT     IDENTITY (1, 1) NOT NULL,
    [lctn_tpe]        CHAR (2)     NOT NULL,
    [lctn_tpe_dsc]    VARCHAR (50) NOT NULL,
    [lctn_tpe_active] BIT          CONSTRAINT [DF_tblLctnTpe_lctn_tpe_active] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblLctnTpe] PRIMARY KEY CLUSTERED ([lctn_tpe] ASC)
);

