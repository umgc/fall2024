const fs = require('fs').promises;
const { Parser } = require('node-sql-parser');

async function validateSQLFile(filePath, fileName) {
    try {
        // Read the SQL file
        const sqlContent = await fs.readFile(filePath, 'utf8');

        // Create a new parser instance
        const parser = new Parser();

        // Split the content into individual statements
        // This regex splits on semicolons that are not within quotes
        const statements = sqlContent.split(';');


        let validStatements = 0;
        let totalStatements = 0;

        for (let stmt of statements) {
            stmt += ';';
            stmt = stmt.trim();
            if (stmt) {
                totalStatements++;
                try {
                    const ast = parser.astify(stmt);
                    // Uncomment the next line if you want to see the AST for each statement
                    // console.log(`Parsed AST:`, JSON.stringify(ast, null, 2));
                    validStatements++;
                } catch (error) {
                    console.error(`Error in statement ${totalStatements}:`, error.message);
                    console.error(`Problematic statement: ${stmt}`);
                }
            }
        }

        console.log(`${fileName}: Validated ${validStatements} out of ${totalStatements} statements.`);
        return validStatements === totalStatements;
    } catch (error) {
        console.log(`${fileName}: Validated 0 statements. Error with student submission: ${error}`);
    }
}

// Usage
const studentFilePath = `./uploads_sql/${process.argv[2]}`;
const studentFileName = process.argv[2];
validateSQLFile(studentFilePath, studentFileName);
