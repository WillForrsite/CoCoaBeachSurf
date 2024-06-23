CREATE TABLE [dbo].[Authentication] (
    [Id]       INT             IDENTITY (1, 1) NOT NULL,
    [Userid]   NVARCHAR (128)  NULL,
    [Email]    NVARCHAR (100)  NULL,
    [Token]    NVARCHAR (1000) NULL,
    [DeviceID] NVARCHAR (128)  NULL,
    [AppId]    INT             NULL,
    [SignIn]   TINYINT         NULL,
    [SignOut]  TINYINT         NULL,
    [LastUsed] NVARCHAR (50)   NULL,
    CONSTRAINT [PK_Authentication] PRIMARY KEY CLUSTERED ([Id] ASC)
);

