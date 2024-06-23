CREATE TABLE [dbo].[AppRegistration] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [AppName]           VARCHAR (500)  NULL,
    [Url]               NVARCHAR (500) NULL,
    [ImagePath]         NVARCHAR (500) NULL,
    [DefaultAuthorized] SMALLINT       CONSTRAINT [DF_AppRegistration_DefaultAuthorized] DEFAULT ((0)) NULL,
    [IsActive]          TINYINT        CONSTRAINT [DF_AppRegistration_IsActive] DEFAULT ((0)) NULL,
    [AppType]           INT            NULL,
    CONSTRAINT [PK_AppRegistration] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AppRegistration_AppType] FOREIGN KEY ([AppType]) REFERENCES [dbo].[AppType] ([Id])
);

