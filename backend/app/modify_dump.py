import re

def modify_dump(file_path, output_path):
    with open(file_path, 'r') as infile, open(output_path, 'w') as outfile:
        for line in infile:
            # Remove PRAGMA statements
            if line.startswith('PRAGMA'):
                continue
            # Replace AUTOINCREMENT with SERIAL
            line = re.sub(r'AUTOINCREMENT', 'SERIAL', line)
            # Remove transaction wrappers
            if line.startswith('BEGIN TRANSACTION') or line.startswith('COMMIT'):
                continue
            # Remove sqlite_sequence table
            if 'sqlite_sequence' in line:
                continue
            # Convert boolean values
            line = line.replace('0', 'FALSE').replace('1', 'TRUE')
            outfile.write(line)

modify_dump('sqlite_dump.sql', 'Postgre_modified.sql')
