package com.example.flink;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class SqlRunnerTest {

    @Test
    void splitsMultilineStatementsAndIgnoresEmptyOnes() {
        List<String> statements = SqlRunner.splitStatements("""
                CREATE TABLE source_table (
                    value STRING
                );
                ;
                INSERT INTO sink_table
                SELECT value FROM source_table;
                """);

        assertEquals(2, statements.size());
        assertEquals("CREATE TABLE source_table (\n    value STRING\n)", statements.get(0));
        assertEquals("INSERT INTO sink_table\nSELECT value FROM source_table", statements.get(1));
    }

    @Test
    void doesNotSplitSemicolonsInsideSingleQuotedStrings() {
        List<String> statements = SqlRunner.splitStatements(
                "CREATE TABLE t (v STRING) WITH ('note' = 'one;two'); INSERT INTO s SELECT * FROM t;");

        assertEquals(2, statements.size());
        assertEquals("CREATE TABLE t (v STRING) WITH ('note' = 'one;two')", statements.get(0));
    }

    @Test
    void supportsSqlEscapedSingleQuotes() {
        List<String> statements = SqlRunner.splitStatements(
                "SELECT 'reader''s;value'; SELECT 'next';");

        assertEquals(List.of("SELECT 'reader''s;value'", "SELECT 'next'"), statements);
    }

    @Test
    void rejectsUnterminatedSingleQuotedStrings() {
        assertThrows(IllegalArgumentException.class,
                () -> SqlRunner.splitStatements("SELECT 'unfinished;"));
    }
}
