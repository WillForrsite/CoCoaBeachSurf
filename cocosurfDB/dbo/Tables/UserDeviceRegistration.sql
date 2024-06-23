CREATE TABLE [dbo].[UserDeviceRegistration] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [UserID]          NVARCHAR (128) NOT NULL,
    [DeviceID]        NVARCHAR (128) NOT NULL,
    [AppID]           INT            NOT NULL,
    [Email]           NVARCHAR (100) NOT NULL,
    [DeviceName]      NVARCHAR (500) NULL,
    [DeviceOs]        NVARCHAR (100) NULL,
    [DeviceOsVersion] NVARCHAR (100) NULL,
    [DeviceConfirmed] BIT            CONSTRAINT [DF_UserDeviceRegistration_DeviceConfirmed] DEFAULT ((0)) NOT NULL,
    [IsActive]        BIT            CONSTRAINT [DF_UserDeviceRegistration_IsActive] DEFAULT ((1)) NULL,
    [IsDeleted]       BIT            CONSTRAINT [DF_UserDeviceRegistration_IsUserDeleted] DEFAULT ((0)) NULL,
    CONSTRAINT [pk_myCompositeConstraint] PRIMARY KEY CLUSTERED ([UserID] ASC, [DeviceID] ASC, [AppID] ASC)
);

