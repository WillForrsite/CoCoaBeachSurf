CREATE TABLE dbo.tblConfig (
    ConfigKey NVARCHAR(50),          -- e.g. 'DebugMode'
    ConfigValue NVARCHAR(200),       -- e.g. 'On', 'Off'
    Environment NVARCHAR(20),        -- e.g. 'Prod', 'Dev', 'Stag'
    IsDefault BIT,                   -- fallback flag: 1 = use when no match
    CONSTRAINT PK_tblConfig PRIMARY KEY (ConfigKey, Environment)
);
go
CREATE FUNCTION dbo.fn_GetConfigValue (
    @ConfigKey NVARCHAR(50),
    @Environment NVARCHAR(20)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @value NVARCHAR(200);

    SELECT @value = ConfigValue
    FROM dbo.tblConfig
    WHERE ConfigKey = @ConfigKey
      AND Environment = @Environment;

    IF @value IS NULL
    BEGIN
        SELECT @value = ConfigValue
        FROM dbo.tblConfig
        WHERE ConfigKey = @ConfigKey
          AND IsDefault = 1;
    END

    RETURN @value;
END
go
SELECT dbo.fn_GetConfigValue('DebugMode', 'Stag');
-- Returns 'On'

SELECT dbo.fn_GetConfigValue('DebugMode', 'QA');
-- No QA override → Falls back to default → Returns 'Off'