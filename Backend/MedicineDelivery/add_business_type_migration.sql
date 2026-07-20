START TRANSACTION;


DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260705095605_AddBusinessTypeToMedicalStore') THEN
    ALTER TABLE "MedicalStores" ADD "BusinessType" integer NOT NULL DEFAULT 4;
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260705095605_AddBusinessTypeToMedicalStore') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260705095605_AddBusinessTypeToMedicalStore', '8.0.0');
    END IF;
END $EF$;
COMMIT;

