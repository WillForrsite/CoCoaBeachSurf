CREATE TABLE [dbo].[AppType] (
    [Id]      INT           IDENTITY (1, 1) NOT NULL,
    [AppType] VARCHAR (500) NULL,
    CONSTRAINT [PK_AppType] PRIMARY KEY CLUSTERED ([Id] ASC)
);

