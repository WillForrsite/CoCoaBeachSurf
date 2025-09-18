/****** Object:  Table [dbo].[tblARinvoice]    Script Date: 8/29/2025 8:22:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblARinvoice](
	[invID] [char](8) NOT NULL,
	[invNbr] [varchar](20) NOT NULL,
	[invType] [char](2) NOT NULL,
	[invCstmID] [varchar](50) NOT NULL,
	[invRefDoc] [varchar](1000) NULL,
	[invPrcMtx] [char](6) NULL,
	[invAmt] [money] NULL,
	[invStatus] [smallint] NULL,
	[invStatusDesc]  AS (case [invStatus] when (0) then 'Open' when (1) then 'Paid' when (2) then 'In Process' else 'In Dispute' end),
	[invCrtdDtTm] [smalldatetime] NOT NULL,
	[invCrtdBy] [nvarchar](128) NOT NULL,
	[invUpdt] [smalldatetime] NULL,
	[invUpdtBy] [nvarchar](128) NULL,
	[invClsDt] [datetime] NULL,
	[invNotes] [varchar](max) NULL,
	[invJulDate]  AS (case when len([invNbr])>(8) AND TRY_CAST(left([invNbr],(5)) AS [int]) IS NOT NULL then dateadd(day,TRY_CAST(substring([invNbr],(3),(3)) AS [int])-(1),datefromparts((2000)+TRY_CAST(substring([invNbr],(1),(2)) AS [int]),(1),(1)))  end),
 CONSTRAINT [PK_tblARinvoice_1] PRIMARY KEY CLUSTERED 
(
	[invID] DESC,
	[invNbr] ASC,
	[invType] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
