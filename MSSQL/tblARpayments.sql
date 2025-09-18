/****** Object:  Table [dbo].[tblARpayments]    Script Date: 8/29/2025 8:24:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblARpayments](
	[pmtID] [char](8) NOT NULL,
	[pmtinvID] [char](20) NOT NULL,
	[pmtChkNo] [varchar](16) NULL,
	[pmtType] [char](2) NOT NULL,
	[pmtRefDoc] [varchar](1000) NULL,
	[pmtAmt] [money] NOT NULL,
	[pmtCrtdDtTm] [smalldatetime] NOT NULL,
	[pmtCrtdBy] [nvarchar](128) NOT NULL,
	[pmtUpdt] [smalldatetime] NULL,
	[pmtUpdtBy] [nvarchar](128) NULL,
	[pmtNotes] [varchar](max) NULL,
 CONSTRAINT [PK_tblARpayments_1] PRIMARY KEY CLUSTERED 
(
	[pmtID] DESC,
	[pmtinvID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


