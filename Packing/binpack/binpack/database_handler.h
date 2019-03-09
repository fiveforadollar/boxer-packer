#include "sqlite3.h"

/* Database callback function */
static int callback(void *data, int argc, char **argv, char **azColName) {
	int i;
	std::string results;
	for (i = 0; i < argc; i++) {
		printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");

		results += azColName[i];
		results += " = ";
		if (argv[i])
			results += argv[i];
		else
			results += "NULL";

		if (!(i == argc - 1))
			results += " | ";
	}
	printf("\n");
	results += "\n";

	char **result_str = (char **)data;
	*result_str = (char *)calloc(strlen(results.c_str()), sizeof(char));
	strcpy(*result_str, results.c_str());

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
std::string performSqlCommand(const char * sql) {
	sqlite3 *db;
	char *zErrMsg = 0;
	int rc;
	char * result_str = "Results";

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
	printf(sql);
	printf("\n");
	rc = sqlite3_exec(db, sql, callback, &result_str, &zErrMsg);
	std::string retStr = result_str;

	if (rc != SQLITE_OK) {
		fprintf(stderr, "SQL error: %s\n", zErrMsg);
		sqlite3_free(zErrMsg);
	}
	else {
		fprintf(stdout, "Operation done successfully\n");
	}
	sqlite3_close(db);

	return retStr;
}

std::vector<std::string> performSqlCommandMultiRow(const char * sql) {
	sqlite3 *db;
	char *zErrMsg = 0;
	int rc;
	std::vector<std::string> queryRows;

	/* Open database */
	rc = sqlite3_open("test.db", &db);

	if (rc) {
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(queryRows);
	}
	else {
		fprintf(stderr, "Opened database successfully\n");
	}

	sqlite3_stmt *stmt;
	rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
	
	if (rc != SQLITE_OK) {
		std::cerr << "SELECT failed: " << sqlite3_errmsg(db) << std::endl;
		return queryRows;
	}

	while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
		int colCount = sqlite3_column_count(stmt);
		std::cout << "Num cols:" << colCount << std::endl;
		const char* id = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0));
		//const char* ready = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));
		//const char* cam1len = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1));

		std::string myRow = id;
		std::cout << "myRow: " << id << std::endl;
		//myRow += ready;

		queryRows.push_back(myRow);
	}
	if (rc != SQLITE_DONE) {
		std::cerr << "SELECT failed: " << sqlite3_errmsg(db) << std::endl;
		// if you return/throw here, don't forget the finalize
	}
	sqlite3_finalize(stmt);

	sqlite3_close(db);

	return queryRows;
}