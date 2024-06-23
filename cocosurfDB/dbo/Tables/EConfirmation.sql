CREATE TABLE [dbo].[EConfirmation] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [GuidKey]     NVARCHAR (128)  NULL,
    [CallbackUrl] NVARCHAR (1000) NULL,
    [CreatedDate] DATETIME        NULL,
    [SendDate]    DATETIME        NULL,
    CONSTRAINT [PK_EConfirmation] PRIMARY KEY CLUSTERED ([Id] ASC)
);

