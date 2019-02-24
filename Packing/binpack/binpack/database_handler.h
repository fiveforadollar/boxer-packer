#include "sqlite3.h"

/* Database callback function */
static int callback(void *NotUsed, int argc, char **argv, char **azColName) {
	int i;
	for (i = 0; i < argc; i++) {
		printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
	}
	printf("\n");
	return 0;
}

/*  Database table initialization function */
int initializeDatabase() {
	sqlite3 *db;
	char *zErrMsg = 0;
	int rc;
	char *sql;

	/* Open database */
	rc = sqlite3_open("test.db", &db);

	if (rc) {
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(0);
	}
	else {
		fprintf(stdout, "Opened database successfully\n");
	}

	/* Create Boxes Table */
	sql = "CREATE TABLE IF NOT EXISTS BOXES("  \
		"ID INT PRIMARY KEY     NOT NULL," \
		"READY          INT     NOT NULL," \
		"CAM1LEN        FLOAT," \
		"CAM1WIDTH      FLOAT," \
		"CAM1DIST       FLOAT," \
		"CAM2LEN        FLOAT," \
		"CAM2WIDTH      FLOAT," \
		"CAM2DIST       FLOAT," \
		"DONE           INT," \
		"SETID         INT );";

	/* Execute SQL statement */
	rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);

	if (rc != SQLITE_OK) {
		fprintf(stderr, "SQL error: %s\n", zErrMsg);
		sqlite3_free(zErrMsg);
	}
	else {
		fprintf(stdout, "Table BOXES created successfully\n");
	}

	/* Create Current Box Table*/
	sql = "CREATE TABLE IF NOT EXISTS CURRENTBOX("  \
		"SETID          INT PRIMARY KEY DEFAULT 0," \
		"BOXID          INT DEFAULT 0);";

	/* Execute SQL statement */
	rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);

	if (rc != SQLITE_OK) {
		fprintf(stderr, "SQL error: %s\n", zErrMsg);
		sqlite3_free(zErrMsg);
	}
	else {
		fprintf(stdout, "Table CURRENTBOX created successfully\n");
	}
	sqlite3_close(db);
	return 0;
}

/* Function to pass SQL command to database for execution */
int performSqlCommand(char * sql ) {
	sqlite3 *db;
	char *zErrMsg = 0;
	int rc;
	const char* data = "Callback function called";

	/* Open database */
	rc = sqlite3_open("test.db", &db);

	if (rc) {
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(0);
	}
	else {
		fprintf(stderr, "Opened database successfully\n");
	}

	/* Execute SQL statement */
	rc = sqlite3_exec(db, sql, callback, (void*)data, &zErrMsg);

	if (rc != SQLITE_OK) {
		fprintf(stderr, "SQL error: %s\n", zErrMsg);
		sqlite3_free(zErrMsg);
	}
	else {
		fprintf(stdout, "Operation done successfully\n");
	}
	sqlite3_close(db);
	return 0;
}