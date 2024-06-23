CREATE TABLE [dbo].[settings] (
    [property]          NVARCHAR (64) NOT NULL,
    [value]             NVARCHAR (64) NOT NULL,
    [date_last_updated] DATETIME      NOT NULL,
    CONSTRAINT [IX_settings] UNIQUE NONCLUSTERED ([property] ASC) WITH (FILLFACTOR = 90)
);

