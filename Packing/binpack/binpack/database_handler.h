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
		"SETID         INT NOT NULL); DELETE FROM BOXES; INSERT INTO BOXES (ID, READY, SETID) VALUES (1, 0, 0);";

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
		"SETID          INT PRIMARY KEY DEFAULT 0 NOT NULL," \
		"BOXID          INT DEFAULT 0); DELETE FROM CURRENTBOX; INSERT INTO CURRENTBOX (SETID, BOXID) VALUES (0, 1);";

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

std::vector<std::map<std::string, std::string>> performSqlCommandMultiRow(const char * sql) {
	sqlite3 *db;
	char *zErrMsg = 0;
	int rc;
	std::vector<std::map<std::string, std::string>> listOfRows;

	/* Open database */
	rc = sqlite3_open("test.db", &db);

	if (rc) {
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(listOfRows);
	}
	else {
		fprintf(stderr, "Opened database successfully\n");
	}

	sqlite3_stmt *stmt;
	std::cout << sql << std::endl;
	rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
	
	if (rc != SQLITE_OK) {
		std::cerr << "SELECT failed: " << sqlite3_errmsg(db) << std::endl;
		return listOfRows;
	}

	while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
		int colCount = sqlite3_column_count(stmt);
		std::map<std::string, std::string> mappedRow;

		for (int i = 0; i < colCount; i++) {
			const char* colName = reinterpret_cast<const char*>(sqlite3_column_name(stmt, i));
			const char* colData = reinterpret_cast<const char*>(sqlite3_column_text(stmt, i));

			if (!colData) {
				//std::cout << colName << ": NULL" << std::endl;
				std::string cName = colName;
				mappedRow[cName] = "NULL";
			}
			else {
				//std::cout << colName << ":" << colData << std::endl;
				std::string cName = colName;
				std::string cData = colData;
				mappedRow[cName] = cData;
			}
		}

		listOfRows.push_back(mappedRow);

	}
	if (rc != SQLITE_DONE) {
		std::cerr << "SELECT failed: " << sqlite3_errmsg(db) << std::endl;
		// if you return/throw here, don't forget the finalize
	}
	sqlite3_finalize(stmt);

	sqlite3_close(db);

	return listOfRows;
}