CREATE TABLE [dbo].[AppUserValidation] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [UserId]        NVARCHAR (128) NULL,
    [AppId]         INT            NULL,
    [IsAppAdmin]    TINYINT        CONSTRAINT [DF_AppUserValidation_IsAppAdmin] DEFAULT ((0)) NULL,
    [IsGlobalAdmin] TINYINT        CONSTRAINT [DF_AppUserValidation_IsGlobalAdmin] DEFAULT ((0)) NULL,
    [IsAllowAccess] TINYINT        CONSTRAINT [DF_AppUserValidation_IsAllowAccess] DEFAULT ((0)) NULL,
    [IsDeleted]     TINYINT        CONSTRAINT [DF_AppUserValidation_IsDelete] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_AppUserValidation] PRIMARY KEY CLUSTERED ([Id] ASC)
);

