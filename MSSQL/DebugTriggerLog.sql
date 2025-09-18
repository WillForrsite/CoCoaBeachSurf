/****** Object:  Table [dbo].[DebugTriggerLog]    Script Date: 8/5/2025 8:56:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DebugTriggerLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Message] [nvarchar](255) NULL,
	[LoggedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DebugTriggerLog] ADD  DEFAULT (getdate()) FOR [LoggedAt]
GO


