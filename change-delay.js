const fs = require('fs');
const yaml = require('js-yaml');

function processRecord(record, predicateFunction, reductionFactor) {
    // Using eval to create a function from the string
    const condition = eval(predicateFunction)
    if (condition(record)) {
        return { ...record, delay: Math.round(record.delay * reductionFactor) };
    }
    return record;
}

try {
    // Read command-line arguments
    const [filePath, predicateFunction, reductionFactorString] = process.argv.slice(2);
    const reductionFactor = parseFloat(reductionFactorString);

    // Read the YAML file
    const fileContents = fs.readFileSync(filePath, 'utf8');
    let data = yaml.load(fileContents);

    // Use map to process each record
    if (data.records && Array.isArray(data.records)) {
        data.records = data.records.map(record => processRecord(record, predicateFunction, reductionFactor));
    }

    // Convert the object back to YAML
    const newYaml = yaml.dump(data);

    // Save the modified content back to the file
    fs.writeFileSync(filePath, newYaml, 'utf8');
    console.log('File updated successfully.');
} catch (e) {
    console.error('Error processing file:', e);
}
